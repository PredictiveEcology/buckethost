#' Verify a local tree against the bucket
#'
#' Wraps `rclone check` to compare a local directory with a remote prefix
#' after an upload. `method = "size"` (the default, `--size-only`) is fast and
#' usually sufficient; `method = "hash"` compares checksums for a stronger,
#' slower guarantee.
#'
#' @param local_dir Local directory to compare.
#' @param remote_path Remote prefix within the bucket to compare against.
#' @inheritParams bucket_config
#' @param method `"size"` for a size-only check (fast) or `"hash"` for a
#'   checksum comparison (thorough).
#' @param filter_file Optional `rclone` filter file, matching the one used for
#'   the upload, so the comparison considers the same set of files.
#' @param rclone_path Path to the `rclone` executable. Default `"rclone"`.
#'
#' @return Invisibly, a list with `ok` (logical; `TRUE` when rclone reports no
#'   differences) and `output` (rclone's captured stderr/stdout, which lists
#'   any mismatches).
#' @seealso [bucket_upload()]
#' @export
#' @examples
#' \dontrun{
#' res <- bucket_verify("~/local/SCANFI/1985", "SCANFI_v2/1985",
#'                      filter_file = "~/scanfi.filter")
#' res$ok
#' }
bucket_verify <- function(local_dir, remote_path,
                          container = NULL, remote = NULL,
                          method = c("size", "hash"),
                          filter_file = NULL,
                          rclone_path = "rclone") {
  method <- match.arg(method)
  dest <- sprintf("%s/%s", bucket_rclone_remote(container, remote), remote_path)
  args <- c(
    "check", local_dir, dest,
    if (method == "size") "--size-only",
    if (!is.null(filter_file)) c("--filter-from", filter_file)
  )
  # rclone check exits non-zero on differences; capture rather than error so
  # the caller can inspect the mismatches.
  out <- rclone(args, path = rclone_path, error = FALSE)
  status <- attr(out, "status")
  ok <- is.null(status) || status == 0L
  invisible(list(ok = ok, output = out))
}
