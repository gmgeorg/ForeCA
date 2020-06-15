# ForeCA R package

[![](https://cranlogs.r-pkg.org/badges/ForeCA)](https://cran.r-project.org/package=ForeCA)


**ForeCA** implements *Forecastable component analysis* in R.  For details on algorithm & methodology see [*Forecastable Component Analysis*, JMLR, Goerg (2013)](http://proceedings.mlr.press/v28/goerg13.pdf).


**In a nutshell:** *ForeCA* finds linear combinations
of multivariate time series that are most forecastable, where forecastability is measured by the spectral entropy of the resulting signal (linear combination of input).


## Installation

**UPDATE**: As of 2020-06-09 **ForeCA** has been removed from CRAN, because
the **ifultools** / **sapa** dependecies are no longer maintained.  I am working
on an update to **ForeCA** to not rely on these packages, but only rely on **astsa**
for multivariate specturm estimation. See `NEWS.md` for details.

In the meantime you can install the ForeCA package directly from
github as
```{r}
library(devtools)
devtools::install_github("gmgeorg/ForeCA")
```

**Temporarily not working**

You can install the stable version on
[CRAN](https://cran.r-project.org/package=ForeCA):

```r
install.packages('ForeCA')
```

## Usage

The workhorse function is `ForeCA::foreca()` which works just like the built-in `princomp` function for PCA. 

```{r}
library(ForeCA)
citation("ForeCA")
```

For a tutorial on how to use `foreca()` and the entire **ForeCA** suite of functions see the [introductory vignette](https://CRAN.R-project.org/package=ForeCA/vignettes/Introduction.html) on CRAN. 

## References

* **ForeCA references & applications in the literature** (non-exhaustive; see here for [full list of ForeCA citations](https://scholar.google.com/scholar?client=ubuntu&channel=fs&oe=utf-8&um=1&ie=UTF-8&lr&cites=5674198772479433271))

  * Very interesting application of ForeCA to historical time series data of temperature/climate to extract predictable climate signals. [Fischer, Matt. (2016). *Predictable components in global speleothem δ18O*. Quaternary Science Reviews. 131. 380-392. 10.1016/j.quascirev.2015.03.024.](https://www.researchgate.net/publication/275953571_Predictable_components_in_global_speleothem_d18O)
  * ForeCA's forecastability measure, spectral entropy of a time series, can be useful as a feature to characterize/visualize/predict performance of different algorithms applied to a set of time series. [Kang, Yanfei & Hyndman, Rob & Smith-Miles, Kate. (2017). *Visualising forecasting algorithm performance using time series instance spaces*. International Journal of Forecasting. 33. 345-358. 10.1016/j.ijforecast.2016.09.004.](https://isidl.com/wp-content/uploads/2017/06/E3999-ISIDL.pdf)


* **Cross-validated & SO posts** (non-exhaustive)

    * [How to determine forecastability of time series](https://stats.stackexchange.com/questions/126829/how-to-determine-forecastability-of-time-series)


 * **Blog posts** (by others)

   * [Stock Forecasting with Machine Learning - Are Stock Prices Predictable?](http://www.anlytcs.com/2016/04/stock-forecasting-with-machine-learning.html) (2016/04/20)
   * [Are stocks predictable?](http://fastml.com/are-stocks-predictable/) (2014/02/20)
   

