# buckethost 0.2.0

* `makeMirrorManifest()` now matches Google Drive files by **path relative to
  `driveFolder`** (e.g. `1985/age.tif`), not bare file name. Identical names
  under different folders (`1985/age.tif` vs `1990/age.tif`) now resolve to
  distinct Drive ids. Drive paths are reconstructed from each item's parent
  chain; if a listing lacks parent info the function falls back to file-name
  matching and warns.
* `bucketUpload()` now uses `rclone copyto` for a single **file** (so it lands
  at exactly the destination key) and `rclone copy` for a **directory**.
  Previously a single file was always sent with `copy`, which nests it as
  `remotePath/filename` rather than placing it at `remotePath`.
* `bucketUpload()`, `bucketDelete()`, and `bucketVerify()` now trim surrounding
  whitespace from path arguments and raise a clear error if a path contains an
  embedded newline or control character (a stray line break otherwise produces
  a baffling shell/rclone failure). `bucketUpload()` also checks that `local`
  exists before invoking rclone.

# buckethost 0.1.0

## Breaking changes

* All functions and multi-word arguments are now **camelCase**, to match the
  PredictiveEcology package family. Renames: `generate_indexes()` ->
  `generateIndexes()`, `bucket_ls()` -> `bucketLs()`, `bucket_url()` ->
  `bucketUrl()`, `bucket_raster()` -> `bucketRaster()`, `bucket_upload()` ->
  `bucketUpload()`, `bucket_delete()` -> `bucketDelete()`, `bucket_verify()`
  -> `bucketVerify()`, `bucket_endpoint()` -> `bucketEndpoint()`,
  `bucket_container()` -> `bucketContainer()`, `bucket_remote()` ->
  `bucketRemote()`, `bucket_base_url()` -> `bucketBaseUrl()`,
  `bucket_rclone_remote()` -> `bucketRcloneRemote()`. Arguments likewise (e.g.
  `dry_run` -> `dryRun`, `rclone_path` -> `rclonePath`, `filter_file` ->
  `filterFile`, `remote_path` -> `remotePath`, `disclaimer_html` ->
  `disclaimerHtml`, `host_note` -> `hostNote`, `all_files` -> `allFiles`).
  Options follow: `buckethost.disclaimerHtml`, `buckethost.hostNote`.

## Improvements

* `bucketUpload()`, `bucketDelete()`, and `bucketVerify()` now accept a full
  public URL as `remotePath` and normalise it to the object key. Previously
  passing e.g. `"https://endpoint/container/SCANFI_v2/x.csv"` uploaded the file
  to a bogus nested key (the URL embedded under the bucket) instead of
  `"SCANFI_v2/x.csv"`.

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
