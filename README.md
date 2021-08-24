
<!-- README.md is generated from README.Rmd. Please edit that file -->

# jtracer

<!-- badges: start -->
<!-- badges: end -->

jtracer provides an R interface to jTRACE, a re-implementation of the
**TRACE** model of spoken word recognition (McClelland & Elman,
[1986](https://www.sciencedirect.com/science/article/pii/0010028586900150))
created by Strauss, Harris & Magnusson
([2007](https://magnuson.psy.uconn.edu/jtrace/)). Using the functions in
this package you can generate the files you need to perform simulations
in jTRACE.

## Installation

You can install it from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("bilingual-project/jtracer")
```

## Installing and launching jTRACE

First, you need to download jTRACE. You do it from R with:

``` r
jtracer::jtrace_install()
```

This will download the jTRACE folder from
<https://magnuson.psy.uconn.edu/jtrace/> into your home directory
(normally Documents) as `.jtrace`. You won’t have to open this folder to
use jtracer. This function will also check if a sufficiently recent
version of Java is up and running (&gt;1.4). If not, it will prompt you
to do it.

Once an appropriate version of Java is up and running, and jTRACE has
been installed, you will be able to launch jTRACE with:

``` r
jtracer::jtrace_launch()
```

## Extracting a lexicon from jTRACE

jTRACE has multiple lexica available to perform simulations. By default,
it offers:

-   biglex\_lr
-   biglex\_lr\_^a
-   biglex901
-   context\_lex
-   empty
-   initial\_lexicon
-   sevenlex
-   slex
-   slex\_pairs

You can import a lexicon from jTRACE as a data frame with
`jtrace_get_lexicon`. For example:

``` r
library(jtracer)
lex <- jtrace_get_lexicon(lexicon = "slex")
head(lex)
#>       phonology      frequency
#> 1    ^                   23248
#> 2    ^br^pt                 37
#> 3    ^dapt                  71
#> 4    ^d^lt                  50
#> 5    ^gri                  264
#> 6    ^lat                   50
```

## Creating a lexicon for jTRACE

The `jtrace_create_lexicon` generates a new lexicon ready to be loaded
to jTRACE and used in simulations. You will only need to provide
phonological forms of the words you wish to include in the lexicon (in
jTRACE notation) and their lexical frequency in the language of interest
(English, Spanish, or Catalan).

### Extracting lexical frequencies

Since lexical frequencies are required to run a simulation, you must do
so before creating your custom lexicon. You can extract the absolute,
relative, or Zipf-transformed lexical frequencies of the words using the
`jtrace_get_frequency` (see example below). You can consult the built-in
dataset `frequencies` to see the complete list of frequencies available
(extracted from the SUBTLEX-UK, SUBTLEX-ESP, and SUBTLEX-CAT databases).
The `language` argument controls that language lexical frequencies
should be looked up into, and the `scale` argument indicates the scale
of the lexical frequencies that should be returned: “frequency\_abs”
(raw counts), “frequency\_rel” (counts per million words), or
“frequency\_zipf” (Zipf-transformed frequencies). Following jTRACE’s
standards, frequencies are computed as counts per million by default.

``` r
my_words <- c("plane", "cake", "tiger", "ham", "seat")
my_freqs <- jtrace_get_frequency(
  word = my_words,
  language = "English",
  scale = c("frequency_rel", "frequency_zipf")
)
head(my_freqs)
#> # A tibble: 5 x 4
#>   word  language frequency_rel frequency_zipf
#>   <chr> <chr>            <dbl>          <dbl>
#> 1 plane English         0.0483           4.58
#> 2 cake  English         0.0804           4.81
#> 3 tiger English         0.0288           4.36
#> 4 ham   English         0.0282           4.35
#> 5 seat  English         0.0767           4.78
```

### Generate jTRACE lexicon

Now we can create a new lexicon, which we will call “custom”:

``` r
my_phons <- c("plEIn", "kEIk", "taIɡ@", "ham", "sit")
jtrace_create_lexicon(
  phonology = my_phons,
  frequency = my_freqs,
  lexicon_name = "answers"
)
#> v Lexicon added as `answers`
```
