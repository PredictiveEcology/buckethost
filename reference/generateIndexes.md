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
generateIndexes(
  container = NULL,
  endpoint = NULL,
  remote = NULL,
  heading = NULL,
  disclaimerHtml = getOption("buckethost.disclaimerHtml", ""),
  hostNote = getOption("buckethost.hostNote", "Hosted on an S3-compatible object store."),
  template = NULL,
  allFiles = NULL,
  rclonePath = "rclone",
  dryRun = FALSE,
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

- disclaimerHtml:

  Raw HTML inserted near the top of every page (the yellow "hero" block
  in the default template). Use it for provenance notes, citations, or
  links to authoritative sources. Default `""` (none). Can also be set
  via `options(buckethost.disclaimerHtml = ...)`.

- hostNote:

  One line shown in the footer describing where the data is hosted.
  Defaults via `options(buckethost.hostNote = ...)` or a generic string.

- template:

  Path to a custom HTML template. Defaults to the one shipped with the
  package (see
  `system.file("templates", "index.html", package = "buckethost")`).
  Templates use `{{token}}` placeholders; see Details.

- allFiles:

  Optional pre-fetched object table (as returned by
  [`bucketLs()`](https://predictiveecology.github.io/buckethost/reference/bucketLs.md)).
  Supply it to avoid re-listing the bucket, or to index a subset. When
  `NULL` (default) the bucket is listed for you.

- rclonePath:

  Path to the `rclone` executable. Default `"rclone"`.

- dryRun:

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
substituted per page: `{{pageTitle}}`, `{{repoHeading}}`,
`{{disclaimerHtml}}`, `{{viewingHeading}}`, `{{breadcrumb}}`,
`{{parentLink}}`, `{{rows}}`, `{{hostNote}}`, and `{{timestamp}}`. The
shipped template provides sortable columns (vanilla JS, no dependencies)
with directories pinned to the top.

## See also

[`bucketLs()`](https://predictiveecology.github.io/buckethost/reference/bucketLs.md),
[`bucketUpload()`](https://predictiveecology.github.io/buckethost/reference/bucketUpload.md)

## Examples

``` r
if (FALSE) { # \dontrun{
options(
  buckethost.endpoint  = "https://object-arbutus.cloud.computecanada.ca",
  buckethost.container = "predictiveecology",
  buckethost.remote    = "arbutus"
)
generateIndexes(
  heading = "PredictiveEcology Temporary Data Repository",
  disclaimerHtml = paste0(
    "<div class='hero'><p><strong>These data are not produced by the ",
    "PredictiveEcology group</strong> and are only hosted here to ease ",
    "open data access.</p></div>"
  ),
  hostNote = paste0("Hosted on the Digital Research Alliance of Canada's ",
                     "Arbutus object storage.")
)
} # }
```
