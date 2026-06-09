# Internal rclone wrapper.
#
# system2(..., stderr = FALSE) silently swallows errors, which makes failed
# transfers maddening to debug. This wrapper captures both streams and, by
# default, raises an R error carrying rclone's own message.

# Is rclone on PATH (or at `path`)?
rcloneAvailable <- function(path = "rclone") {
  nzchar(Sys.which(path))
}

# Stop with a helpful message if rclone is missing.
requireRclone <- function(path = "rclone") {
  if (!rcloneAvailable(path)) {
    stop(
      "Could not find the 'rclone' executable",
      if (path != "rclone") sprintf(" at '%s'", path) else "",
      ".\n  buckethost uses rclone for uploads, deletes, and verification.",
      "\n  Install it from https://rclone.org/downloads/ and configure a ",
      "remote with `rclone config`.",
      call. = FALSE
    )
  }
  invisible(TRUE)
}

# Run rclone with `args` (a character vector). Returns captured output
# invisibly. On non-zero exit, errors (unless `error = FALSE`) with rclone's
# stderr included.
rclone <- function(args, path = "rclone", error = TRUE, echo = FALSE) {
  requireRclone(path)
  if (echo) {
    message("+ ", path, " ", paste(args, collapse = " "))
  }
  out <- suppressWarnings(
    system2(path, args = args, stdout = TRUE, stderr = TRUE)
  )
  status <- attr(out, "status")
  if (!is.null(status) && status != 0L && error) {
    stop(
      sprintf(
        "rclone failed (exit status %d):\n%s",
        status, paste(out, collapse = "\n")
      ),
      call. = FALSE
    )
  }
  invisible(out)
}
