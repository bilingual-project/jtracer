
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
lex <- jtracer::jtrace_get_lexicon(lexicon = "slex")
head(lex)
#>       phonology      frequency
#> 1    ^                   23248
#> 2    ^br^pt                 37
#> 3    ^dapt                  71
#> 4    ^d^lt                  50
#> 5    ^gri                  264
#> 6    ^lat                   50
```
