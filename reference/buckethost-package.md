# buckethost: Host and Catalogue Files on S3-Compatible Object Storage

`buckethost` turns any S3-compatible bucket into a browsable, remotely
readable data repository. It has three jobs:

## Details

- Discover:

  [`bucketLs()`](https://predictiveecology.github.io/buckethost/reference/bucketLs.md)
  lists objects via the bucket's public S3 listing API;
  [`bucketUrl()`](https://predictiveecology.github.io/buckethost/reference/bucketUrl.md)
  and
  [`bucketRaster()`](https://predictiveecology.github.io/buckethost/reference/bucketRaster.md)
  build the HTTPS / `/vsicurl/` URLs you read from.

- Mutate:

  [`bucketUpload()`](https://predictiveecology.github.io/buckethost/reference/bucketUpload.md)
  and
  [`bucketDelete()`](https://predictiveecology.github.io/buckethost/reference/bucketDelete.md)
  wrap `rclone` so transfers are robust and failures are loud.

- Maintain:

  [`generateIndexes()`](https://predictiveecology.github.io/buckethost/reference/generateIndexes.md)
  writes a static `index.html` for every "folder" in the bucket so it
  can be browsed in a web browser;
  [`bucketVerify()`](https://predictiveecology.github.io/buckethost/reference/bucketVerify.md)
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
[bucketConfig](https://predictiveecology.github.io/buckethost/reference/bucketConfig.md).

## See also

Useful links:

- <https://github.com/PredictiveEcology/buckethost>

- <https://predictiveecology.github.io/buckethost/>

- Report bugs at
  <https://github.com/PredictiveEcology/buckethost/issues>

## Author

**Maintainer**: Eliot McIntire <eliotmcintire@gmail.com>

Authors:

- Eliot McIntire <eliotmcintire@gmail.com>

Other contributors:

- PredictiveEcology \[copyright holder, funder\]
