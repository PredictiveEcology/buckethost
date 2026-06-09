# A small synthetic object table standing in for a real bucket listing.
fake_files <- function() {
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
    disclaimer_html = "<div class='hero'><p>hello</p></div>",
    host_note = "Hosted somewhere.",
    root_label = "testbucket",
    timestamp = "2026-06-09 12:00 UTC"
  )
}

read_template <- function() {
  paste(
    readLines(
      system.file("templates", "index.html", package = "buckethost"),
      warn = FALSE
    ),
    collapse = "\n"
  )
}

test_that("build_index_pages emits one page per directory incl. root", {
  pages <- buckethost:::build_index_pages(fake_files(), read_template(), opts())
  expect_setequal(
    names(pages),
    c("", "SCANFI_v2", "SCANFI_v2/1985", "SCANFI_v2/1990")
  )
})

test_that("root page lists top-level dir and file, not nested files", {
  parts <- buckethost:::build_page_parts(
    "", fake_files(), root_label = "testbucket"
  )
  expect_equal(parts$n_dirs, 1L) # SCANFI_v2/
  expect_equal(parts$n_files, 1L) # README.txt
  expect_match(parts$rows, "SCANFI_v2/index.html")
  expect_match(parts$rows, "README.txt")
  expect_false(grepl("age.tif", parts$rows)) # nested, not shown at root
})

test_that("leaf page lists its files with sizes and data-size attrs", {
  parts <- buckethost:::build_page_parts(
    "SCANFI_v2/1985", fake_files(), root_label = "testbucket"
  )
  expect_equal(parts$n_files, 2L)
  expect_equal(parts$n_dirs, 0L)
  expect_match(parts$rows, "biomass.tif")
  expect_match(parts$rows, "3.00 GB") # 3 * 1024^3
  expect_match(parts$rows, "data-size='3221225472'")
})

test_that("breadcrumb depth and parent links scale with nesting", {
  root <- buckethost:::build_page_parts("", fake_files(), "testbucket")
  expect_equal(root$parent_link, "") # no parent at root

  leaf <- buckethost:::build_page_parts("SCANFI_v2/1985", fake_files(), "testbucket")
  expect_match(leaf$parent_link, "../index.html")
  # root link climbs two levels from depth-2 dir
  expect_match(leaf$breadcrumb, "\\.\\./\\.\\./\\./index.html")
  expect_match(leaf$breadcrumb, ">testbucket<")
  expect_match(leaf$breadcrumb, ">1985<")
})

test_that("full page substitutes all template tokens (no leftovers)", {
  pages <- buckethost:::build_index_pages(fake_files(), read_template(), opts())
  root <- pages[[which(names(pages) == "")]]
  expect_false(grepl("{{", root, fixed = TRUE))
  expect_match(root, "<h1>Test Repo</h1>")
  expect_match(root, "Hosted somewhere.")
  expect_match(root, "Repository contents")
})

test_that("dry_run builds pages without needing rclone or network", {
  pages <- generate_indexes(
    all_files = fake_files(),
    heading = "Test Repo",
    dry_run = TRUE,
    quiet = TRUE
  )
  expect_true(length(pages) >= 4)
  expect_false(any(grepl("{{", pages, fixed = TRUE)))
})
