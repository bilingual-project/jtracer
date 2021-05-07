# create jTRACE language
jt_language <- function(
  phonemes,
  language_name = NULL,
  output_path = NULL
){
  if(is.null(output_path)) output_path <- paste0(getwd(), "/language_", tolower(language_name), ".jt")
  
  header <- paste0(
    "<?xml version='1.0' encoding='UTF-8'?><phonology xmlns='http://xml.netbeans.org/examples/targetNS'\nxmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'\nxsi:schemaLocation='http://xml.netbeans.org/examples/targetNS ",
    "file:C:\\Users\\", Sys.info()[8], "\\Documents\\jtrace-a64\\jtrace-a64/Schema/jTRACESchema.xsd'>"
  )
  language_name <- paste0("<languageName>", language_name, "</languageName>")
  header_2 <- paste0("<phonemes>\n")
  
  body <- phonemes %>%
    clean_names() %>% 
    mutate(allophones = tolower(allophones)) %>% 
    drop_na() %>% 
    rename(grd = cons) %>% 
    relocate(symbol, duration, allophones, burst, voi, grd, acu, diff, voc, pow) %>% 
    pivot_longer(
      -c(symbol, duration, allophones),
      names_to = "feature",
      values_to = "value"
    ) %>% 
    expand_grid(score = 1:9) %>% 
    mutate(score_lgl = as.numeric(score==value)) %>% 
    pivot_wider(names_from = score, values_from = score_lgl) %>% 
    select(-value) %>% 
    pivot_wider(names_from = feature, values_from = 5:13) %>% 
    split(., .$symbol) %>% 
    map_chr(function(x){
      paste0(
        "<phoneme>\n",
        "\t<symbol>", unique(x$symbol), "</symbol>\n",
        "\t<features>", paste0(paste0(x[1,4:66], ".0"), collapse = " "), " </features>\n",
        "\t<durationScalar>", paste0(rep(unique(x$duration), 7), collapse = " "), " </durationScalar>\n",
        "\t<allophonicRelations>", paste0(rep(unique(x$allophones), length(unique(p$symbol))), collapse = " "), " </allophonicRelations>\n",
        "</phoneme>",
        sep = "",
        collapse = ""
      )
    }) %>% 
    unlist() %>% 
    paste0(collapse = "\n", sep = "")
  
  footer <- "</phonemes>\n</phonology>"
  write_lines(c(header, language_name, header_2, body, footer), file = output_path)
}