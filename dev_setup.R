# Development / CRAN release workflow for the ForeCA package.
#
# Not part of the package build (see .Rbuildignore). Step through it interactively;
# it is a reference checklist, not a script to source top-to-bottom.
#
# Release checklist reference:
# https://github.com/mpjashby/sfhotspot/blob/main/.github/ISSUE_TEMPLATE/release-to-cran.md

install.packages(c("devtools", "roxygen2", "testthat", "usethis"))
library(devtools)
library(usethis)

setwd("/Users/georg/Projects/r_packages/ForeCA")

# ---------------------------------------------------------------------------
# 0. Dependencies
# ---------------------------------------------------------------------------
# R CMD check ERRORS (not skips) when a suggested package is missing, so install
# all of them before checking. rSFA is only used by the test_sfa.R cross-check,
# psd only by spectrum.control$method = "pspectrum", mgcv only by smoothing = TRUE.
install.packages(c("astsa", "MASS", "psd", "knitr", "markdown", "mgcv", "rSFA"))

# ---------------------------------------------------------------------------
# 1. Before every release: bump BOTH Version and Date in DESCRIPTION
# ---------------------------------------------------------------------------
# A stale Date ("over a month old") and an un-bumped Version each produce their
# own CRAN incoming-feasibility WARNING. inst/CITATION also derives the citation
# year from meta$Date, so the Date field must stay present.
# Then add a matching section to the top of NEWS.md.

# ---------------------------------------------------------------------------
# 2. Documentation
# ---------------------------------------------------------------------------
devtools::document()  # regenerate man/*.Rd and NAMESPACE from roxygen blocks

# Never hand-edit man/*.Rd. Two Rd gotchas that CRAN flags as NOTEs:
#   - \item{label}{description} lists must live in \describe{}, not \itemize{}
#     ("Lost braces in \itemize"). \itemize{} only takes bare \item text.
#   - the package doc block ends in "_PACKAGE"; @docType package is deprecated.

# ---------------------------------------------------------------------------
# 3. Test
# ---------------------------------------------------------------------------
devtools::test()
# Expect: FAIL 0 | WARN 6 | PASS 819. The 6 warnings are the intentional
# "cannot check if data is whitened in fast way" fallback path. Zero FAILs is the bar.

# ---------------------------------------------------------------------------
# 4. Check
# ---------------------------------------------------------------------------
devtools::check(cran = TRUE, manual = TRUE)

# Expected clean result is 2 NOTEs, both environmental and NOT actionable:
#   - "Found the following (possibly) invalid URLs" for the Cross Validated link in
#     README.md -- Stack Exchange returns 403 to non-browser user agents. URL is fine.
#   - "checking for future file timestamps ... unable to verify current time" --
#     no network access to the world-clock service. Silence locally with:
#       Sys.setenv(`_R_CHECK_SYSTEM_CLOCK_` = 0)
# Anything beyond those two is a real regression.

# If you deliberately skip installing a suggested package:
#   Sys.setenv(`_R_CHECK_FORCE_SUGGESTS_` = "false")

# ---------------------------------------------------------------------------
# 5. Build the source tarball (this is what win-builder wants)
# ---------------------------------------------------------------------------
# win-builder takes a SOURCE tarball (.tar.gz), not a Windows .zip binary.
pkg_file <- devtools::build(path = "..", manual = FALSE)
print(pkg_file)   # -> ../ForeCA_<version>.tar.gz

# Re-check the actual built artifact, not the source directory:
devtools::check_built(pkg_file, cran = TRUE)

# ---------------------------------------------------------------------------
# 6. win-builder
# ---------------------------------------------------------------------------
# Either upload pkg_file by hand at https://win-builder.r-project.org/upload.aspx
# (results are emailed to the Maintainer address in DESCRIPTION), or submit
# straight from R:
devtools::check_win_devel()     # R-devel   <- the one CRAN cares about most
devtools::check_win_release()   # R-release
devtools::check_win_oldrelease()

# Optionally also check on macOS builders and via rhub:
# devtools::check_mac_release()

# ---------------------------------------------------------------------------
# 7. Install locally and smoke-test
# ---------------------------------------------------------------------------
devtools::install()

library(ForeCA)
citation("ForeCA")   # verify inst/CITATION renders (bibentry, not the old citEntry)

XX <- diff(log(EuStockMarkets)) * 100
Omega(XX)
ff <- foreca(XX, n.comp = 4)
ff
summary(ff)
plot(ff)

# Sanity check on the convergence tolerance: the EFFECTIVE default is 1e-6, which is
# deliberate (a looser tol stops EM early and costs ~0.2pp of Omega on the leading
# ForeC). Only a bare no-arg call falls back to the formal default of 1e-3.
complete_algorithm_control(list())$tol   # 1e-06
complete_algorithm_control()$tol         # 0.001

# ---------------------------------------------------------------------------
# 8. Submit
# ---------------------------------------------------------------------------
# Once win-builder is clean, submit at https://cran.r-project.org/submit.html
# (or devtools::release()). Include a cran-comments.md explaining the two
# expected NOTEs above.
