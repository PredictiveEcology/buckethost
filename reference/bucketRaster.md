# Read a remote raster via GDAL `/vsicurl/`

Convenience wrapper around `terra::rast("/vsicurl/<url>")`. When the
object is a Cloud-Optimized GeoTIFF, GDAL fetches only the byte ranges
needed — opening metadata or cropping to a small area transfers a few
hundred KB rather than the whole file.

## Usage

``` r
bucketRaster(path, container = NULL, endpoint = NULL, ...)
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

- ...:

  Passed to
  [`terra::rast()`](https://rspatial.github.io/terra/reference/rast.html).

## Value

A
[terra::SpatRaster](https://rspatial.github.io/terra/reference/SpatRaster-class.html).

## Examples

``` r
if (FALSE) { # \dontrun{
r <- bucketRaster("SCANFI_v2/1985/SCANFI_age_median_1985_v2.tif")
r                                  # metadata only, no full download
terra::crop(r, my_aoi)             # fetches just the AOI's bytes
} # }
```
