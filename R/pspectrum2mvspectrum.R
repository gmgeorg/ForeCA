# # @rdname mvspectrum
# # 
# # @description
# # \code{.pspectrum2mvspectrum} converts the output of \code{\link[psd]{pspectrum}} to a 3D array with
# # frequencies in the first and the spectral density matrix at a given frequency in the latter
# # two dimensions.
# # 
# # @details
# # \code{.pspectrum2mvspectrum} is typically not called by the user, but by
# # \code{\link{mvspectrum}}.
# # 
# # @param pspectrum.output an object of class \code{"amt"} from \code{\link[psd]{pspectrum}}
# # @keywords ts manip

.pspectrum2mvspectrum <- function(pspectrum.output) {
  f.lambda <- pspectrum.output$pspec
  # remove frequency 0
  f.lambda <- f.lambda[pspectrum.output$freq > 0,,]
  attr(f.lambda, "frequency") <- pspectrum.output$freq[pspectrum.output$freq > 0] * pi
  return(f.lambda)
} 