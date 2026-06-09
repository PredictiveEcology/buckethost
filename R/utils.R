# Internal helpers (not exported).

# Human-readable byte sizes, vectorised. Matches the original generator's
# thresholds: KB below 1 MiB, MB below 1 GiB, GB above.
format_size <- function(bytes) {
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
dirs_for_key <- function(key) {
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
render_template <- function(template, replacements) {
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
html_escape <- function(x) {
  x <- gsub("&", "&amp;", x, fixed = TRUE)
  x <- gsub("<", "&lt;", x, fixed = TRUE)
  x <- gsub(">", "&gt;", x, fixed = TRUE)
  x <- gsub("\"", "&quot;", x, fixed = TRUE)
  x <- gsub("'", "&#39;", x, fixed = TRUE)
  x
}

# Path to the packaged HTML template, or a user override.
template_path <- function(template = NULL) {
  if (!is.null(template)) {
    if (!file.exists(template)) {
      stop("Template file not found: ", template, call. = FALSE)
    }
    return(template)
  }
  system.file("templates", "index.html", package = "buckethost")
}
