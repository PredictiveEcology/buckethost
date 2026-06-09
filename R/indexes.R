# ---- internal: build the HTML for one directory level --------------------

# Construct the breadcrumb / parent-link / row HTML for a single directory
# `dir` ("" is the root) given the full object table `allFiles`.
# Returns a list of the pieces the template needs.
buildPageParts <- function(dir, allFiles, rootLabel) {
  prefix <- if (nzchar(dir)) paste0(dir, "/") else ""
  depth <- if (nzchar(dir)) {
    length(strsplit(dir, "/", fixed = TRUE)[[1]])
  } else {
    0L
  }

  isDesc <- startsWith(allFiles$key, prefix)
  rel <- substring(allFiles$key[isDesc], nchar(prefix) + 1L)
  relSize <- allFiles$size[isDesc]

  isInSubdir <- grepl("/", rel, fixed = TRUE)

  # Immediate files, sorted by name.
  fName <- rel[!isInSubdir]
  fSize <- relSize[!isInSubdir]
  ord <- order(fName)
  fName <- fName[ord]
  fSize <- fSize[ord]

  # Immediate subdirectories.
  subdirs <- if (any(isInSubdir)) {
    sort(unique(sub("/.*$", "", rel[isInSubdir])))
  } else {
    character(0)
  }

  # Breadcrumb: root link + one clickable link per path component.
  rootLink <- sprintf(
    "<a href='%s./index.html'>%s</a>",
    paste(rep("../", depth), collapse = ""),
    htmlEscape(rootLabel)
  )
  parts <- if (nzchar(dir)) strsplit(dir, "/", fixed = TRUE)[[1]] else character(0)
  crumbs <- if (length(parts) > 0) {
    vapply(seq_along(parts), function(i) {
      up <- depth - i
      href <- if (up == 0) {
        "./index.html"
      } else {
        paste0(paste(rep("../", up), collapse = ""), "index.html")
      }
      sprintf("<a href='%s'>%s</a>", href, htmlEscape(parts[i]))
    }, character(1))
  } else {
    character(0)
  }
  breadcrumb <- paste(c(rootLink, crumbs), collapse = " / ")

  parentLink <- if (nzchar(dir)) {
    "<p><a href='../index.html'>\u2B06 Parent directory</a></p>"
  } else {
    ""
  }

  # Rows. Directories carry no size and always sort to the top (the client
  # JS keeps them grouped); files carry data-size for numeric sorting.
  dirRows <- if (length(subdirs) > 0) {
    sprintf(
      "<tr class='dir'><td><a href='%s/index.html'>%s/</a></td><td></td></tr>",
      subdirs, htmlEscape(subdirs)
    )
  } else {
    character(0)
  }
  fileRows <- if (length(fName) > 0) {
    sprintf(
      paste0(
        "<tr class='file' data-size='%.0f'>",
        "<td><a href='%s'>%s</a></td>",
        "<td style='text-align:right'>%s</td></tr>"
      ),
      fSize, fName, htmlEscape(fName), formatSize(fSize)
    )
  } else {
    character(0)
  }

  list(
    breadcrumb = breadcrumb,
    parentLink = parentLink,
    rows = paste(c(dirRows, fileRows), collapse = "\n"),
    nDirs = length(subdirs),
    nFiles = length(fName)
  )
}

# Render the full HTML page for one directory.
buildPageHtml <- function(dir, allFiles, template, opts) {
  parts <- buildPageParts(dir, allFiles, opts$rootLabel)

  viewing <- if (nzchar(dir)) {
    sprintf("Currently viewing: <code>%s</code>", htmlEscape(dir))
  } else {
    "Repository contents"
  }
  pageTitle <- if (nzchar(dir)) {
    paste0(htmlEscape(dir), " \u2014 ", htmlEscape(opts$heading))
  } else {
    htmlEscape(opts$heading)
  }

  html <- renderTemplate(template, list(
    pageTitle = pageTitle,
    repoHeading = htmlEscape(opts$heading),
    disclaimerHtml = opts$disclaimerHtml,
    viewingHeading = viewing,
    breadcrumb = parts$breadcrumb,
    parentLink = parts$parentLink,
    rows = parts$rows,
    hostNote = opts$hostNote,
    timestamp = opts$timestamp
  ))

  attr(html, "nDirs") <- parts$nDirs
  attr(html, "nFiles") <- parts$nFiles
  html
}

# Build the page HTML for every directory level (incl. root "") implied by
# `allFiles`. Returns a list with `html` (a named character vector: names are
# directory paths, "" for root) plus the per-page `nDirs` / `nFiles` counts.
# (lapply is used rather than vapply so the per-page count attributes survive
# to be harvested before the HTML strings are flattened.)
buildIndexPages <- function(allFiles, template, opts) {
  allDirs <- sort(unique(c(
    "",
    unlist(lapply(allFiles$key, dirsForKey))
  )))
  built <- lapply(
    allDirs,
    buildPageHtml,
    allFiles = allFiles, template = template, opts = opts
  )
  html <- vapply(built, as.vector, character(1)) # drop attrs -> clean strings
  names(html) <- allDirs
  list(
    html = html,
    nDirs = vapply(built, function(x) attr(x, "nDirs"), integer(1)),
    nFiles = vapply(built, function(x) attr(x, "nFiles"), integer(1))
  )
}

# ---- exported: generate and upload indexes -------------------------------

#' Generate a browsable HTML catalogue for a bucket
#'
#' Lists every object in the bucket, then writes one `index.html` per
#' "directory" level (including the root) and uploads them back to the bucket
#' with `rclone`. The result is a static, dependency-free website: open
#' `<base_url>/index.html` in any browser to navigate the tree, sort columns,
#' and click through to files. Each page also carries a configurable
#' disclaimer/"hero" block so context follows users wherever they land.
#'
#' Re-run it whenever the bucket's contents change.
#'
#' @inheritParams bucketConfig
#' @param heading Text for the page `<h1>` and `<title>`. Defaults to the
#'   container name. Set this to your repository's display name.
#' @param disclaimerHtml Raw HTML inserted near the top of every page (the
#'   yellow "hero" block in the default template). Use it for provenance
#'   notes, citations, or links to authoritative sources. Default `""` (none).
#'   Can also be set via `options(buckethost.disclaimerHtml = ...)`.
#' @param hostNote One line shown in the footer describing where the data is
#'   hosted. Defaults via `options(buckethost.hostNote = ...)` or a generic
#'   string.
#' @param template Path to a custom HTML template. Defaults to the one shipped
#'   with the package (see `system.file("templates", "index.html", package =
#'   "buckethost")`). Templates use `{{token}}` placeholders; see Details.
#' @param allFiles Optional pre-fetched object table (as returned by
#'   [bucketLs()]). Supply it to avoid re-listing the bucket, or to index a
#'   subset. When `NULL` (default) the bucket is listed for you.
#' @param rclonePath Path to the `rclone` executable. Default `"rclone"`.
#' @param dryRun If `TRUE`, build the pages but do not upload them; the HTML
#'   is returned (invisibly) for inspection. Default `FALSE`.
#' @param quiet Suppress progress messages. Default `FALSE`.
#'
#' @details
#' ## Template placeholders
#' A custom `template` is a single HTML file in which these tokens are
#' substituted per page: `{{pageTitle}}`, `{{repoHeading}}`,
#' `{{disclaimerHtml}}`, `{{viewingHeading}}`, `{{breadcrumb}}`,
#' `{{parentLink}}`, `{{rows}}`, `{{hostNote}}`, and `{{timestamp}}`. The
#' shipped template provides sortable columns (vanilla JS, no dependencies)
#' with directories pinned to the top.
#'
#' @return Invisibly, a named character vector of the generated HTML pages
#'   (names are directory paths, `""` for the root).
#' @seealso [bucketLs()], [bucketUpload()]
#' @export
#' @examples
#' \dontrun{
#' options(
#'   buckethost.endpoint  = "https://object-arbutus.cloud.computecanada.ca",
#'   buckethost.container = "predictiveecology",
#'   buckethost.remote    = "arbutus"
#' )
#' generateIndexes(
#'   heading = "PredictiveEcology Temporary Data Repository",
#'   disclaimerHtml = paste0(
#'     "<div class='hero'><p><strong>These data are not produced by the ",
#'     "PredictiveEcology group</strong> and are only hosted here to ease ",
#'     "open data access.</p></div>"
#'   ),
#'   hostNote = paste0("Hosted on the Digital Research Alliance of Canada's ",
#'                      "Arbutus object storage.")
#' )
#' }
generateIndexes <- function(container = NULL,
                             endpoint = NULL,
                             remote = NULL,
                             heading = NULL,
                             disclaimerHtml = getOption("buckethost.disclaimerHtml", ""),
                             hostNote = getOption(
                               "buckethost.hostNote",
                               "Hosted on an S3-compatible object store."
                             ),
                             template = NULL,
                             allFiles = NULL,
                             rclonePath = "rclone",
                             dryRun = FALSE,
                             quiet = FALSE) {
  container <- bucketContainer(container)
  base_url <- bucketBaseUrl(container, endpoint)
  rcloneRemote <- bucketRcloneRemote(container, remote)
  if (is.null(heading)) heading <- container

  tmpl <- paste(readLines(templatePath(template), warn = FALSE), collapse = "\n")

  if (is.null(allFiles)) {
    allFiles <- bucketLs(container = container, endpoint = endpoint)
  }
  if (!quiet) message(sprintf("Indexing %d objects...", nrow(allFiles)))

  opts <- list(
    heading = heading,
    disclaimerHtml = disclaimerHtml,
    hostNote = hostNote,
    rootLabel = container,
    timestamp = format(Sys.time(), "%Y-%m-%d %H:%M %Z")
  )

  built <- buildIndexPages(allFiles, tmpl, opts)
  pages <- built$html

  if (dryRun) {
    if (!quiet) message("dryRun = TRUE: built ", length(pages), " pages (not uploaded).")
    return(invisible(pages))
  }

  requireRclone(rclonePath)
  dirs <- names(pages)
  # Index by position, not name: the root directory's name is "" and
  # `pages[[""]]` is a subscript-out-of-bounds error in R.
  for (i in seq_along(pages)) {
    dir <- dirs[i]
    html <- pages[[i]]
    tmpfile <- tempfile(fileext = ".html")
    writeLines(html, tmpfile)
    on.exit(unlink(tmpfile), add = TRUE)

    destKey <- if (nzchar(dir)) paste0(dir, "/index.html") else "index.html"
    dest <- sprintf("%s/%s", rcloneRemote, destKey)

    res <- tryCatch(
      {
        rclone(c("copyto", tmpfile, dest), path = rclonePath)
        TRUE
      },
      error = function(e) {
        if (!quiet) message(sprintf("  Failed: %s/  (%s)", dir, conditionMessage(e)))
        FALSE
      }
    )
    unlink(tmpfile)
    if (res && !quiet) {
      message(sprintf(
        "  Indexed: %s/  (%d dirs, %d files)",
        dir, built$nDirs[i], built$nFiles[i]
      ))
    }
  }

  invisible(pages)
}
