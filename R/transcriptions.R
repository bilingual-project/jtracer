#' Transcribe phonology from IPA to jTRACE notation
#' @export ipa_to_jtrace
#' @importFrom mgsub mgsub
ipa_to_jtrace <- function(x){
  y <- mgsub(x, phonemes$ipa, phonemes$trace)
  return(y)
}
