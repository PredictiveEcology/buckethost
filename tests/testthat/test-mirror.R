# Mock bucketLs() / bucketUrl() so these tests need no bucket or network.
mockLs <- function(prefix = "", container = NULL, endpoint = NULL,
                    includeIndexes = FALSE) {
  data.frame(
    key = c("SCANFI_v2/1985/age.tif", "SCANFI_v2/1990/age.tif",
            "SCANFI_v2/1985/biomass.tif"),
    size = c(1, 2, 3),
    modified = "2026-01-01T00:00:00.000Z",
    stringsAsFactors = FALSE
  )
}
mockUrl <- function(path, container = NULL, endpoint = NULL) {
  paste0("https://host/", container %||% "predictiveecology", "/", path)
}
`%||%` <- function(a, b) if (is.null(a)) b else a

test_that("makeMirrorManifest builds filename/key/url and can write CSV", {
  testthat::local_mocked_bindings(bucketLs = mockLs, bucketUrl = mockUrl)

  tmp <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp), add = TRUE)

  m <- makeMirrorManifest("predictiveecology", "SCANFI_v2/", file = tmp)

  expect_named(m, c("filename", "key", "url"))
  expect_equal(m$filename, c("age.tif", "age.tif", "biomass.tif"))
  expect_equal(
    m$url[1],
    "https://host/predictiveecology/SCANFI_v2/1985/age.tif"
  )
  expect_false("id" %in% names(m)) # no driveFolder -> no id column

  # CSV round-trips
  expect_true(file.exists(tmp))
  back <- utils::read.csv(tmp, stringsAsFactors = FALSE)
  expect_equal(back$url, m$url)
})

test_that("makeMirrorManifest returns invisibly when writing a file", {
  testthat::local_mocked_bindings(bucketLs = mockLs, bucketUrl = mockUrl)
  tmp <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp), add = TRUE)
  expect_invisible(makeMirrorManifest("predictiveecology", file = tmp))
})

test_that("driveFolder without googledrive installed errors clearly", {
  testthat::local_mocked_bindings(bucketLs = mockLs, bucketUrl = mockUrl)
  skip_if(
    requireNamespace("googledrive", quietly = TRUE),
    "googledrive is installed; cannot test the missing-package path"
  )
  expect_error(
    makeMirrorManifest("predictiveecology", driveFolder = "abc"),
    "googledrive"
  )
})

test_that("duplicate basenames warn when matching to Drive", {
  skip_if_not(
    requireNamespace("googledrive", quietly = TRUE),
    "googledrive not installed"
  )
  testthat::local_mocked_bindings(bucketLs = mockLs, bucketUrl = mockUrl)
  # Stub googledrive::drive_ls / as_id so no real Drive call happens.
  testthat::local_mocked_bindings(
    as_id = function(x) x,
    drive_ls = function(path, recursive = TRUE, ...) {
      data.frame(name = c("age.tif", "biomass.tif"),
                 id = c("id_age", "id_bio"), stringsAsFactors = FALSE)
    },
    .package = "googledrive"
  )
  expect_warning(
    m <- makeMirrorManifest("predictiveecology", driveFolder = "folder"),
    "more than one prefix"
  )
  # age.tif appears twice; both rows get the (single) matched id
  expect_equal(m$id[m$filename == "age.tif"], c("id_age", "id_age"))
})
