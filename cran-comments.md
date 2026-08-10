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

* local macOS (aarch64-apple-darwin20), R 4.4.2 -- 0 errors, 0 warnings, 0 notes
  (locally two additional NOTEs appear that are environmental only: a 403 from
  stats.stackexchange.com, which rejects non-browser user agents, and
  "unable to verify current time" from the offline check host. Neither reproduces
  on win-builder.)
* win-builder, R Under development (unstable) (2026-08-09 r90385 ucrt) -- Status: OK
* win-builder, R release -- submitted
* win-builder, R oldrelease -- submitted

## R CMD check results

Status: OK on win-builder R-devel. 0 errors, 0 warnings, 0 notes.

## Reverse dependencies

No reverse dependencies were broken; the changes are limited to documentation, metadata,
and the removal of unused declared dependencies.
