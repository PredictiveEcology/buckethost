# buckethost 0.0.3

* New `makeMirrorManifest()`: builds a "remap" `data.frame` (one row per
  object: `filename`, `key`, `url`), optionally adds a Google Drive `id`
  column matched by file name, and optionally writes the table to CSV. Warns
  when duplicate file names make the Drive match ambiguous. `googledrive`
  moves to Suggests.

# buckethost 0.0.2

* Fix `generate_indexes()` erroring with "subscript out of bounds" when
  actually uploading (not `dry_run`): the upload loop indexed pages by name,
  but the root directory's name is `""` and `pages[[""]]` is an error in R. It
  now indexes positionally. Added a regression test that exercises the full
  upload loop, including the root page, with `rclone` stubbed out.
* `generate_indexes()` progress messages now report the correct per-folder
  dir/file counts (previously lost because `vapply()` stripped the count
  attributes).

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
