# Read one page of a bucket listing. A bucket that refuses anonymous listing
# makes xml2 fail with only "cannot open the connection"; the HTTP status is in
# a warning. Turn that case into a classed error so bucketLs() can fall back to
# rclone, and let every other failure through unchanged.
readListing <- function(url) {
  warns <- character(0)
  withCallingHandlers(
    tryCatch(xml2::read_xml(url), error = function(e) {
      if (any(grepl("error: 403", warns, fixed = TRUE))) {
        stop(structure(
          class = c("buckethostListingDenied", "error", "condition"),
          list(message = paste0("Anonymous listing refused (HTTP 403): ", url),
               call = NULL)
        ))
      }
      stop(e)
    }),
    warning = function(w) {
      warns <<- c(warns, conditionMessage(w))
      invokeRestart("muffleWarning")
    }
  )
}

# List keys under `prefix` with `rclone lsf`, using credentials from the rclone
# remote. rclone lists by directory, so list the directory part of the prefix
# and keep keys that start with the full prefix (S3 prefix semantics).
# `modified` is rclone's modification time (the source file's time when it was
# uploaded with rclone), formatted "YYYY-MM-DD HH:MM:SS".
rcloneListKeys <- function(rcloneRemote, prefix = "", rclonePath = "rclone") {
  dir <- sub("[^/]*$", "", prefix)
  out <- rclone(
    c("lsf", "-R", "--files-only", "--format", "pst", "--separator", "\t",
      paste0(rcloneRemote, "/", dir)),
    path = rclonePath, error = FALSE
  )
  status <- attr(out, "status")
  if (!is.null(status) && status != 0L) {
    if (any(grepl("directory not found", out, fixed = TRUE))) {
      out <- character(0)
    } else {
      stop(sprintf("rclone failed (exit status %d):\n%s",
                   status, paste(out, collapse = "\n")), call. = FALSE)
    }
  }
  # rclone's stderr (e.g. NOTICE lines) is captured too; keep only listing rows.
  out <- grep("^[^\t]+\t[0-9]+\t", out, value = TRUE)
  parts <- strsplit(out, "\t", fixed = TRUE)
  df <- data.frame(
    key = paste0(dir, vapply(parts, `[`, character(1), 1L)),
    size = as.numeric(vapply(parts, `[`, character(1), 2L)),
    modified = vapply(parts, `[`, character(1), 3L),
    stringsAsFactors = FALSE
  )
  df[startsWith(df$key, prefix), , drop = FALSE]
}

# Walk a bucket's public S3 listing API, following pagination markers.
# `base_url` is the public bucket URL (endpoint/container). The bucket must
# allow anonymous listing (public-read) for this to work without credentials.
fetchAllKeys <- function(base_url, prefix = "") {
  out <- list()
  marker <- ""
  repeat {
    url <- paste0(
      base_url,
      "?marker=", utils::URLencode(marker, reserved = TRUE),
      if (nzchar(prefix)) {
        paste0("&prefix=", utils::URLencode(prefix, reserved = TRUE))
      } else {
        ""
      }
    )
    resp <- readListing(url)
    ns <- xml2::xml_ns(resp)
    contents <- xml2::xml_find_all(resp, ".//d1:Contents", ns)
    if (length(contents) == 0L) {
      break
    }
    keys <- xml2::xml_text(xml2::xml_find_all(contents, ".//d1:Key", ns))
    sizes <- as.numeric(
      xml2::xml_text(xml2::xml_find_all(contents, ".//d1:Size", ns))
    )
    modified <- xml2::xml_text(
      xml2::xml_find_all(contents, ".//d1:LastModified", ns)
    )
    out[[length(out) + 1L]] <- data.frame(
      key = keys, size = sizes, modified = modified,
      stringsAsFactors = FALSE
    )

    truncated <- xml2::xml_text(
      xml2::xml_find_first(resp, ".//d1:IsTruncated", ns)
    )
    if (is.na(truncated) || truncated != "true") {
      break
    }
    marker <- keys[length(keys)]
  }
  if (length(out) == 0L) {
    return(data.frame(
      key = character(0), size = numeric(0), modified = character(0),
      stringsAsFactors = FALSE
    ))
  }
  do.call(rbind, out)
}

#' List objects in a bucket
#'
#' Reads the bucket's public S3 listing API and returns one row per object.
#' Pagination (1000 keys per response) is handled for you. If the bucket
#' refuses anonymous listing (HTTP 403), as the PredictiveEcology bucket on the
#' new Arbutus does, it lists with `rclone` instead, using the credentials of
#' your rclone `remote`.
#'
#' @param prefix Optional key prefix to restrict the listing, e.g.
#'   `"SCANFI_v2/1985"`. Default `""` lists everything.
#' @inheritParams bucketConfig
#' @param includeIndexes If `FALSE` (default), generated `index.html` files
#'   are dropped from the result so you see only data objects.
#' @param rclonePath Path to the `rclone` executable, used only when anonymous
#'   listing is refused. Default `"rclone"`.
#'
#' @return A `data.frame` with columns `key`, `size` (bytes), and `modified`
#'   (a time string: ISO-8601 from the public listing, `"YYYY-MM-DD HH:MM:SS"`
#'   from rclone), sorted by key.
#' @seealso [bucketUrl()], [generateIndexes()]
#' @export
#' @examples
#' \dontrun{
#' bucketLs(prefix = "SCANFI_v2/1985",
#'           endpoint = "https://object-arbutus.cloud.computecanada.ca",
#'           container = "predictiveecology")
#' }
bucketLs <- function(prefix = "",
                      container = NULL,
                      endpoint = NULL,
                      includeIndexes = FALSE,
                      remote = NULL,
                      rclonePath = "rclone") {
  base_url <- bucketBaseUrl(container, endpoint)
  df <- tryCatch(
    fetchAllKeys(base_url, prefix = prefix),
    buckethostListingDenied = function(e) {
      rcloneRemote <- bucketRcloneRemote(container, remote)
      message("Anonymous listing refused; listing with rclone remote '",
              rcloneRemote, "'.")
      rcloneListKeys(rcloneRemote, prefix = prefix, rclonePath = rclonePath)
    }
  )
  if (!includeIndexes && nrow(df) > 0) {
    df <- df[!grepl("(^|/)index\\.html$", df$key), , drop = FALSE]
  }
  df <- df[order(df$key), , drop = FALSE]
  rownames(df) <- NULL
  df
}
