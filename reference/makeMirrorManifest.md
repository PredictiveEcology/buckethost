# Build a mirror manifest for a bucket

Produces a "remap" table: one row per object in the bucket, giving its
`filename`, its full object `key`, and its public `url`. Optionally adds
an `id` column with the matching Google Drive file id, so you can map a
Drive source to its mirrored copy on the bucket. Optionally writes the
table to a CSV.

## Usage

``` r
makeMirrorManifest(
  bucket = NULL,
  prefix = "",
  driveFolder = NULL,
  endpoint = NULL,
  file = NULL,
  directories = FALSE
)
```

## Arguments

- bucket:

  Container (bucket) name. When `NULL` (default), resolved via
  [`bucketContainer()`](https://predictiveecology.github.io/buckethost/reference/bucketConfig.md).

- prefix:

  Optional key prefix to restrict the manifest, e.g. `"SCANFI_v2/1985"`.
  Default `""` (the whole bucket).

- driveFolder:

  Optional Google Drive folder id or URL corresponding to the bucket's
  `prefix` folder. When supplied, the folder is listed recursively and
  an `id` column is added, matched to the bucket objects by their **path
  relative to the folder** (see Details). Requires the googledrive
  package.

- endpoint:

  Optional endpoint override (see
  [bucketConfig](https://predictiveecology.github.io/buckethost/reference/bucketConfig.md)).

- file:

  Optional path to write the manifest to as CSV. When `NULL` (default)
  no file is written.

- directories:

  Logical. When `TRUE`, append one *directory remap* row per Google
  Drive folder (mapping its folder id to the bucket's prefix-listing
  URL) and add a `type` column (`"file"`/`"dir"`). Requires
  `driveFolder`. Default `FALSE` (file rows only, unchanged schema).

## Value

A `data.frame` with columns `filename`, `key`, `url`, and (when
`driveFolder` is given) `id`; plus a `type` column and appended
directory rows when `directories = TRUE`. Returned invisibly when `file`
is written, visibly otherwise.

## Details

With `directories = TRUE` the manifest also gains one row per Google
Drive **folder** (a *directory remap*): its `url` is the bucket's S3
prefix-listing URL for the matching folder
(`<base>/?prefix=<key>/&delimiter=/`), and a `type` column distinguishes
`"dir"` rows from `"file"` rows. A consumer (e.g. `reproducible`) can
then enumerate a Drive folder's contents from the public bucket listing
instead of
[`googledrive::drive_ls()`](https://googledrive.tidyverse.org/reference/drive_ls.html),
so listing a folder needs no Google authentication.

Matching to Drive is by **relative path**, not bare file name. The
bucket object `SCANFI_v2/1985/age.tif` (with `prefix = "SCANFI_v2"`) is
matched to the Drive file at `1985/age.tif` under `driveFolder`. This
keeps identical file names under different folders (e.g. `1985/age.tif`
and `1990/age.tif`) distinct, which a
bare-[`basename()`](https://rdrr.io/r/base/basename.html) match cannot
do.

Because `googledrive::drive_ls(recursive = TRUE)` flattens the tree, the
relative Drive paths are reconstructed from each item's parent chain. If
the listing carries no parent information, the function falls back to
file-name matching and warns. Objects with no Drive file at the matching
path get `NA` and a count is warned.

## See also

[`bucketLs()`](https://predictiveecology.github.io/buckethost/reference/bucketLs.md),
[`bucketUrl()`](https://predictiveecology.github.io/buckethost/reference/bucketUrl.md)

## Examples

``` r
if (FALSE) { # \dontrun{
m <- buckethost::makeMirrorManifest(
  "predictiveecology", "SCANFI_v2/",
  driveFolder = "https://.../folders/199oEp-..."
)
write.csv(m, "arbutus_manifest_SCANFI_v2_clean.csv", row.names = FALSE)

# Or let makeMirrorManifest() write the CSV for you via `file =`:
makeMirrorManifest("predictiveecology", "SCANFI_v2/",
                   driveFolder = "https://.../folders/199oEp-...",
                   file = "arbutus_manifest_SCANFI_v2_clean.csv")
} # }
```
