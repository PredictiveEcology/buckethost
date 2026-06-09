#' Upload files to a bucket
#'
#' Thin, loud wrapper around `rclone copy`. Copies `local` (a file or
#' directory) to `remote_path` within the bucket. rclone only transfers what
#' has changed, so re-running is cheap and idempotent.
#'
#' @param local Path to a local file or directory to upload.
#' @param remote_path Destination key/prefix within the bucket, e.g.
#'   `"SCANFI_v2/1985"`. Leading slashes are not required.
#' @inheritParams bucket_config
#' @param filter_file Optional path to an `rclone` filter file (`--filter-from`)
#'   to include/exclude by pattern. See the migration vignette for an example.
#' @param transfers Number of parallel transfers (`--transfers`). Default 16.
#' @param extra Character vector of additional raw `rclone` flags, e.g.
#'   `c("--retries", "10", "--stats", "60s")`.
#' @param rclone_path Path to the `rclone` executable. Default `"rclone"`.
#' @param dry_run If `TRUE`, pass `--dry-run` so rclone reports what it *would*
#'   do without transferring. Default `FALSE`.
#' @param echo If `TRUE`, print the rclone command before running it.
#'
#' @return Invisibly, rclone's captured output (character).
#' @seealso [bucket_verify()], [bucket_delete()]
#' @export
#' @examples
#' \dontrun{
#' bucket_upload("~/local/SCANFI/1985", "SCANFI_v2/1985",
#'               filter_file = "~/scanfi.filter",
#'               extra = c("--retries", "10", "--stats", "60s"))
#' }
bucket_upload <- function(local, remote_path,
                          container = NULL, remote = NULL,
                          filter_file = NULL, transfers = 16L,
                          extra = character(0),
                          rclone_path = "rclone",
                          dry_run = FALSE, echo = FALSE) {
  dest <- sprintf("%s/%s", bucket_rclone_remote(container, remote), remote_path)
  args <- c(
    "copy", local, dest,
    "--transfers", as.character(transfers),
    if (!is.null(filter_file)) c("--filter-from", filter_file),
    if (dry_run) "--dry-run",
    extra
  )
  rclone(args, path = rclone_path, echo = echo)
}

#' Delete an object or prefix from a bucket
#'
#' Removes a single file (`rclone deletefile`) or an entire prefix
#' (`rclone delete`, when `recursive = TRUE`) from the bucket. Because this is
#' destructive it asks for confirmation by default; set `confirm = FALSE` to
#' delete non-interactively (e.g. in scripts).
#'
#' @param remote_path Key (single file) or prefix (with `recursive = TRUE`) to
#'   delete, e.g. `"SCANFI_v2/1985/old.tif"`.
#' @inheritParams bucket_config
#' @param recursive If `TRUE`, delete everything under `remote_path` (a
#'   prefix). If `FALSE` (default), delete a single object.
#' @param confirm If `TRUE` (default) and the session is interactive, prompt
#'   before deleting.
#' @param rclone_path Path to the `rclone` executable. Default `"rclone"`.
#' @param dry_run If `TRUE`, pass `--dry-run`. Default `FALSE`.
#'
#' @return Invisibly, rclone's captured output, or `NULL` if cancelled.
#' @seealso [bucket_upload()]
#' @export
bucket_delete <- function(remote_path,
                          container = NULL, remote = NULL,
                          recursive = FALSE, confirm = TRUE,
                          rclone_path = "rclone", dry_run = FALSE) {
  dest <- sprintf("%s/%s", bucket_rclone_remote(container, remote), remote_path)

  if (confirm && interactive() && !dry_run) {
    what <- if (recursive) "EVERYTHING under prefix" else "object"
    ans <- readline(sprintf("Delete %s '%s'? [y/N] ", what, dest))
    if (!tolower(trimws(ans)) %in% c("y", "yes")) {
      message("Cancelled.")
      return(invisible(NULL))
    }
  }

  verb <- if (recursive) "delete" else "deletefile"
  args <- c(verb, dest, if (dry_run) "--dry-run")
  rclone(args, path = rclone_path)
}
