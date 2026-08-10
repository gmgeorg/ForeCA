# ForeCA

CRAN R package implementing **Forecastable Component Analysis** (Goerg, JMLR W&CP 28(2):64-72, 2013).
Finds linear combinations `y_t = X_t w` of a multivariate time series that are maximally
*forecastable*, where forecastability `Omega(y_t) = (1 - spectral_entropy(y_t)) * 100` (in %).
Pure R, no compiled code. Version in `DESCRIPTION`; release notes in `NEWS.md`.

## Commands

```bash
Rscript -e 'devtools::test()'                  # ~10s, 819 assertions, expect 6 warnings (see below)
Rscript -e 'devtools::test(filter = "foreca")' # single test file
Rscript -e 'devtools::load_all()'              # interactive dev
Rscript -e 'devtools::document()'              # regenerate man/ (roxygen2 7.3.2)
Rscript -e 'devtools::check()'                 # full R CMD check
Rscript -e 'knitr::knit("vignettes/Introduction.Rmd")'
```

`man/*.Rd` is roxygen2-generated — **edit the roxygen block in `R/`, never the `.Rd`**.
`RoxygenNote` matches the installed roxygen2, so `document()` produces a minimal diff.

**Clean `R CMD check --as-cran` is 2 NOTEs**, both environmental, neither actionable:
a 403 on the Cross Validated link in `README.md` (bot-blocking; the URL is fine in a browser)
and "unable to verify current time" (no network access to the time service). Anything else is new.

## Pipeline

`foreca(series, n.comp)` is the only entry point users should call. It is a `princomp`-alike:
returns `$scores` (the ForeCs), `$loadings`, `$Omega`, `$whitening`, `$center`.

```text
series (T x K)
  └─ whiten()                    -> U (zero mean, unit var, uncorrelated) + whitening/dewhitening matrices
      └─ foreca.multiple_weightvectors()      # deflation loop over n.comp
          for each component:
            MASS::Null() projection onto orthogonal complement of previous weightvectors
            └─ foreca.one_weightvector()      # dispatch + num.starts random restarts
                └─ foreca.EM.one_weightvector()
                    initialize_weightvector() # "rnorm" default; also max/PCA*/SFA*
                    iterate foreca.EM.E_and_M_step() until tol / max.iter:
                      E: foreca.EM.E_step()   f_y = w' f_U w   (spectrum_of_linear_combination)
                      M: foreca.EM.M_step()   min-eigenvector of weightvector2entropy_wcov(),
                                              i.e. cov matrix weighted by -log(f_y)
```

Supporting layer: `mvspectrum()` (spectrum estimation) → `normalize_mvspectrum()` →
`mvspectrum2wcov()` (integrate spectrum back to a weighted covariance matrix) →
`spectral_entropy()` → `Omega()`. Entropy plugins: `discrete_entropy()`, `continuous_entropy()`.
`sfa()` (slow feature analysis) exists mainly to seed `initialize_weightvector(method = "SFA*")`.

## Conventions

- **Control lists.** Every non-trivial function takes `spectrum.control`, `entropy.control`,
  `algorithm.control` as partial lists and passes them through
  `complete_{spectrum,entropy,algorithm}_control()` (`R/complete_controls.R`), which fill defaults
  and **reject unknown names**. Add a new setting there and to its `valid.entries` vector.
- **`mvspectrum` objects** are 3D arrays `num.freqs x K x K` over **positive frequencies only**
  (0 omitted); Hermitian per frequency, with `"frequency"` and `"normalized"` attributes.
  Normalized means it sums to `0.5 * I_K` over the stored half. Univariate spectra are plain vectors.
- **Attribute-based fast checks.** `check_whitened()` / `check_mvspectrum_normalized()` look only at
  the `"whitened"` / `"normalized"` attribute by default (`check.attribute.only = TRUE`) and fall
  back to a slow data-driven check with a warning if it is absent. Preserve these attributes when
  transforming data or spectra, otherwise inner-loop code warns or errors.
- **Naming.** Exported API is `snake_case`; `.`-prefixed functions (`.mvspec2mvspectrum`) are
  internal converters; `foreca.EM.*` uses dots as namespacing, *not* S3 dispatch. Real S3 methods:
  `print/summary/plot/biplot.foreca`, `summary/plot.foreca.one_weightvector`, `plot.mvspectrum`.
- **Tests** (`tests/testthat/`, testthat **2nd edition**) mirror `R/` file names, use `context()`,
  `kPascalCase` constants for fixtures, and `helper_*.R` for shared constants
  (`kMvspectrumMethods <- c("mvspec", "pgram")` — only these two methods are exercised).
  Tests assert mathematical properties (Hermitian, PSD, orthonormal, sums to 0.5), not golden values.
- Commit messages: short, lowercase, imperative ("fix link", "update readme").

## Gotchas

- **`\item{label}{description}` lists must use `\describe{}`, not `\itemize{}`** — the latter
  triggers CRAN's "Lost braces" NOTE. `\itemize` takes bare `\item text` only. (Under `@return`,
  `\item{}{}` at top level without any wrapper is also valid; `R/complete_controls.R` and
  `R/whiten.R` rely on that.)
- The package-level doc block ends in `"_PACKAGE"`, not `NULL` — `@docType package` is deprecated
  in roxygen2 7.3.x. Author/aliases are derived from `DESCRIPTION`; don't re-add `@author`/`@aliases`.
- If a suggested package is not installed, `R CMD check` **errors** ("Packages suggested but not
  available") rather than skipping. Either install it or run with `_R_CHECK_FORCE_SUGGESTS_=false`.
  `test_sfa.R` guards its `rSFA` cross-check with `requireNamespace()` and silently skips it.
- The 6 test warnings are the intentional "cannot check if data is whitened in fast way" path
  (`test_foreca.R`, `test_mvspectrum.R`). Zero failures is the passing bar; the warnings are expected.
- `spectrum.control$method = "mvspec"` (default) requires **astsa**; `"pspectrum"` requires **psd**
  and is *not production-ready* — `psd::pspectrum` does not preserve the identity
  `f_y = w' f_X w`, so ForeCA's quadratic-form step is inconsistent under it (see NEWS 0.2.7).
  `"ar"` is univariate-only. Spectrum `smoothing = TRUE` needs **mgcv** and is univariate-only.
- `Omega` re-estimated directly from `$scores` will not exactly match `$Omega`: the reported value
  comes from `w' f_X w`, not from re-estimating the spectrum of the combined series. Always read
  `$Omega` / `$Omega.univ` off the fitted object. See the Warning section in `?foreca`.
- `complete_algorithm_control()` specifies defaults **twice** — as formal-argument defaults and again
  via `is.null()` fill-ins in the body. Realistic calls pass a partial list, so **only the body
  fill-ins take effect**; the signature defaults are reachable only via a bare no-arg call. Mirror
  any new setting into `valid.entries` too.
- **`tol` diverges between the two on purpose**: signature `1e-3`, body fill-in (and therefore the
  effective default) `1e-6`. This is a quality decision, not a bug — relaxing `tol` to `1e-3` stops
  EM early and costs ~0.2pp of `Omega` on the leading ForeC (6.34 → 6.13 on `EuStockMarkets`,
  `n.comp = 4`), while roughly halving runtime. Do not "align" the two without re-measuring `Omega`;
  there is a code comment at the fill-in saying so.
- `inst/CITATION` derives the citation year from `meta$Date`, so `DESCRIPTION` must keep a `Date:`
  field. On release, bump both `Version:` and `Date:` — a stale `Date` and an un-bumped version each
  produce a CRAN incoming-feasibility WARNING.
