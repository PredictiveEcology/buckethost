# buckethost 0.0.1

* Initial release.
* `generate_indexes()` writes a browsable, sortable static HTML catalogue
  (one `index.html` per folder level) for an S3-compatible bucket and uploads
  it via `rclone`. The HTML template is externalised to
  `inst/templates/index.html` with `{{token}}` placeholders, and the page
  heading, disclaimer/"hero" block, and footer note are all configurable.
* Discovery helpers: `bucket_ls()`, `bucket_url()`, `bucket_raster()`.
* Mutation helpers (rclone wrappers that fail loudly): `bucket_upload()`,
  `bucket_delete()`.
* Maintenance: `bucket_verify()`.
* Connection configuration via options / `BUCKETHOST_*` environment variables:
  `bucket_endpoint()`, `bucket_container()`, `bucket_remote()`,
  `bucket_base_url()`, `bucket_rclone_remote()`.
* Vignettes: "Getting started" and "Migrating data to an object store (the
  Arbutus recipe)".
