# Package index

## Discover

Find what’s in a bucket and build the URLs you read from.

- [`bucketLs()`](https://predictiveecology.github.io/buckethost/reference/bucketLs.md)
  : List objects in a bucket

- [`bucketUrl()`](https://predictiveecology.github.io/buckethost/reference/bucketUrl.md)
  : Build the public URL for an object

- [`bucketRaster()`](https://predictiveecology.github.io/buckethost/reference/bucketRaster.md)
  :

  Read a remote raster via GDAL `/vsicurl/`

## Mutate

Upload to and delete from a bucket. Thin, loud wrappers around rclone.

- [`bucketUpload()`](https://predictiveecology.github.io/buckethost/reference/bucketUpload.md)
  : Upload files to a bucket
- [`bucketDelete()`](https://predictiveecology.github.io/buckethost/reference/bucketDelete.md)
  : Delete an object or prefix from a bucket

## Maintain

Generate the browsable HTML catalogue and check integrity.

- [`generateIndexes()`](https://predictiveecology.github.io/buckethost/reference/generateIndexes.md)
  : Generate a browsable HTML catalogue for a bucket
- [`bucketVerify()`](https://predictiveecology.github.io/buckethost/reference/bucketVerify.md)
  : Verify a local tree against the bucket

## Mirror

Map a bucket’s contents (and optional Google Drive source) to a
manifest.

- [`makeMirrorManifest()`](https://predictiveecology.github.io/buckethost/reference/makeMirrorManifest.md)
  : Build a mirror manifest for a bucket

## Configuration

Resolve connection details from options / environment variables.

- [`bucketEndpoint()`](https://predictiveecology.github.io/buckethost/reference/bucketConfig.md)
  [`bucketContainer()`](https://predictiveecology.github.io/buckethost/reference/bucketConfig.md)
  [`bucketRemote()`](https://predictiveecology.github.io/buckethost/reference/bucketConfig.md)
  [`bucketBaseUrl()`](https://predictiveecology.github.io/buckethost/reference/bucketConfig.md)
  [`bucketRcloneRemote()`](https://predictiveecology.github.io/buckethost/reference/bucketConfig.md)
  : Connection configuration

## Package

- [`buckethost`](https://predictiveecology.github.io/buckethost/reference/buckethost-package.md)
  [`buckethost-package`](https://predictiveecology.github.io/buckethost/reference/buckethost-package.md)
  : buckethost: Host and Catalogue Files on S3-Compatible Object Storage
