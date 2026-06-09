# Changelog

## buckethost 0.0.1

- Initial release.
- [`generate_indexes()`](https://predictiveecology.github.io/buckethost/reference/generate_indexes.md)
  writes a browsable, sortable static HTML catalogue (one `index.html`
  per folder level) for an S3-compatible bucket and uploads it via
  `rclone`. The HTML template is externalised to
  `inst/templates/index.html` with `{{token}}` placeholders, and the
  page heading, disclaimer/“hero” block, and footer note are all
  configurable.
- Discovery helpers:
  [`bucket_ls()`](https://predictiveecology.github.io/buckethost/reference/bucket_ls.md),
  [`bucket_url()`](https://predictiveecology.github.io/buckethost/reference/bucket_url.md),
  [`bucket_raster()`](https://predictiveecology.github.io/buckethost/reference/bucket_raster.md).
- Mutation helpers (rclone wrappers that fail loudly):
  [`bucket_upload()`](https://predictiveecology.github.io/buckethost/reference/bucket_upload.md),
  [`bucket_delete()`](https://predictiveecology.github.io/buckethost/reference/bucket_delete.md).
- Maintenance:
  [`bucket_verify()`](https://predictiveecology.github.io/buckethost/reference/bucket_verify.md).
- Connection configuration via options / `BUCKETHOST_*` environment
  variables:
  [`bucket_endpoint()`](https://predictiveecology.github.io/buckethost/reference/bucket_config.md),
  [`bucket_container()`](https://predictiveecology.github.io/buckethost/reference/bucket_config.md),
  [`bucket_remote()`](https://predictiveecology.github.io/buckethost/reference/bucket_config.md),
  [`bucket_base_url()`](https://predictiveecology.github.io/buckethost/reference/bucket_config.md),
  [`bucket_rclone_remote()`](https://predictiveecology.github.io/buckethost/reference/bucket_config.md).
- Vignettes: “Getting started” and “Migrating data to an object store
  (the Arbutus recipe)”.
