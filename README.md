# buckethost

<!-- badges: start -->
<!-- badges: end -->

> Host and catalogue files on any S3-compatible object store.

`buckethost` turns a bucket into a browsable, remotely readable data
repository. It was built to host open geospatial data (Cloud-Optimized
GeoTIFFs) on the Digital Research Alliance of Canada's **Arbutus** object
storage, but nothing in it is Arbutus-specific — it works against any
S3-compatible store: Amazon S3, OpenStack Swift, Ceph, MinIO, Cloudflare R2,
Backblaze B2.

It does three things:

| Job | Functions |
|-----|-----------|
| **Discover** what's in a bucket | `bucket_ls()`, `bucket_url()`, `bucket_raster()` |
| **Mutate** the bucket (loudly) | `bucket_upload()`, `bucket_delete()` |
| **Maintain** a browsable catalogue + integrity | `generate_indexes()`, `bucket_verify()` |

## Installation

```r
# install.packages("remotes")
remotes::install_github("PredictiveEcology/buckethost")
```

Upload/delete/verify shell out to [`rclone`](https://rclone.org); install it
and configure a remote with `rclone config` (see the migration vignette).
Listing and index generation only need a public-read bucket — no credentials.

## Configure once

Most functions resolve their connection details from options (or
`BUCKETHOST_*` environment variables), so set them once per session:

```r
options(
  buckethost.endpoint  = "https://object-arbutus.cloud.computecanada.ca",
  buckethost.container = "predictiveecology",
  buckethost.remote    = "arbutus"   # the rclone remote name
)
```

## Read remote rasters without downloading

```r
library(buckethost)

r <- bucket_raster("SCANFI_v2/1985/SCANFI_age_median_1985_v2.tif")
r                          # opens metadata only — no full download

aoi <- terra::vect(my_study_area)
sub <- terra::crop(r, terra::project(aoi, terra::crs(r)))   # fetches only the AOI bytes
terra::plot(sub)
```

## Build a browsable catalogue

```r
generate_indexes(
  heading = "PredictiveEcology Temporary Data Repository",
  disclaimer_html = paste0(
    "<div class='hero'><p><strong>These data are not produced by the ",
    "PredictiveEcology group</strong> and are only hosted here to ease open ",
    "data access.</p></div>"
  ),
  host_note = "Hosted on the Digital Research Alliance of Canada's Arbutus object storage."
)
```

This writes one `index.html` per "folder" in the bucket (sortable columns,
breadcrumbs, per-page disclaimer) and uploads them. Browse the result at
`<endpoint>/<container>/index.html`. Re-run whenever the data changes.

The HTML is produced from a template you can override
(`system.file("templates", "index.html", package = "buckethost")`); pass
`template = "my-template.html"` to customise it. Tokens: `{{page_title}}`,
`{{repo_heading}}`, `{{disclaimer_html}}`, `{{viewing_heading}}`,
`{{breadcrumb}}`, `{{parent_link}}`, `{{rows}}`, `{{host_note}}`,
`{{timestamp}}`.

## Migrate data into a bucket

See `vignette("migration-workflow", package = "buckethost")` for the full
end-to-end recipe: requesting an Arbutus allocation, EC2 credentials,
configuring `rclone` for S3 + Google Drive, running a large transfer on a fast
transfer node, verifying it, and generating the catalogue.

## Why object storage over Google Drive?

Google Drive doesn't serve HTTP range requests reliably, so
`terra::rast("/vsicurl/...")` ends up pulling whole files. An S3/Swift store
serves byte ranges, so reading a COG transfers only the bytes your area of
interest needs — typically a few hundred KB per query.

## License

GPL-3 © Eliot McIntire / PredictiveEcology
