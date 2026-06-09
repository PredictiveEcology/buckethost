# Internal helpers (not exported).

# Human-readable byte sizes, vectorised. Matches the original generator's
# thresholds: KB below 1 MiB, MB below 1 GiB, GB above.
formatSize <- function(bytes) {
  ifelse(
    bytes < 1024^2,
    sprintf("%.1f KB", bytes / 1024),
    ifelse(
      bytes < 1024^3,
      sprintf("%.1f MB", bytes / 1024^2),
      sprintf("%.2f GB", bytes / 1024^3)
    )
  )
}

# All ancestor directory paths of an object key, excluding the file itself.
# "a/b/c.tif" -> c("a", "a/b"); "top.tif" -> character(0).
dirsForKey <- function(key) {
  parts <- strsplit(key, "/", fixed = TRUE)[[1]]
  if (length(parts) <= 1L) {
    return(character(0))
  }
  parents <- parts[-length(parts)]
  Reduce(function(a, b) paste(a, b, sep = "/"), parents, accumulate = TRUE)
}

# Minimal, dependency-free mustache-ish renderer: replaces every
# `{{name}}` token in `template` (a single string) with replacements[[name]].
# Replacement values are inserted literally (no regex backreferences).
renderTemplate <- function(template, replacements) {
  stopifnot(length(template) == 1L)
  for (nm in names(replacements)) {
    template <- gsub(
      paste0("{{", nm, "}}"),
      replacements[[nm]],
      template,
      fixed = TRUE
    )
  }
  template
}

# Escape the five XML/HTML special characters for safe interpolation into
# attribute-free text contexts.
htmlEscape <- function(x) {
  x <- gsub("&", "&amp;", x, fixed = TRUE)
  x <- gsub("<", "&lt;", x, fixed = TRUE)
  x <- gsub(">", "&gt;", x, fixed = TRUE)
  x <- gsub("\"", "&quot;", x, fixed = TRUE)
  x <- gsub("'", "&#39;", x, fixed = TRUE)
  x
}

# Path to the packaged HTML template, or a user override.
templatePath <- function(template = NULL) {
  if (!is.null(template)) {
    if (!file.exists(template)) {
      stop("Template file not found: ", template, call. = FALSE)
    }
    return(template)
  }
  system.file("templates", "index.html", package = "buckethost")
}

# Trim surrounding whitespace from a path argument and reject embedded control
# characters (newlines, tabs). A stray newline inside a path is almost always
# an accident (copy/paste, a trailing newline carried into basename()), and if
# rclone is reached through a shell wrapper such a newline silently splits the
# command into pieces -- a very confusing failure. Fail early and clearly.
cleanArg <- function(x, name) {
  if (length(x) != 1L || !is.character(x)) {
    stop("`", name, "` must be a single string.", call. = FALSE)
  }
  x <- trimws(x)
  if (grepl("[[:cntrl:]]", x)) {
    stop(
      "`", name, "` contains a newline or control character after trimming: ",
      encodeString(x, quote = "\""),
      "\n  This usually means a stray line break crept into the path.",
      call. = FALSE
    )
  }
  x
}

# Normalise a destination into an object key. A plain key is returned with any
# leading slashes trimmed. A full public URL (what users often paste, e.g.
# "https://endpoint/container/SCANFI_v2/x.csv") is stripped down to the key
# ("SCANFI_v2/x.csv") so it doesn't get nested under the bucket as a literal
# path. Stripping uses the resolved base URL first, then falls back to the
# "/<container>/" marker for endpoints that differ from the default.
asBucketKey <- function(path, container = NULL, endpoint = NULL) {
  if (length(path) != 1L) {
    return(sub("^/+", "", path))
  }
  if (grepl("^https?://", path)) {
    base <- paste0(bucketBaseUrl(container, endpoint), "/")
    if (startsWith(path, base)) {
      return(substring(path, nchar(base) + 1L))
    }
    marker <- paste0("/", bucketContainer(container), "/")
    pos <- regexpr(marker, path, fixed = TRUE)
    if (pos > 0L) {
      return(substring(path, pos + nchar(marker)))
    }
    stop(
      "Could not derive an object key from URL (container '",
      bucketContainer(container), "' not found in it): ", path,
      call. = FALSE
    )
  }
  sub("^/+", "", path)
}
