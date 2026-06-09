# Generate a browsable HTML catalogue for a bucket

Lists every object in the bucket, then writes one `index.html` per
"directory" level (including the root) and uploads them back to the
bucket with `rclone`. The result is a static, dependency-free website:
open `<base_url>/index.html` in any browser to navigate the tree, sort
columns, and click through to files. Each page also carries a
configurable disclaimer/"hero" block so context follows users wherever
they land.

## Usage

``` r
generate_indexes(
  container = NULL,
  endpoint = NULL,
  remote = NULL,
  heading = NULL,
  disclaimer_html = getOption("buckethost.disclaimer_html", ""),
  host_note = getOption("buckethost.host_note",
    "Hosted on an S3-compatible object store."),
  template = NULL,
  all_files = NULL,
  rclone_path = "rclone",
  dry_run = FALSE,
  quiet = FALSE
)
```

## Arguments

- container:

  The bucket (container) name. When `NULL` (the default), resolved from
  `options(buckethost.container=)`, then `BUCKETHOST_CONTAINER`, then a
  built-in default.

- endpoint:

  The object store's HTTPS host (no bucket name). When `NULL`, resolved
  from `options(buckethost.endpoint=)`, then `BUCKETHOST_ENDPOINT`, then
  a built-in default.

- remote:

  The name of your local `rclone` remote. When `NULL`, resolved from
  `options(buckethost.remote=)`, then `BUCKETHOST_REMOTE`, then a
  built-in default.

- heading:

  Text for the page `<h1>` and `<title>`. Defaults to the container
  name. Set this to your repository's display name.

- disclaimer_html:

  Raw HTML inserted near the top of every page (the yellow "hero" block
  in the default template). Use it for provenance notes, citations, or
  links to authoritative sources. Default `""` (none). Can also be set
  via `options(buckethost.disclaimer_html = ...)`.

- host_note:

  One line shown in the footer describing where the data is hosted.
  Defaults via `options(buckethost.host_note = ...)` or a generic
  string.

- template:

  Path to a custom HTML template. Defaults to the one shipped with the
  package (see
  `system.file("templates", "index.html", package = "buckethost")`).
  Templates use `{{token}}` placeholders; see Details.

- all_files:

  Optional pre-fetched object table (as returned by
  [`bucket_ls()`](https://predictiveecology.github.io/buckethost/reference/bucket_ls.md)).
  Supply it to avoid re-listing the bucket, or to index a subset. When
  `NULL` (default) the bucket is listed for you.

- rclone_path:

  Path to the `rclone` executable. Default `"rclone"`.

- dry_run:

  If `TRUE`, build the pages but do not upload them; the HTML is
  returned (invisibly) for inspection. Default `FALSE`.

- quiet:

  Suppress progress messages. Default `FALSE`.

## Value

Invisibly, a named character vector of the generated HTML pages (names
are directory paths, `""` for the root).

## Details

Re-run it whenever the bucket's contents change.

### Template placeholders

A custom `template` is a single HTML file in which these tokens are
substituted per page: `{{page_title}}`, `{{repo_heading}}`,
`{{disclaimer_html}}`, `{{viewing_heading}}`, `{{breadcrumb}}`,
`{{parent_link}}`, `{{rows}}`, `{{host_note}}`, and `{{timestamp}}`. The
shipped template provides sortable columns (vanilla JS, no dependencies)
with directories pinned to the top.

## See also

[`bucket_ls()`](https://predictiveecology.github.io/buckethost/reference/bucket_ls.md),
[`bucket_upload()`](https://predictiveecology.github.io/buckethost/reference/bucket_upload.md)

## Examples

``` r
if (FALSE) { # \dontrun{
options(
  buckethost.endpoint  = "https://object-arbutus.cloud.computecanada.ca",
  buckethost.container = "predictiveecology",
  buckethost.remote    = "arbutus"
)
generate_indexes(
  heading = "PredictiveEcology Temporary Data Repository",
  disclaimer_html = paste0(
    "<div class='hero'><p><strong>These data are not produced by the ",
    "PredictiveEcology group</strong> and are only hosted here to ease ",
    "open data access.</p></div>"
  ),
  host_note = paste0("Hosted on the Digital Research Alliance of Canada's ",
                     "Arbutus object storage.")
)
} # }
```
