#' @title Phoneme inventory
#' @description A dataset containing an extensive set of phonemes that can be transcribed
#' from IPA or SAMPA to jTRACE notation using approximations. These dimensions are
#' the same used in jTRACE \insertCite{strauss2007jtrace}{jtracer}.
#'  
#' @docType data
#' @usage data(phonemes)
#' @format A data frame with 74 rows and 7 variables:
#' \describe{
#'   \item{id}{Individual phoneme numeric identifier}
#'   \item{ipa}{Phoneme symbol in IPA notation}
#'   \item{trace}{Phoneme symbol in jTRACE notation}
#'   \item{description}{Rough classification of the phoneme}
#'   \item{is_english}{Is this phoneme present in English?}
#'   \item{is_spanish}{Is this phoneme present in Spanish?}
#'   \item{is_catalan}{Is this phoneme present in Catalan?}
#'   \item{type}{Is the phoneme a consonant or a vowel?}
#'   \item{pow}{Power dimension \insertCite{mcclelland1986trace}{jtracer}}
#'   \item{voc}{Vocalic dimension \insertCite{jakobson1951preliminaries}{jtracer}}
#'   \item{dif}{Diffusiveness dimension \insertCite{jakobson1951preliminaries}{jtracer}}
#'   \item{acu}{Acuteness dimension \insertCite{jakobson1951preliminaries}{jtracer}}
#'   \item{con}{Consonantal dimension \insertCite{jakobson1951preliminaries}{jtracer}}
#'   \item{voi}{Voicing dimension \insertCite{jakobson1951preliminaries}{jtracer}}
#'   \item{bur}{Burst dimension \insertCite{mcclelland1986trace}{jtracer}}
#' }
#' @usage
#' data("phonemes")
#' @examples
#' data("phonemes")
#' @references
#'  \insertAllCited{}
"phonemes"