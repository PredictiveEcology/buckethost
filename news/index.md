# Changelog

## buckethost 0.1.0

### Breaking changes

- All functions and multi-word arguments are now **camelCase**, to match
  the PredictiveEcology package family. Renames: `generate_indexes()`
  -\>
  [`generateIndexes()`](https://predictiveecology.github.io/buckethost/reference/generateIndexes.md),
  `bucket_ls()` -\>
  [`bucketLs()`](https://predictiveecology.github.io/buckethost/reference/bucketLs.md),
  `bucket_url()` -\>
  [`bucketUrl()`](https://predictiveecology.github.io/buckethost/reference/bucketUrl.md),
  `bucket_raster()` -\>
  [`bucketRaster()`](https://predictiveecology.github.io/buckethost/reference/bucketRaster.md),
  `bucket_upload()` -\>
  [`bucketUpload()`](https://predictiveecology.github.io/buckethost/reference/bucketUpload.md),
  `bucket_delete()` -\>
  [`bucketDelete()`](https://predictiveecology.github.io/buckethost/reference/bucketDelete.md),
  `bucket_verify()` -\>
  [`bucketVerify()`](https://predictiveecology.github.io/buckethost/reference/bucketVerify.md),
  `bucket_endpoint()` -\>
  [`bucketEndpoint()`](https://predictiveecology.github.io/buckethost/reference/bucketConfig.md),
  `bucket_container()` -\>
  [`bucketContainer()`](https://predictiveecology.github.io/buckethost/reference/bucketConfig.md),
  `bucket_remote()` -\>
  [`bucketRemote()`](https://predictiveecology.github.io/buckethost/reference/bucketConfig.md),
  `bucket_base_url()` -\>
  [`bucketBaseUrl()`](https://predictiveecology.github.io/buckethost/reference/bucketConfig.md),
  `bucket_rclone_remote()` -\>
  [`bucketRcloneRemote()`](https://predictiveecology.github.io/buckethost/reference/bucketConfig.md).
  Arguments likewise (e.g. `dry_run` -\> `dryRun`, `rclone_path` -\>
  `rclonePath`, `filter_file` -\> `filterFile`, `remote_path` -\>
  `remotePath`, `disclaimer_html` -\> `disclaimerHtml`, `host_note` -\>
  `hostNote`, `all_files` -\> `allFiles`). Options follow:
  `buckethost.disclaimerHtml`, `buckethost.hostNote`.

### Improvements

- [`bucketUpload()`](https://predictiveecology.github.io/buckethost/reference/bucketUpload.md),
  [`bucketDelete()`](https://predictiveecology.github.io/buckethost/reference/bucketDelete.md),
  and
  [`bucketVerify()`](https://predictiveecology.github.io/buckethost/reference/bucketVerify.md)
  now accept a full public URL as `remotePath` and normalise it to the
  object key. Previously passing
  e.g. `"https://endpoint/container/SCANFI_v2/x.csv"` uploaded the file
  to a bogus nested key (the URL embedded under the bucket) instead of
  `"SCANFI_v2/x.csv"`.

## buckethost 0.0.3

- New
  [`makeMirrorManifest()`](https://predictiveecology.github.io/buckethost/reference/makeMirrorManifest.md):
  builds a “remap” `data.frame` (one row per object: `filename`, `key`,
  `url`), optionally adds a Google Drive `id` column matched by file
  name, and optionally writes the table to CSV. Warns when duplicate
  file names make the Drive match ambiguous. `googledrive` moves to
  Suggests.

## buckethost 0.0.2

- Fix `generate_indexes()` erroring with “subscript out of bounds” when
  actually uploading (not `dry_run`): the upload loop indexed pages by
  name, but the root directory’s name is `""` and `pages[[""]]` is an
  error in R. It now indexes positionally. Added a regression test that
  exercises the full upload loop, including the root page, with `rclone`
  stubbed out.
- `generate_indexes()` progress messages now report the correct
  per-folder dir/file counts (previously lost because
  [`vapply()`](https://rdrr.io/r/base/lapply.html) stripped the count
  attributes).

## buckethost 0.0.1

- Initial release.
- `generate_indexes()` writes a browsable, sortable static HTML
  catalogue (one `index.html` per folder level) for an S3-compatible
  bucket and uploads it via `rclone`. The HTML template is externalised
  to `inst/templates/index.html` with `{{token}}` placeholders, and the
  page heading, disclaimer/“hero” block, and footer note are all
  configurable.
- Discovery helpers: `bucket_ls()`, `bucket_url()`, `bucket_raster()`.
- Mutation helpers (rclone wrappers that fail loudly):
  `bucket_upload()`, `bucket_delete()`.
- Maintenance: `bucket_verify()`.
- Connection configuration via options / `BUCKETHOST_*` environment
  variables: `bucket_endpoint()`, `bucket_container()`,
  `bucket_remote()`, `bucket_base_url()`, `bucket_rclone_remote()`.
- Vignettes: “Getting started” and “Migrating data to an object store
  (the Arbutus recipe)”.
