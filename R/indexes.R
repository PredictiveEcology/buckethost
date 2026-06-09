# ---- internal: build the HTML for one directory level --------------------

# Construct the breadcrumb / parent-link / row HTML for a single directory
# `dir` ("" is the root) given the full object table `all_files`.
# Returns a list of the pieces the template needs.
build_page_parts <- function(dir, all_files, root_label) {
  prefix <- if (nzchar(dir)) paste0(dir, "/") else ""
  depth <- if (nzchar(dir)) {
    length(strsplit(dir, "/", fixed = TRUE)[[1]])
  } else {
    0L
  }

  is_desc <- startsWith(all_files$key, prefix)
  rel <- substring(all_files$key[is_desc], nchar(prefix) + 1L)
  rel_size <- all_files$size[is_desc]

  is_in_subdir <- grepl("/", rel, fixed = TRUE)

  # Immediate files, sorted by name.
  f_name <- rel[!is_in_subdir]
  f_size <- rel_size[!is_in_subdir]
  ord <- order(f_name)
  f_name <- f_name[ord]
  f_size <- f_size[ord]

  # Immediate subdirectories.
  subdirs <- if (any(is_in_subdir)) {
    sort(unique(sub("/.*$", "", rel[is_in_subdir])))
  } else {
    character(0)
  }

  # Breadcrumb: root link + one clickable link per path component.
  root_link <- sprintf(
    "<a href='%s./index.html'>%s</a>",
    paste(rep("../", depth), collapse = ""),
    html_escape(root_label)
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
      sprintf("<a href='%s'>%s</a>", href, html_escape(parts[i]))
    }, character(1))
  } else {
    character(0)
  }
  breadcrumb <- paste(c(root_link, crumbs), collapse = " / ")

  parent_link <- if (nzchar(dir)) {
    "<p><a href='../index.html'>\u2B06 Parent directory</a></p>"
  } else {
    ""
  }

  # Rows. Directories carry no size and always sort to the top (the client
  # JS keeps them grouped); files carry data-size for numeric sorting.
  dir_rows <- if (length(subdirs) > 0) {
    sprintf(
      "<tr class='dir'><td><a href='%s/index.html'>%s/</a></td><td></td></tr>",
      subdirs, html_escape(subdirs)
    )
  } else {
    character(0)
  }
  file_rows <- if (length(f_name) > 0) {
    sprintf(
      paste0(
        "<tr class='file' data-size='%.0f'>",
        "<td><a href='%s'>%s</a></td>",
        "<td style='text-align:right'>%s</td></tr>"
      ),
      f_size, f_name, html_escape(f_name), format_size(f_size)
    )
  } else {
    character(0)
  }

  list(
    breadcrumb = breadcrumb,
    parent_link = parent_link,
    rows = paste(c(dir_rows, file_rows), collapse = "\n"),
    n_dirs = length(subdirs),
    n_files = length(f_name)
  )
}

# Render the full HTML page for one directory.
build_page_html <- function(dir, all_files, template, opts) {
  parts <- build_page_parts(dir, all_files, opts$root_label)

  viewing <- if (nzchar(dir)) {
    sprintf("Currently viewing: <code>%s</code>", html_escape(dir))
  } else {
    "Repository contents"
  }
  page_title <- if (nzchar(dir)) {
    paste0(html_escape(dir), " \u2014 ", html_escape(opts$heading))
  } else {
    html_escape(opts$heading)
  }

  html <- render_template(template, list(
    page_title = page_title,
    repo_heading = html_escape(opts$heading),
    disclaimer_html = opts$disclaimer_html,
    viewing_heading = viewing,
    breadcrumb = parts$breadcrumb,
    parent_link = parts$parent_link,
    rows = parts$rows,
    host_note = opts$host_note,
    timestamp = opts$timestamp
  ))

  attr(html, "n_dirs") <- parts$n_dirs
  attr(html, "n_files") <- parts$n_files
  html
}

# Build the page HTML for every directory level (incl. root "") implied by
# `all_files`. Returns a named character vector: names are directory paths
# ("" for root), values are full HTML documents.
build_index_pages <- function(all_files, template, opts) {
  all_dirs <- sort(unique(c(
    "",
    unlist(lapply(all_files$key, dirs_for_key))
  )))
  pages <- vapply(
    all_dirs,
    function(d) build_page_html(d, all_files, template, opts),
    character(1)
  )
  names(pages) <- all_dirs
  pages
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
#' @inheritParams bucket_config
#' @param heading Text for the page `<h1>` and `<title>`. Defaults to the
#'   container name. Set this to your repository's display name.
#' @param disclaimer_html Raw HTML inserted near the top of every page (the
#'   yellow "hero" block in the default template). Use it for provenance
#'   notes, citations, or links to authoritative sources. Default `""` (none).
#'   Can also be set via `options(buckethost.disclaimer_html = ...)`.
#' @param host_note One line shown in the footer describing where the data is
#'   hosted. Defaults via `options(buckethost.host_note = ...)` or a generic
#'   string.
#' @param template Path to a custom HTML template. Defaults to the one shipped
#'   with the package (see `system.file("templates", "index.html", package =
#'   "buckethost")`). Templates use `{{token}}` placeholders; see Details.
#' @param all_files Optional pre-fetched object table (as returned by
#'   [bucket_ls()]). Supply it to avoid re-listing the bucket, or to index a
#'   subset. When `NULL` (default) the bucket is listed for you.
#' @param rclone_path Path to the `rclone` executable. Default `"rclone"`.
#' @param dry_run If `TRUE`, build the pages but do not upload them; the HTML
#'   is returned (invisibly) for inspection. Default `FALSE`.
#' @param quiet Suppress progress messages. Default `FALSE`.
#'
#' @details
#' ## Template placeholders
#' A custom `template` is a single HTML file in which these tokens are
#' substituted per page: `{{page_title}}`, `{{repo_heading}}`,
#' `{{disclaimer_html}}`, `{{viewing_heading}}`, `{{breadcrumb}}`,
#' `{{parent_link}}`, `{{rows}}`, `{{host_note}}`, and `{{timestamp}}`. The
#' shipped template provides sortable columns (vanilla JS, no dependencies)
#' with directories pinned to the top.
#'
#' @return Invisibly, a named character vector of the generated HTML pages
#'   (names are directory paths, `""` for the root).
#' @seealso [bucket_ls()], [bucket_upload()]
#' @export
#' @examples
#' \dontrun{
#' options(
#'   buckethost.endpoint  = "https://object-arbutus.cloud.computecanada.ca",
#'   buckethost.container = "predictiveecology",
#'   buckethost.remote    = "arbutus"
#' )
#' generate_indexes(
#'   heading = "PredictiveEcology Temporary Data Repository",
#'   disclaimer_html = paste0(
#'     "<div class='hero'><p><strong>These data are not produced by the ",
#'     "PredictiveEcology group</strong> and are only hosted here to ease ",
#'     "open data access.</p></div>"
#'   ),
#'   host_note = paste0("Hosted on the Digital Research Alliance of Canada's ",
#'                      "Arbutus object storage.")
#' )
#' }
generate_indexes <- function(container = NULL,
                             endpoint = NULL,
                             remote = NULL,
                             heading = NULL,
                             disclaimer_html = getOption("buckethost.disclaimer_html", ""),
                             host_note = getOption(
                               "buckethost.host_note",
                               "Hosted on an S3-compatible object store."
                             ),
                             template = NULL,
                             all_files = NULL,
                             rclone_path = "rclone",
                             dry_run = FALSE,
                             quiet = FALSE) {
  container <- bucket_container(container)
  base_url <- bucket_base_url(container, endpoint)
  rclone_remote <- bucket_rclone_remote(container, remote)
  if (is.null(heading)) heading <- container

  tmpl <- paste(readLines(template_path(template), warn = FALSE), collapse = "\n")

  if (is.null(all_files)) {
    all_files <- bucket_ls(container = container, endpoint = endpoint)
  }
  if (!quiet) message(sprintf("Indexing %d objects...", nrow(all_files)))

  opts <- list(
    heading = heading,
    disclaimer_html = disclaimer_html,
    host_note = host_note,
    root_label = container,
    timestamp = format(Sys.time(), "%Y-%m-%d %H:%M %Z")
  )

  pages <- build_index_pages(all_files, tmpl, opts)

  if (dry_run) {
    if (!quiet) message("dry_run = TRUE: built ", length(pages), " pages (not uploaded).")
    return(invisible(pages))
  }

  require_rclone(rclone_path)
  for (dir in names(pages)) {
    html <- pages[[dir]]
    tmpfile <- tempfile(fileext = ".html")
    writeLines(html, tmpfile)
    on.exit(unlink(tmpfile), add = TRUE)

    dest_key <- if (nzchar(dir)) paste0(dir, "/index.html") else "index.html"
    dest <- sprintf("%s/%s", rclone_remote, dest_key)

    res <- tryCatch(
      {
        rclone(c("copyto", tmpfile, dest), path = rclone_path)
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
        dir, attr(html, "n_dirs"), attr(html, "n_files")
      ))
    }
  }

  invisible(pages)
}
