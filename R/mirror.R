# Reconstruct each item's path relative to `rootId` from the parent chain in a
# googledrive listing. drive_ls(recursive = TRUE) flattens the tree (the `name`
# column is just the file name), so to disambiguate repeated names we rebuild
# "1985/age.tif" by walking parents -> root. Returns a character vector aligned
# with `d`'s rows, or NULL if the listing carries no parent information (older
# googledrive, or fields not requested) so the caller can fall back.
driveRelPaths <- function(d, rootId) {
  res <- d$drive_resource
  if (is.null(res)) {
    return(NULL)
  }
  getParent <- function(r) {
    p <- tryCatch(r[["parents"]], error = function(e) NULL)
    if (is.null(p) || length(p) == 0L) NA_character_ else as.character(p)[[1]]
  }
  parentId <- vapply(res, getParent, character(1))
  if (all(is.na(parentId))) {
    return(NULL)
  }

  ids <- as.character(d$id)
  nameById <- as.character(d$name)
  names(nameById) <- ids
  parentById <- parentId
  names(parentById) <- ids

  vapply(ids, function(id) {
    parts <- character(0)
    cur <- id
    guard <- 0L
    while (!is.na(cur) && !identical(cur, rootId) && guard < 1000L) {
      nm <- unname(nameById[cur])
      if (is.na(nm)) break # parent outside the listed tree
      parts <- c(nm, parts)
      cur <- unname(parentById[cur])
      guard <- guard + 1L
    }
    paste(parts, collapse = "/")
  }, character(1), USE.NAMES = FALSE)
}

# Which rows of a googledrive listing are *folders*? A file can never be a
# parent, so any id that appears as another listed item's parent is a folder.
# Empty folders have no children and so are not detected -- which is fine for a
# mirror manifest, since an empty folder mirrors no objects. Returns a logical
# vector aligned with `d`'s rows (all FALSE if the listing carries no parent
# information).
driveIsFolder <- function(d) {
  res <- d$drive_resource
  if (is.null(res)) {
    return(rep(FALSE, nrow(d)))
  }
  getParent <- function(r) {
    p <- tryCatch(r[["parents"]], error = function(e) NULL)
    if (is.null(p) || length(p) == 0L) NA_character_ else as.character(p)[[1]]
  }
  parentId <- vapply(res, getParent, character(1))
  as.character(d$id) %in% unique(parentId[!is.na(parentId)])
}

#' Build a mirror manifest for a bucket
#'
#' Produces a "remap" table: one row per object in the bucket, giving its
#' `filename`, its full object `key`, and its public `url`. Optionally adds an
#' `id` column with the matching Google Drive file id, so you can map a Drive
#' source to its mirrored copy on the bucket. Optionally writes the table to a
#' CSV.
#'
#' With `directories = TRUE` the manifest also gains one row per Google Drive
#' **folder** (a *directory remap*): its `url` is the bucket's S3 prefix-listing
#' URL for the matching folder (`<base>/?prefix=<key>/&delimiter=/`), and a
#' `type` column distinguishes `"dir"` rows from `"file"` rows. A consumer
#' (e.g. `reproducible`) can then enumerate a Drive folder's contents from the
#' public bucket listing instead of `googledrive::drive_ls()`, so listing a
#' folder needs no Google authentication.
#'
#' @param bucket Container (bucket) name. When `NULL` (default), resolved via
#'   [bucketContainer()].
#' @param prefix Optional key prefix to restrict the manifest, e.g.
#'   `"SCANFI_v2/1985"`. Default `""` (the whole bucket).
#' @param driveFolder Optional Google Drive folder id or URL corresponding to
#'   the bucket's `prefix` folder. When supplied, the folder is listed
#'   recursively and an `id` column is added, matched to the bucket objects by
#'   their **path relative to the folder** (see Details). Requires the
#'   \pkg{googledrive} package.
#' @param endpoint Optional endpoint override (see [bucketConfig]).
#' @param file Optional path to write the manifest to as CSV. When `NULL`
#'   (default) no file is written.
#' @param directories Logical. When `TRUE`, append one *directory remap* row per
#'   Google Drive folder (mapping its folder id to the bucket's prefix-listing
#'   URL) and add a `type` column (`"file"`/`"dir"`). Requires `driveFolder`.
#'   Default `FALSE` (file rows only, unchanged schema).
#'
#' @details
#' Matching to Drive is by **relative path**, not bare file name. The bucket
#' object `SCANFI_v2/1985/age.tif` (with `prefix = "SCANFI_v2"`) is matched to
#' the Drive file at `1985/age.tif` under `driveFolder`. This keeps identical
#' file names under different folders (e.g. `1985/age.tif` and
#' `1990/age.tif`) distinct, which a bare-`basename()` match cannot do.
#'
#' Because `googledrive::drive_ls(recursive = TRUE)` flattens the tree, the
#' relative Drive paths are reconstructed from each item's parent chain. If the
#' listing carries no parent information, the function falls back to file-name
#' matching and warns. Objects with no Drive file at the matching path get
#' `NA` and a count is warned.
#'
#' @return A `data.frame` with columns `filename`, `key`, `url`, and (when
#'   `driveFolder` is given) `id`; plus a `type` column and appended directory
#'   rows when `directories = TRUE`. Returned invisibly when `file` is written,
#'   visibly otherwise.
#' @seealso [bucketLs()], [bucketUrl()]
#' @export
#' @examples
#' \dontrun{
#' m <- buckethost::makeMirrorManifest(
#'   "predictiveecology", "SCANFI_v2/",
#'   driveFolder = "https://.../folders/199oEp-..."
#' )
#' write.csv(m, "arbutus_manifest_SCANFI_v2_clean.csv", row.names = FALSE)
#'
#' # Or let makeMirrorManifest() write the CSV for you via `file =`:
#' makeMirrorManifest("predictiveecology", "SCANFI_v2/",
#'                    driveFolder = "https://.../folders/199oEp-...",
#'                    file = "arbutus_manifest_SCANFI_v2_clean.csv")
#' }
makeMirrorManifest <- function(bucket = NULL,
                               prefix = "",
                               driveFolder = NULL,
                               endpoint = NULL,
                               file = NULL,
                               directories = FALSE) {
  if (isTRUE(directories) && is.null(driveFolder)) {
    stop(
      "directories = TRUE needs 'driveFolder': a directory remap row carries ",
      "the Google Drive folder id, which comes from the Drive listing.",
      call. = FALSE
    )
  }
  objs <- bucketLs(prefix = prefix, container = bucket, endpoint = endpoint)

  m <- data.frame(
    filename = basename(objs$key),
    key = objs$key,
    url = bucketUrl(objs$key, container = bucket, endpoint = endpoint),
    stringsAsFactors = FALSE
  )

  if (!is.null(driveFolder)) {
    if (!requireNamespace("googledrive", quietly = TRUE)) {
      stop(
        "Matching to Google Drive needs the 'googledrive' package. ",
        "Install it with install.packages('googledrive').",
        call. = FALSE
      )
    }
    d <- googledrive::drive_ls(googledrive::as_id(driveFolder), recursive = TRUE)
    rootId <- as.character(googledrive::as_id(driveFolder))

    # Path of each bucket object relative to the prefix folder, e.g. key
    # "SCANFI_v2/1985/age.tif" with prefix "SCANFI_v2" -> "1985/age.tif".
    pfx <- sub("/+$", "", prefix)
    bucketRel <- m$key
    if (nzchar(pfx)) {
      pre <- paste0(pfx, "/")
      bucketRel <- ifelse(
        startsWith(m$key, pre), substring(m$key, nchar(pre) + 1L), m$key
      )
    }

    driveRel <- driveRelPaths(d, rootId)
    if (is.null(driveRel)) {
      warning(
        "Could not reconstruct Google Drive folder paths (no parent info in ",
        "the listing); falling back to file-name matching, which is ambiguous ",
        "when the same name appears under more than one folder.",
        call. = FALSE
      )
      m$id <- d$id[match(m$filename, d$name)]
    } else {
      # Match on the full relative path so identical file names under
      # different folders (e.g. 1985/age.tif vs 1990/age.tif) stay distinct.
      m$id <- d$id[match(bucketRel, driveRel)]
      nMiss <- sum(is.na(m$id))
      if (nMiss > 0L) {
        missKeys <- m$key[is.na(m$id)]
        shown <- paste(utils::head(missKeys, 5L), collapse = ", ")
        if (nMiss > 5L) shown <- paste0(shown, ", ...")
        warning(
          sprintf(
            paste0(
              "%d of %d object(s) had no Drive file at the matching relative ",
              "path (kept with id = NA): %s. This is expected for bucket ",
              "objects with no Drive source (e.g. a manifest CSV or ",
              "generated index)."
            ),
            nMiss, nrow(m), shown
          ),
          call. = FALSE
        )
      }
    }
  }

  if (isTRUE(directories)) {
    m$type <- "file"
    # `driveRel` / `d` come from the driveFolder block above (always run when
    # directories = TRUE). Skip directory rows if folder paths are unavailable.
    if (is.null(driveRel)) {
      warning(
        "directories = TRUE: could not reconstruct Google Drive folder paths ",
        "(no parent info in the listing); no directory rows added.",
        call. = FALSE
      )
    } else {
      isDir <- driveIsFolder(d)
      if (any(isDir)) {
        rel <- driveRel[isDir]
        bp <- if (nzchar(pfx)) paste0(pfx, "/", rel) else rel
        base <- bucketBaseUrl(container = bucket, endpoint = endpoint)
        listUrl <- paste0(
          base, "/?prefix=",
          vapply(paste0(bp, "/"), utils::URLencode, character(1), reserved = TRUE),
          "&delimiter=/"
        )
        dirRows <- data.frame(
          filename = basename(rel),
          key = paste0(bp, "/"),
          url = listUrl,
          id = as.character(d$id[isDir]),
          type = "dir",
          stringsAsFactors = FALSE
        )
        m <- rbind(m, dirRows[names(m)])
      }
    }
  }

  if (!is.null(file)) {
    utils::write.csv(m, file, row.names = FALSE)
    return(invisible(m))
  }
  m
}
