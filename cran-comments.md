# cran-comments

## Submission summary

ForeCA 0.2.8 is a maintenance release that addresses the `R CMD check` issues raised by the
CRAN maintainers. Notably:

* removed the "Lost braces in \itemize" `Rd` NOTEs in `?foreca` and `?initialize_weightvector`
  (`\describe{}` is now used for `\item{label}{description}` lists).
* replaced the deprecated `citEntry()` / `personList()` calls in `inst/CITATION` with
  `bibentry()` / `c(person(...))`.
* fixed stale references: the JMLR proceedings URL returned 404 and now points at
  <https://proceedings.mlr.press/v28/goerg13.html>; remaining `http` links were updated.
* added `.Rbuildignore` so development-only files are no longer shipped in the tarball.
* dropped the unused `reshape2` import and the unused `fBasics` / `nlme` suggests.

There are no user-visible changes to the algorithms; `Omega` and `foreca()` results are
unchanged from 0.2.7. See `NEWS.md` for the full list.

## Test environments

* local macOS (aarch64-apple-darwin20), R 4.4.2
* win-builder, R Under development (unstable) (2026-08-09 r90385 ucrt) -- Status: OK
* win-builder, R 4.5.3 (oldrelease) -- Status: 1 NOTE (see below)
* win-builder, R release -- submitted

## R CMD check results

0 errors, 0 warnings.

`Status: OK` on win-builder R-devel. On win-builder R-oldrelease there is one NOTE:

```
Found the following (possibly) invalid URLs:
  URL: https://scholar.google.com/scholar?...cites=5674198772479433271
    From: README.md
    Status: 403
  URL: https://stats.stackexchange.com/questions/126829/how-to-determine-forecastability-of-time-series
    From: README.md
    Status: 403
```

Both URLs are valid and load correctly in a browser; Google Scholar and Stack Exchange
return 403 to automated (non-browser) user agents. We have verified both by hand and
would ask that this NOTE be disregarded. The same check reports OK on R-devel.

Locally an additional environmental NOTE appears -- "checking for future file
timestamps ... unable to verify current time" -- because the local check host has no
network access to the world-clock service. It does not reproduce on win-builder.

## Reverse dependencies

No reverse dependencies were broken; the changes are limited to documentation, metadata,
and the removal of unused declared dependencies.
