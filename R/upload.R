#' Upload files to a bucket
#'
#' Thin, loud wrapper around `rclone copy`. Copies `local` (a file or
#' directory) to `remotePath` within the bucket. rclone only transfers what
#' has changed, so re-running is cheap and idempotent.
#'
#' @param local Path to a local file or directory to upload.
#' @param remotePath Destination within the bucket. Either a key/prefix like
#'   `"SCANFI_v2/1985"`, or a full public URL like
#'   `"https://endpoint/container/SCANFI_v2/file.csv"` — a URL is normalised to
#'   the key (`"SCANFI_v2/file.csv"`) so the file lands where you expect rather
#'   than nested under the bucket. Leading slashes are not required.
#' @inheritParams bucketConfig
#' @param filterFile Optional path to an `rclone` filter file (`--filter-from`)
#'   to include/exclude by pattern. See the migration vignette for an example.
#' @param transfers Number of parallel transfers (`--transfers`). Default 16.
#' @param extra Character vector of additional raw `rclone` flags, e.g.
#'   `c("--retries", "10", "--stats", "60s")`.
#' @param rclonePath Path to the `rclone` executable. Default `"rclone"`.
#' @param dryRun If `TRUE`, pass `--dry-run` so rclone reports what it *would*
#'   do without transferring. Default `FALSE`.
#' @param echo If `TRUE`, print the rclone command before running it.
#'
#' @return Invisibly, rclone's captured output (character).
#' @seealso [bucketVerify()], [bucketDelete()]
#' @export
#' @examples
#' \dontrun{
#' bucketUpload("~/local/SCANFI/1985", "SCANFI_v2/1985",
#'               filterFile = "~/scanfi.filter",
#'               extra = c("--retries", "10", "--stats", "60s"))
#' }
bucketUpload <- function(local, remotePath,
                          container = NULL, remote = NULL,
                          filterFile = NULL, transfers = 16L,
                          extra = character(0),
                          rclonePath = "rclone",
                          dryRun = FALSE, echo = FALSE) {
  remotePath <- asBucketKey(remotePath, container)
  dest <- sprintf("%s/%s", bucketRcloneRemote(container, remote), remotePath)
  args <- c(
    "copy", local, dest,
    "--transfers", as.character(transfers),
    if (!is.null(filterFile)) c("--filter-from", filterFile),
    if (dryRun) "--dry-run",
    extra
  )
  rclone(args, path = rclonePath, echo = echo)
}

#' Delete an object or prefix from a bucket
#'
#' Removes a single file (`rclone deletefile`) or an entire prefix
#' (`rclone delete`, when `recursive = TRUE`) from the bucket. Because this is
#' destructive it asks for confirmation by default; set `confirm = FALSE` to
#' delete non-interactively (e.g. in scripts).
#'
#' @param remotePath Key (single file) or prefix (with `recursive = TRUE`) to
#'   delete, e.g. `"SCANFI_v2/1985/old.tif"`. A full public URL is accepted and
#'   normalised to the key.
#' @inheritParams bucketConfig
#' @param recursive If `TRUE`, delete everything under `remotePath` (a
#'   prefix). If `FALSE` (default), delete a single object.
#' @param confirm If `TRUE` (default) and the session is interactive, prompt
#'   before deleting.
#' @param rclonePath Path to the `rclone` executable. Default `"rclone"`.
#' @param dryRun If `TRUE`, pass `--dry-run`. Default `FALSE`.
#'
#' @return Invisibly, rclone's captured output, or `NULL` if cancelled.
#' @seealso [bucketUpload()]
#' @export
bucketDelete <- function(remotePath,
                          container = NULL, remote = NULL,
                          recursive = FALSE, confirm = TRUE,
                          rclonePath = "rclone", dryRun = FALSE) {
  remotePath <- asBucketKey(remotePath, container)
  dest <- sprintf("%s/%s", bucketRcloneRemote(container, remote), remotePath)

  if (confirm && interactive() && !dryRun) {
    what <- if (recursive) "EVERYTHING under prefix" else "object"
    ans <- readline(sprintf("Delete %s '%s'? [y/N] ", what, dest))
    if (!tolower(trimws(ans)) %in% c("y", "yes")) {
      message("Cancelled.")
      return(invisible(NULL))
    }
  }

  verb <- if (recursive) "delete" else "deletefile"
  args <- c(verb, dest, if (dryRun) "--dry-run")
  rclone(args, path = rclonePath)
}
