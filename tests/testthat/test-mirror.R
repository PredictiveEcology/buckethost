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

# A Drive listing mirroring the bucket: a SCANFI_v2 root (id "ROOT") with
# 1985/ and 1990/ folders, age.tif in both plus biomass.tif in 1985.
mockDriveLs <- function(path, recursive = TRUE, ...) {
  d <- data.frame(
    name = c("1985", "1990", "age.tif", "biomass.tif", "age.tif"),
    id   = c("F1985", "F1990", "A85", "B85", "A90"),
    stringsAsFactors = FALSE
  )
  d$drive_resource <- list(
    list(parents = "ROOT"),
    list(parents = "ROOT"),
    list(parents = "F1985"),
    list(parents = "F1985"),
    list(parents = "F1990")
  )
  d
}

test_that("driveRelPaths rebuilds relative paths from the parent chain", {
  rel <- buckethost:::driveRelPaths(mockDriveLs(), rootId = "ROOT")
  expect_equal(
    rel,
    c("1985", "1990", "1985/age.tif", "1985/biomass.tif", "1990/age.tif")
  )
})

test_that("Drive id matches by relative path, keeping duplicate names distinct", {
  skip_if_not(
    requireNamespace("googledrive", quietly = TRUE),
    "googledrive not installed"
  )
  testthat::local_mocked_bindings(bucketLs = mockLs, bucketUrl = mockUrl)
  testthat::local_mocked_bindings(
    as_id = function(x) "ROOT",
    drive_ls = mockDriveLs,
    .package = "googledrive"
  )
  m <- makeMirrorManifest("predictiveecology", prefix = "SCANFI_v2",
                          driveFolder = "folder")
  # mockLs keys: 1985/age.tif, 1990/age.tif, 1985/biomass.tif
  # The two age.tif rows now resolve to DIFFERENT Drive ids.
  expect_equal(m$id, c("A85", "A90", "B85"))
})

test_that("unmatched objects keep id = NA and the warning names them", {
  skip_if_not(
    requireNamespace("googledrive", quietly = TRUE),
    "googledrive not installed"
  )
  # Bucket has an extra object (a manifest CSV) with no Drive counterpart.
  lsWithExtra <- function(prefix = "", container = NULL, endpoint = NULL,
                          includeIndexes = FALSE) {
    data.frame(
      key = c("SCANFI_v2/1985/age.tif", "SCANFI_v2/files.csv"),
      size = c(1, 2), modified = "x", stringsAsFactors = FALSE
    )
  }
  testthat::local_mocked_bindings(bucketLs = lsWithExtra, bucketUrl = mockUrl)
  testthat::local_mocked_bindings(
    as_id = function(x) "ROOT", drive_ls = mockDriveLs, .package = "googledrive"
  )
  expect_warning(
    m <- makeMirrorManifest("predictiveecology", prefix = "SCANFI_v2",
                            driveFolder = "folder"),
    "SCANFI_v2/files\\.csv"
  )
  expect_true(is.na(m$id[m$key == "SCANFI_v2/files.csv"]))
  expect_equal(m$id[m$key == "SCANFI_v2/1985/age.tif"], "A85")
})

test_that("falls back to name matching (with warning) when parents are absent", {
  skip_if_not(
    requireNamespace("googledrive", quietly = TRUE),
    "googledrive not installed"
  )
  testthat::local_mocked_bindings(bucketLs = mockLs, bucketUrl = mockUrl)
  testthat::local_mocked_bindings(
    as_id = function(x) "ROOT",
    drive_ls = function(path, recursive = TRUE, ...) {
      data.frame(name = c("age.tif", "biomass.tif"),
                 id = c("id_age", "id_bio"), stringsAsFactors = FALSE)
    },
    .package = "googledrive"
  )
  expect_warning(
    m <- makeMirrorManifest("predictiveecology", prefix = "SCANFI_v2",
                            driveFolder = "folder"),
    "falling back to file-name matching"
  )
  expect_equal(m$id[m$filename == "age.tif"], c("id_age", "id_age"))
})
