# Walk a bucket's public S3 listing API, following pagination markers.
# `base_url` is the public bucket URL (endpoint/container). The bucket must
# allow anonymous listing (public-read) for this to work without credentials.
fetch_all_keys <- function(base_url, prefix = "") {
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
    resp <- xml2::read_xml(url)
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
#' Pagination (1000 keys per response) is handled for you. The bucket must be
#' configured for public/anonymous read.
#'
#' @param prefix Optional key prefix to restrict the listing, e.g.
#'   `"SCANFI_v2/1985"`. Default `""` lists everything.
#' @inheritParams bucket_config
#' @param include_indexes If `FALSE` (default), generated `index.html` files
#'   are dropped from the result so you see only data objects.
#'
#' @return A `data.frame` with columns `key`, `size` (bytes), and `modified`
#'   (ISO-8601 string), sorted by key.
#' @seealso [bucket_url()], [generate_indexes()]
#' @export
#' @examples
#' \dontrun{
#' bucket_ls(prefix = "SCANFI_v2/1985",
#'           endpoint = "https://object-arbutus.cloud.computecanada.ca",
#'           container = "predictiveecology")
#' }
bucket_ls <- function(prefix = "",
                      container = NULL,
                      endpoint = NULL,
                      include_indexes = FALSE) {
  base_url <- bucket_base_url(container, endpoint)
  df <- fetch_all_keys(base_url, prefix = prefix)
  if (!include_indexes && nrow(df) > 0) {
    df <- df[!grepl("(^|/)index\\.html$", df$key), , drop = FALSE]
  }
  df <- df[order(df$key), , drop = FALSE]
  rownames(df) <- NULL
  df
}
