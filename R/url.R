#' Build the public URL for an object
#'
#' @param path Object key relative to the bucket root, e.g.
#'   `"SCANFI_v2/1985/SCANFI_age_median_1985_v2.tif"`.
#' @inheritParams bucketConfig
#'
#' @return The full HTTPS URL `endpoint/container/path` (character).
#' @seealso [bucketRaster()] for a GDAL `/vsicurl/` wrapper.
#' @export
#' @examples
#' bucketUrl("SCANFI_v2/1985/age.tif",
#'            endpoint = "https://object-arbutus.cloud.computecanada.ca",
#'            container = "predictiveecology")
bucketUrl <- function(path, container = NULL, endpoint = NULL) {
  paste0(bucketBaseUrl(container, endpoint), "/", path)
}

#' Read a remote raster via GDAL `/vsicurl/`
#'
#' Convenience wrapper around `terra::rast("/vsicurl/<url>")`. When the object
#' is a Cloud-Optimized GeoTIFF, GDAL fetches only the byte ranges needed —
#' opening metadata or cropping to a small area transfers a few hundred KB
#' rather than the whole file.
#'
#' @inheritParams bucketUrl
#' @param ... Passed to [terra::rast()].
#'
#' @return A [terra::SpatRaster].
#' @export
#' @examples
#' \dontrun{
#' r <- bucketRaster("SCANFI_v2/1985/SCANFI_age_median_1985_v2.tif")
#' r                                  # metadata only, no full download
#' terra::crop(r, my_aoi)             # fetches just the AOI's bytes
#' }
bucketRaster <- function(path, container = NULL, endpoint = NULL, ...) {
  if (!requireNamespace("terra", quietly = TRUE)) {
    stop(
      "bucketRaster() needs the 'terra' package. ",
      "Install it with install.packages('terra').",
      call. = FALSE
    )
  }
  terra::rast(paste0("/vsicurl/", bucketUrl(path, container, endpoint)), ...)
}
