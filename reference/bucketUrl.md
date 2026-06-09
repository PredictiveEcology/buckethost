# Build the public URL for an object

Build the public URL for an object

## Usage

``` r
bucketUrl(path, container = NULL, endpoint = NULL)
```

## Arguments

- path:

  Object key relative to the bucket root, e.g.
  `"SCANFI_v2/1985/SCANFI_age_median_1985_v2.tif"`.

- container:

  The bucket (container) name. When `NULL` (the default), resolved from
  `options(buckethost.container=)`, then `BUCKETHOST_CONTAINER`, then a
  built-in default.

- endpoint:

  The object store's HTTPS host (no bucket name). When `NULL`, resolved
  from `options(buckethost.endpoint=)`, then `BUCKETHOST_ENDPOINT`, then
  a built-in default.

## Value

The full HTTPS URL `endpoint/container/path` (character).

## See also

[`bucketRaster()`](https://predictiveecology.github.io/buckethost/reference/bucketRaster.md)
for a GDAL `/vsicurl/` wrapper.

## Examples

``` r
bucketUrl("SCANFI_v2/1985/age.tif",
           endpoint = "https://object-arbutus.cloud.computecanada.ca",
           container = "predictiveecology")
#> [1] "https://object-arbutus.cloud.computecanada.ca/predictiveecology/SCANFI_v2/1985/age.tif"
```
