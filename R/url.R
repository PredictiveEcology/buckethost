#' Build the public URL for an object
#'
#' @param path Object key relative to the bucket root, e.g.
#'   `"SCANFI_v2/1985/SCANFI_age_median_1985_v2.tif"`.
#' @inheritParams bucket_config
#'
#' @return The full HTTPS URL `endpoint/container/path` (character).
#' @seealso [bucket_raster()] for a GDAL `/vsicurl/` wrapper.
#' @export
#' @examples
#' bucket_url("SCANFI_v2/1985/age.tif",
#'            endpoint = "https://object-arbutus.cloud.computecanada.ca",
#'            container = "predictiveecology")
bucket_url <- function(path, container = NULL, endpoint = NULL) {
  paste0(bucket_base_url(container, endpoint), "/", path)
}

#' Read a remote raster via GDAL `/vsicurl/`
#'
#' Convenience wrapper around `terra::rast("/vsicurl/<url>")`. When the object
#' is a Cloud-Optimized GeoTIFF, GDAL fetches only the byte ranges needed —
#' opening metadata or cropping to a small area transfers a few hundred KB
#' rather than the whole file.
#'
#' @inheritParams bucket_url
#' @param ... Passed to [terra::rast()].
#'
#' @return A [terra::SpatRaster].
#' @export
#' @examples
#' \dontrun{
#' r <- bucket_raster("SCANFI_v2/1985/SCANFI_age_median_1985_v2.tif")
#' r                                  # metadata only, no full download
#' terra::crop(r, my_aoi)             # fetches just the AOI's bytes
#' }
bucket_raster <- function(path, container = NULL, endpoint = NULL, ...) {
  if (!requireNamespace("terra", quietly = TRUE)) {
    stop(
      "bucket_raster() needs the 'terra' package. ",
      "Install it with install.packages('terra').",
      call. = FALSE
    )
  }
  terra::rast(paste0("/vsicurl/", bucket_url(path, container, endpoint)), ...)
}
