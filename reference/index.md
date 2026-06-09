# Package index

## Discover

Find what’s in a bucket and build the URLs you read from.

- [`bucket_ls()`](https://predictiveecology.github.io/buckethost/reference/bucket_ls.md)
  : List objects in a bucket

- [`bucket_url()`](https://predictiveecology.github.io/buckethost/reference/bucket_url.md)
  : Build the public URL for an object

- [`bucket_raster()`](https://predictiveecology.github.io/buckethost/reference/bucket_raster.md)
  :

  Read a remote raster via GDAL `/vsicurl/`

## Mutate

Upload to and delete from a bucket. Thin, loud wrappers around rclone.

- [`bucket_upload()`](https://predictiveecology.github.io/buckethost/reference/bucket_upload.md)
  : Upload files to a bucket
- [`bucket_delete()`](https://predictiveecology.github.io/buckethost/reference/bucket_delete.md)
  : Delete an object or prefix from a bucket

## Maintain

Generate the browsable HTML catalogue and check integrity.

- [`generate_indexes()`](https://predictiveecology.github.io/buckethost/reference/generate_indexes.md)
  : Generate a browsable HTML catalogue for a bucket
- [`bucket_verify()`](https://predictiveecology.github.io/buckethost/reference/bucket_verify.md)
  : Verify a local tree against the bucket

## Configuration

Resolve connection details from options / environment variables.

- [`bucket_endpoint()`](https://predictiveecology.github.io/buckethost/reference/bucket_config.md)
  [`bucket_container()`](https://predictiveecology.github.io/buckethost/reference/bucket_config.md)
  [`bucket_remote()`](https://predictiveecology.github.io/buckethost/reference/bucket_config.md)
  [`bucket_base_url()`](https://predictiveecology.github.io/buckethost/reference/bucket_config.md)
  [`bucket_rclone_remote()`](https://predictiveecology.github.io/buckethost/reference/bucket_config.md)
  : Connection configuration

## Package

- [`buckethost`](https://predictiveecology.github.io/buckethost/reference/buckethost-package.md)
  [`buckethost-package`](https://predictiveecology.github.io/buckethost/reference/buckethost-package.md)
  : buckethost: Host and Catalogue Files on S3-Compatible Object Storage
