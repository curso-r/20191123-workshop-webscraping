tags_table <- xml_find_all(html, "//table")

tabela <- tags_table %>% 
  rvest::html_table()

tabela[[1]]