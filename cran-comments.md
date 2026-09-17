# cran-comments

## Submission summary

ForeCA 0.2.8-1 is a follow-up patch to the 0.2.8 submission. A subsequent `R CMD check`
run on a newer `R-devel` build (2026-08-19) surfaced one additional NOTE not caught by
the checks run for 0.2.8:

* `?common-arguments` is an internal, non-callable Rd topic that exists only so that other
  functions can `@inheritParams` its argument descriptions; it was flagged as "Rd files
  without \usage: common-arguments.Rd \arguments should not be documented without \usage".
  Fixed by marking the topic `@keywords internal`.

This release also carries forward everything already fixed in 0.2.8 (see `NEWS.md`):
the `\itemize`/`\describe` "Lost braces" NOTEs in `?foreca` and `?initialize_weightvector`,
modernizing `inst/CITATION` to `bibentry()`/`c(person(...))`, and related cleanup.

There are no user-visible changes to the algorithms; `Omega` and `foreca()` results are
unchanged from 0.2.7.

## Test environments

* local macOS (aarch64-apple-darwin20), R 4.4.2
* win-builder, R Under development (unstable) -- to be submitted

## R CMD check results

0 errors, 0 warnings, 0 notes locally (the environmental "unable to verify current time"
NOTE aside, since the local check host has no network access to the world-clock service).

## Reverse dependencies

No reverse dependencies were broken; the change is limited to a single Rd `\keyword` tag.
