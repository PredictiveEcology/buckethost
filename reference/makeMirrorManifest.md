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
  file = NULL
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

  Optional Google Drive folder id or URL. When supplied, the folder is
  listed recursively and an `id` column is added, matched to the bucket
  objects by file name. Requires the googledrive package.

- endpoint:

  Optional endpoint override (see
  [bucketConfig](https://predictiveecology.github.io/buckethost/reference/bucketConfig.md)).

- file:

  Optional path to write the manifest to as CSV. When `NULL` (default)
  no file is written.

## Value

A `data.frame` with columns `filename`, `key`, `url`, and (when
`driveFolder` is given) `id`. Returned invisibly when `file` is written,
visibly otherwise.

## Details

Matching to Drive is by **file name** (`basename(key)`). If the same
file name appears under more than one folder in the bucket, those rows
cannot be told apart by name alone and the `id` match is ambiguous; a
warning is issued listing the offending names. The `key` column always
disambiguates the rows themselves.

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
