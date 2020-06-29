# ForeCA Release Notes

## 0.2.7

* add `pspectrum` from **psd** package as a replacement for `sapa::SDF`.  Not recommended for
  use in production yet since `psd::psectrum` does not preserve spectrum estimates from
  multivariate spectrum to univariate, i.e., spectrum of linear combination does not equal
  linear combination (quadratic form) of spectrum.  `psd::pspectrum` an be used to compute
  univariate forecastability estimates based on a better (smoothed) estimates of periodogram
  compared to raw `spec.pgram`.

## v0.2.6-1 

* remove all dependencies and calls to **sapa** R package.  In particular this
  means no `"wosa"`, `"multitaper"`, or `"direct"` spectral `method` argument
  anymore. Instead rely on `"mvspec"` in the **astsa** package.
  
  This is (unfortunately) necessary since **ifultools** and all its dependencies
  were removed from CRAN by 2020-06-09. **sapa** was the workhorse package for
  **ForeCA**.

## v0.2.5 (May 2020)

* make `ForeCA` compatible with R 4.0.0
* improve test coverage and error messages (move away from `expect_true` wherever possible)

## v0.2.4 (April 2016)

### New

- added an introductory R markdown vignette using **knitr**

### Bug fixes

- `quadratic_form` now computes the vector product with the transpose _and_
  conjugate of the vector, i.e., the Hermitian of the vector. Also added small
  speed up using `crossprod` function.
- `sqrt_matrix` did not work correctly for singular matrices (zero eigenvalue).
  Fixed issue with numerical precision errors testing for equality to zero. Now
  throws an error if matrix is not of full rank and the inverse is required.

## v0.2.2 (April 2015)

### New

- `fill_hermitian()` is now a public function (and added tests)
- added `foreca.EM.E_and_M_step` as a wrapper for `foreca.EM.E_step` followed
  by `foreca.EM.M_step`.
- add a `TRUE/FALSE` "normalized" attribute to objects of class 
  mvspectrum. This speeds up computation and checks significantly 
  since `check_mvspectrum_normalized`
  only needs to check the attribute, rather than computing the sum and
  comparing it to identity matrix.
- removed `"lag window"` option for `mvspectrum` since it does not work
  well with `normalize_mvspectrum`.
- added a `plot.mvspectrum` S3 method

### Bug fixes

- `normalize_mvspectrum()` normalizes by left and right multiplication of 
  inverse square root of frequency total aggregate estimate.  This fixes
  the issue with different results of normalization based on multivariate vs.
  univariate spectra estimation.
- removed a `print()` statement when running `foreca()` (displayed
  `Omega` scores of the final ForeCs)
- `sqrt_matrix` threw an error if input matrix had complex-valued
  eigen-values (since it checked for negative values).  Fixed now.
- specify `nrow` in `diag()` if `n.comp=1` in `foreca.multiple_weightvectors`
  (otherwise it generated non-comformable arrays error).

### Minor changes / improvements

- fixed real/imaginary problem with the eigenvalues of Hermitian matrices
  in `test_mvspectrum()`
- change tolerance level in EM convergence to `1e-6` (see
  `complete_algorithm_control()`)

## v0.2.0 (Jan 2015)
A bug-fix release and more modular, less repetitive coding under the hood;
results in improved performance of the main algorithms.

Main notable change for users: to specify spectrum and entropy estimation use
`spectrum.control` and `entropy.control`.  Otherwise no relevant visible
user-interface changes.

Also review the manual; it has been _very_ thoroughly reviewed.

### New

- a couple of new functions for more modular code and easier testing:
    * `sqrt_matrix`
    * `complete_entropy_control`
    * `complete_spectrum_control`
    * `complete_algorithm_control`
    * `check_whitened`
    * `check_mvspectrum_normalized`
    * `weightvector2entropy_wcov`
    * `mvpgram`
- a `print.foreca` S3 method
- `Omega` and several `foreca.*` functions changed arguments:
    * `spectrum.conrol = list(...)` is the new way to specify `spectrum.method`,
      `smoothing`.
    * `entropy.control = list(...)` is the new way to specify `entropy.method`,
      `threshold`, `prior.weight`.
- made `"mvfft"` default for spectrum estimation, using `mvfft` in R. This
  avoids the requirement to have **sapa** or **astsa** installed.
- general `foreca.one_weightvector` and `foreca.multiple_weightvectors` wrappers
  for more modular and less repititve coding.
- **By default** entropy is smoothed by a mixture with a uniform prior
  distribution with `prior.weight = 1e-03` in order to avoid `log(0)` throughout
  the computations. If you don't want this, you have to explicitly specify
  `prior.weight = 0` in the `entropy.control` argument.
- formally added tests using the **testthat** package
- added list of all available `spectrum.method`s for estimation of the
  spectrum/spectral density in the `complete_spectrum_control` help page.
- all `foreca.*()` functions only accept whitened time series `U`, not `series`.
  Only `foreca()` directly accepts the original (unwhitened) `series`.  Use `U
  <- whiten(series)$U` to obtain the whitened series.

#### Removed

- `foreca.EM`: use `foreca(..., algorithm.type = "EM")` directly.
- dependency on R packages: 
    - **R.utils**: `R.utils::wrap` got replaced by `base::aperm`.
    - **sapa** and **astsa**: in its basic form the **ForeCA** package now runs
      in base R! However, it is still highly recommended to use either the
      **sapa** or **astsa** package (users can use their algorihms via the
      `method` argument in several functions.)
- `spectral_entropy` now only works with a spectral density input `f.U`; not
  with `series` or `spectrum.estimate`.

### Bug fixes

- `whiten()` (thanks to Bjoern Weghenkel for pointing this out):
    * forgot to center U; if data was centered to start with, then this didn't
      affect results.
    * fixed dewhitening and whitening matrices
- `initialize_weightvector` used the minimum Omega vector, not maximum, for
  `method = "max"`.

### Minor changes/improvements

- thourough revision of documentation:
    * better explanations
    * fixed typos or code / documentation mismatch
    * more concise (hopefully)
- `mvspectrum`: the smooth univariate spectrum estimate (`smoothing = TRUE`)
   uses an exponential distribution with a logarithmic link function in the
   `mgcv::gam` function.
- `discrete_entropy`: 
    * The uniform distribution is now added using a mixture type model, rather
      than an absolute addition to original distribution and then renormalizing.
      Thus the `prior.weight` is now between 0 and 1, not just greater than 0.
      can be done just with the `prior.weight` argument.
    * Only `''MLE''` is a valid `method` now.  If you want to use `''smoothed''`, then this
- lower and upper limit arguments for `continuous_entropy` changed from `a` and
  `b` to `lower` and `upper`.
- `eigen()` calls got `symmetric = TRUE`.  About 3x faster.
- The random methods in `initialize_weightvector` have the `r` prefix, i.e.,
  `"rnorm"` instead of `"norm"`.  Same for `"cauchy"` and `"unif"`.
- `foreca.EM.opt_weightvector` changed to `foreca.EM.one_weightvector`.
- the trace plots of the weights are always smooth curves (and don't jump
  betweeen  +/- 1 times the weightvector).

* * *

## v0.1

- changed underscore (`_`) in argument names to dot (`.`). E.g., `max_iter` to
  `max.iter`
- cleaned up code for better readability
  - changed `=` to `<-` assignment operator (big thanks to `tidy.source()`)
  - removed unnecessary code (thanks `checkUsage()`)
- cleaned up `NEWS` file and edited to conform to proper markdown format
- changed `method` argument in `foreca()` to `algorithm.type`
- moved function to initialize a weightvector from the `EM` class, to its own
  function (`initialize_weightvector()`)
- replaced AR spectrum estimation to `"burg"` in `spec.ar()`
- moved `tol`, `nstart`, and `max.iter` in `foreCA.EM()` into a `control` list
  (where `nstart` became `num.starts`)
- improved display of `plot.foreca.EM.opt_weightvector`

### Bug fixes

- fix bug in `mvspectrum2wcov()`
- fix bug in `mvspectrum()` (set `detrend = FALSE` and `fast = FALSE` in
  `astsa::mvspec`)
- make all spectral estimate functions return the same number of frequencies
  (`T/2` +/- 1 depending on even/odd sample size)
- fix bug in `fill_symmetric()` (double counting diagonal; only affected `SDF`
  type estimation)


## v0.0.9

- changed capitalized ForeCA names to lowercase (except for abbreviations such
  as `EM` or `MLE`). E.g., `ForeCA.EM` to `foreca.EM`; 
- changed `foreca.one_weightvector()` to `foreca.EM.opt_weightvector()`


## v0.0.8.1

- added many additional functions in the package, including the main algorithm
  `ForeCA.EM`
- changed to Roxygen2 documentation


## v0.0.1 (initial release)

- base functions to estimate (spectral) entropies and Omega for (multivariate)
  time series
- first draft of documentation
- simple examples in help files

First version 0.0.1 written by Georg M. Goerg on May 14, 2012.

# Bugs & feature requests

* check what is the best way to store the 3D array spectrum
   - frequency last or first?
   - `data.table` package?
* include more spectrum estimators
* include a continuous estimator of spectral entropy; can be used, e.g., to compute entropy for a fitted AR spectrum
* compressed sensing type of sparsity in the spectrum; currently only by a heuristic thresholding rule
* nice plotting for 3D spectra?
