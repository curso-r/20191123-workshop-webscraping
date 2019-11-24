library(magrittr)
library(httr)
library(rvest)
library(tidyverse)
library(janitor)

# Ler os menus do site e salvar no computador
for(i in 0:25){
  httr::GET(
    paste0('http://example.webscraping.com/places/default/index/', i),
    write_disk(paste0("site/static/slides/menus/", i, ".html"), TRUE)
  )
  Sys.sleep(2)
}

# Iterar nos arquivos através de seus nomes
menus <- list()
for(i in 0:25) {
  file <- paste0("site/static/slides/menus/", i, ".html")
  
  nodes <- file %>%
    read_html() %>%
    xml_find_all("//td//a")
  
  tabela <- tibble(
    pais = xml_text(nodes),
    links = xml_attr(nodes, "href")
  )
  
  menus[[i+1]] <- tabela
}

# Alternativa: iterar nos arquivos através de list.files
for(file in list.files("site/static/slides/menus", full.names = TRUE)) {
  
  nodes <- file %>%
    read_html() %>%
    xml_find_all("//td//a")
  
  tabela <- tibble(
    pais = xml_text(nodes),
    links = xml_attr(nodes, "href")
  )
  
  print(tabela)
}

# Alternativa 2: tudo na base do pipe
"site/static/slides/menus" %>%
  list.files(full.names = TRUE) %>%
  map(read_html) %>%
  map(xml_find_all, "//td//a") %>%
  map(~tibble(
    pais = xml_text(.x),
    links = xml_attr(.x, "href")
    )
  ) %>%
  bind_rows()

# Juntar todas as tabelas de menus
paises <- menus %>%
  bind_rows() %>%
  mutate(links = paste0("http://example.webscraping.com", links))

# Baixar cada país iterando nas linhas da tabela
for (i in 1:252) {
  
  httr::GET(
    paises[i,]$links,
    write_disk(
      paste0("site/static/slides/paises/", paises[i,]$pais, ".html"),
      TRUE
    )
  )
  Sys.sleep(3)
}

# Juntar todos os países depois de parseá-los
files <- list.files("site/static/slides/paises/", full.names = TRUE)
dados <- list()
for (i in 1:91) {
  
  tabela <- files[i] %>%
    read_html() %>%
    xml_find_all("//table") %>%
    html_table() %>%
    extract2(1) %>%
    select(-X3) %>%
    pivot_wider(names_from = X1, values_from = X2) %>%
    clean_names() %>%
    select(country, everything())
  
  dados[[i]] <- tabela
}
dados %>%
  bind_rows() %>%
  View()

# Login no site
pag <- GET("http://example.webscraping.com/places/default/user/login?_next=/places/default/index")
chave <- pag %>%
  read_html() %>%
  xml_find_all("//input[@name='_formkey']") %>%
  xml_attr("value")

body <- list(
  "email" = "asdf@asdjfk.com",
  "password" = "1234",
  "_next" = "/places/default/index",
  "_formkey" = chave,
  "_formname" = "login"
)

teste <- POST(
  "http://example.webscraping.com/places/default/user/login?_next=/places/default/index",
  body = body, encode = "form", write_disk("teste.html")
)
