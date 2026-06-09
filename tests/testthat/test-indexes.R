# A small synthetic object table standing in for a real bucket listing.
fakeFiles <- function() {
  data.frame(
    key = c(
      "README.txt",
      "SCANFI_v2/1985/age.tif",
      "SCANFI_v2/1985/biomass.tif",
      "SCANFI_v2/1990/age.tif"
    ),
    size = c(1024, 2 * 1024^2, 3 * 1024^3, 5 * 1024^2),
    modified = "2026-01-01T00:00:00.000Z",
    stringsAsFactors = FALSE
  )
}

opts <- function() {
  list(
    heading = "Test Repo",
    disclaimerHtml = "<div class='hero'><p>hello</p></div>",
    hostNote = "Hosted somewhere.",
    rootLabel = "testbucket",
    timestamp = "2026-06-09 12:00 UTC"
  )
}

readTemplate <- function() {
  paste(
    readLines(
      system.file("templates", "index.html", package = "buckethost"),
      warn = FALSE
    ),
    collapse = "\n"
  )
}

test_that("buildIndexPages emits one page per directory incl. root", {
  built <- buckethost:::buildIndexPages(fakeFiles(), readTemplate(), opts())
  expect_setequal(
    names(built$html),
    c("", "SCANFI_v2", "SCANFI_v2/1985", "SCANFI_v2/1990")
  )
  # counts line up with pages, and the root has 1 dir (SCANFI_v2) + 1 file
  expect_length(built$nDirs, length(built$html))
  root <- which(names(built$html) == "")
  expect_equal(built$nDirs[root], 1L)
  expect_equal(built$nFiles[root], 1L)
})

test_that("root page lists top-level dir and file, not nested files", {
  parts <- buckethost:::buildPageParts(
    "", fakeFiles(), rootLabel = "testbucket"
  )
  expect_equal(parts$nDirs, 1L) # SCANFI_v2/
  expect_equal(parts$nFiles, 1L) # README.txt
  expect_match(parts$rows, "SCANFI_v2/index.html")
  expect_match(parts$rows, "README.txt")
  expect_false(grepl("age.tif", parts$rows)) # nested, not shown at root
})

test_that("leaf page lists its files with sizes and data-size attrs", {
  parts <- buckethost:::buildPageParts(
    "SCANFI_v2/1985", fakeFiles(), rootLabel = "testbucket"
  )
  expect_equal(parts$nFiles, 2L)
  expect_equal(parts$nDirs, 0L)
  expect_match(parts$rows, "biomass.tif")
  expect_match(parts$rows, "3.00 GB") # 3 * 1024^3
  expect_match(parts$rows, "data-size='3221225472'")
})

test_that("breadcrumb depth and parent links scale with nesting", {
  root <- buckethost:::buildPageParts("", fakeFiles(), "testbucket")
  expect_equal(root$parentLink, "") # no parent at root

  leaf <- buckethost:::buildPageParts("SCANFI_v2/1985", fakeFiles(), "testbucket")
  expect_match(leaf$parentLink, "../index.html")
  # root link climbs two levels from depth-2 dir
  expect_match(leaf$breadcrumb, "\\.\\./\\.\\./\\./index.html")
  expect_match(leaf$breadcrumb, ">testbucket<")
  expect_match(leaf$breadcrumb, ">1985<")
})

test_that("full page substitutes all template tokens (no leftovers)", {
  pages <- buckethost:::buildIndexPages(fakeFiles(), readTemplate(), opts())$html
  root <- pages[[which(names(pages) == "")]]
  expect_false(grepl("{{", root, fixed = TRUE))
  expect_match(root, "<h1>Test Repo</h1>")
  expect_match(root, "Hosted somewhere.")
  expect_match(root, "Repository contents")
})

test_that("dryRun builds pages without needing rclone or network", {
  pages <- generateIndexes(
    allFiles = fakeFiles(),
    heading = "Test Repo",
    dryRun = TRUE,
    quiet = TRUE
  )
  expect_true(length(pages) >= 4)
  expect_false(any(grepl("{{", pages, fixed = TRUE)))
})

test_that("the upload loop handles the root (\"\") page without subscript error", {
  # Regression: generateIndexes() indexed pages by name, but the root page's
  # name is "" and pages[[\"\"]] is a subscript-out-of-bounds error. Exercise
  # the real (non-dry-run) upload loop with `true` standing in for rclone so
  # every copyto "succeeds" without touching the network.
  skip_if_not(nzchar(Sys.which("true")), "no `true` executable to stand in for rclone")

  expect_no_error(
    pages <- generateIndexes(
      allFiles = fakeFiles(),
      heading = "Test Repo",
      rclonePath = "true",
      quiet = TRUE
    )
  )
  # root "" plus the three real directories were all processed
  expect_setequal(
    names(pages),
    c("", "SCANFI_v2", "SCANFI_v2/1985", "SCANFI_v2/1990")
  )
})
