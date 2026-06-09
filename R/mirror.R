#' Build a mirror manifest for a bucket
#'
#' Produces a "remap" table: one row per object in the bucket, giving its
#' `filename`, its full object `key`, and its public `url`. Optionally adds an
#' `id` column with the matching Google Drive file id, so you can map a Drive
#' source to its mirrored copy on the bucket. Optionally writes the table to a
#' CSV.
#'
#' @param bucket Container (bucket) name. When `NULL` (default), resolved via
#'   [bucketContainer()].
#' @param prefix Optional key prefix to restrict the manifest, e.g.
#'   `"SCANFI_v2/1985"`. Default `""` (the whole bucket).
#' @param driveFolder Optional Google Drive folder id or URL. When supplied,
#'   the folder is listed recursively and an `id` column is added, matched to
#'   the bucket objects by file name. Requires the \pkg{googledrive} package.
#' @param endpoint Optional endpoint override (see [bucketConfig]).
#' @param file Optional path to write the manifest to as CSV. When `NULL`
#'   (default) no file is written.
#'
#' @details
#' Matching to Drive is by **file name** (`basename(key)`). If the same file
#' name appears under more than one folder in the bucket, those rows cannot be
#' told apart by name alone and the `id` match is ambiguous; a warning is
#' issued listing the offending names. The `key` column always disambiguates
#' the rows themselves.
#'
#' @return A `data.frame` with columns `filename`, `key`, `url`, and (when
#'   `driveFolder` is given) `id`. Returned invisibly when `file` is written,
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
                               file = NULL) {
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
    dupes <- unique(m$filename[duplicated(m$filename)])
    if (length(dupes) > 0) {
      warning(
        "Some file names occur under more than one prefix; their Drive 'id' ",
        "match is ambiguous (first match wins): ",
        paste(dupes, collapse = ", "),
        call. = FALSE
      )
    }
    d <- googledrive::drive_ls(googledrive::as_id(driveFolder), recursive = TRUE)
    m$id <- d$id[match(m$filename, d$name)]
  }

  if (!is.null(file)) {
    utils::write.csv(m, file, row.names = FALSE)
    return(invisible(m))
  }
  m
}
