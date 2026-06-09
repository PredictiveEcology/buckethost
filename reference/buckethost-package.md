# buckethost: Host and Catalogue Files on S3-Compatible Object Storage

`buckethost` turns any S3-compatible bucket into a browsable, remotely
readable data repository. It has three jobs:

## Details

- Discover:

  [`bucket_ls()`](https://predictiveecology.github.io/buckethost/reference/bucket_ls.md)
  lists objects via the bucket's public S3 listing API;
  [`bucket_url()`](https://predictiveecology.github.io/buckethost/reference/bucket_url.md)
  and
  [`bucket_raster()`](https://predictiveecology.github.io/buckethost/reference/bucket_raster.md)
  build the HTTPS / `/vsicurl/` URLs you read from.

- Mutate:

  [`bucket_upload()`](https://predictiveecology.github.io/buckethost/reference/bucket_upload.md)
  and
  [`bucket_delete()`](https://predictiveecology.github.io/buckethost/reference/bucket_delete.md)
  wrap `rclone` so transfers are robust and failures are loud.

- Maintain:

  [`generate_indexes()`](https://predictiveecology.github.io/buckethost/reference/generate_indexes.md)
  writes a static `index.html` for every "folder" in the bucket so it
  can be browsed in a web browser;
  [`bucket_verify()`](https://predictiveecology.github.io/buckethost/reference/bucket_verify.md)
  checks a local tree against the remote.

## Configuration

Most functions default their connection details from options (falling
back to environment variables), so you set them once per session and
omit them everywhere after:


    options(
      buckethost.endpoint  = "https://object-arbutus.cloud.computecanada.ca",
      buckethost.container = "predictiveecology",
      buckethost.remote    = "arbutus"   # the name of your rclone remote
    )

The equivalent environment variables are `BUCKETHOST_ENDPOINT`,
`BUCKETHOST_CONTAINER`, and `BUCKETHOST_REMOTE`. See
[bucket_config](https://predictiveecology.github.io/buckethost/reference/bucket_config.md).

## See also

Useful links:

- <https://github.com/PredictiveEcology/buckethost>

- Report bugs at
  <https://github.com/PredictiveEcology/buckethost/issues>

## Author

**Maintainer**: Eliot McIntire <eliotmcintire@gmail.com>

Authors:

- Eliot McIntire <eliotmcintire@gmail.com>

Other contributors:

- PredictiveEcology \[copyright holder, funder\]
