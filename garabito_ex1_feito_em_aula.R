library(httr)
library(xml2)

# primeiro passo: requisição
req <- GET("http://example.webscraping.com/")

# segundo passo: transformar a requisição em conteúdo html (texto contendo os dados)
html <- read_html(req)
html <- content(req)

#content é uma função em requisição (resultado de GET e de POST)

# outro jeito de fazer: html <- read_html("http://example.webscraping.com/")

# terceiro passo: decidir o que é que eu quero analisar ou aonde podar a árvore

# passo 3.1: chutar seletores (xpath ou css)

# primeiro chute: //*[@id="results"]/table/tbody/tr[1]/td[2]/div/a (está errado)

# opcao 1: seguindo o chrome
xml_find_all(html, "//*[@id='results']/table/tr/td/div/a")

# opcao 2: segue o crome até um pedaço e depois pega os filhos no R
divs_filhos_de_td <- xml_find_all(html, "//*[@id='results']/table/tr/td/div") 

xml_children(divs_filhos_de_td)

# opcao 3: encurtar ao máximo a query
tags_a <- xml_find_all(html, "//td//a")

# quarto passo: extrair dos nós que eu tenho interesse as informações relevantes

# passo 4.1: pegar os links

links <- unlist(xml_attrs(tags_a))

links <- xml_attr(tags_a, "href")

# passo 4.2: pegar os textos

textos <- xml_text(tags_a)

# quinto passo: montar o data.frame

data.frame(
  coluna_link = links,
  coluna_nome_pais = textos
)
