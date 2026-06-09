#' Verify a local tree against the bucket
#'
#' Wraps `rclone check` to compare a local directory with a remote prefix
#' after an upload. `method = "size"` (the default, `--size-only`) is fast and
#' usually sufficient; `method = "hash"` compares checksums for a stronger,
#' slower guarantee.
#'
#' @param localDir Local directory to compare.
#' @param remotePath Remote prefix within the bucket to compare against.
#' @inheritParams bucketConfig
#' @param method `"size"` for a size-only check (fast) or `"hash"` for a
#'   checksum comparison (thorough).
#' @param filterFile Optional `rclone` filter file, matching the one used for
#'   the upload, so the comparison considers the same set of files.
#' @param rclonePath Path to the `rclone` executable. Default `"rclone"`.
#'
#' @return Invisibly, a list with `ok` (logical; `TRUE` when rclone reports no
#'   differences) and `output` (rclone's captured stderr/stdout, which lists
#'   any mismatches).
#' @seealso [bucketUpload()]
#' @export
#' @examples
#' \dontrun{
#' res <- bucketVerify("~/local/SCANFI/1985", "SCANFI_v2/1985",
#'                      filterFile = "~/scanfi.filter")
#' res$ok
#' }
bucketVerify <- function(localDir, remotePath,
                          container = NULL, remote = NULL,
                          method = c("size", "hash"),
                          filterFile = NULL,
                          rclonePath = "rclone") {
  method <- match.arg(method)
  localDir <- cleanArg(localDir, "localDir")
  remotePath <- cleanArg(remotePath, "remotePath")
  remotePath <- asBucketKey(remotePath, container)
  dest <- sprintf("%s/%s", bucketRcloneRemote(container, remote), remotePath)
  args <- c(
    "check", localDir, dest,
    if (method == "size") "--size-only",
    if (!is.null(filterFile)) c("--filter-from", filterFile)
  )
  # rclone check exits non-zero on differences; capture rather than error so
  # the caller can inspect the mismatches.
  out <- rclone(args, path = rclonePath, error = FALSE)
  status <- attr(out, "status")
  ok <- is.null(status) || status == 0L
  invisible(list(ok = ok, output = out))
}
