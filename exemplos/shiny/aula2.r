library(dplyr)


#Neste exemplo as tabelas foram construídas. Em uma situação real basta obter os dados a partir do banco de dados


estado_table <- 
  data.frame(key=c("CA", "NY", "WA", "ON", "QU"),
             nome=c("California", "Nova York", "Washington", "Ontario", "Quebec"),
             pais=c("EUA", "EUA", "EUA", "Canada", "Canada"))


mes_table <- 
  data.frame(key=1:12,
             desc=c("Jan", "Feb", "Mar", "Abr", "Mai", "Jun", "Jul", "Ago", "Set", "Out", "Nov", "Dez"),
             quarter=c("Q1","Q1","Q1","Q2","Q2","Q2","Q3","Q3","Q3","Q4","Q4","Q4"))


prod_table <- 
  data.frame(ID=c(1, 2, 3),
             descricao=c("impressora", "Tablet", "Notebook"),
             preco=c(825, 1570, 5120))


#Função para gerar a tabela vendas
#Em uma situação real basta fazer uma consulta SQL
gen_vendas <- function(no_of_recs) {
  
  # Gera a amostra randomicamente
  loc <- sample(estado_table$key, no_of_recs,replace=T, prob=c(2,2,1,1,1))
  time_mes <- sample(mes_table$key, no_of_recs, replace=T)
  time_ano <- sample(c(2012, 2013), no_of_recs, replace=T)
  prod <- sample(prod_table$ID, no_of_recs, replace=T, prob=c(1, 3, 2))
  unidade <- sample(c(1,2), no_of_recs, replace=T, prob=c(10, 3))
  montante <- unidade*prod_table[prod,]$preco
  
  vendas <- data.frame(mes=time_mes,
                       ano=time_ano,
                       loc=loc,
                       prod=prod,
                       unidade=unidade,
                       montante=montante)
  
  # Sort the records by time order
  vendas <- vendas[order(vendas$ano, vendas$mes),]
  row.names(vendas) <- NULL
  return(vendas)
}


#Criando o fato vendas


vendas_fato <- gen_vendas(500)%>%
  inner_join(prod_table, by=c("prod"="ID"))


# Imprimindo os primeiros registros
head(vendas_fato)


# Construindo o cubo
receita_cubo <- 
  tapply(vendas_fato$montante, 
         vendas_fato[,c("prod", "mes", "ano", "loc")], 
         FUN=function(x){return(sum(x))})


receita_cubo


dimnames(receita_cubo)


# Operações com o cubo: Slice
# cubo em Jan, 2012
receita_cubo[, "1", "2012",]
# cubo em Jan, 2012 para o produto 1
receita_cubo[1, "1", "2012",]


receita_cubo[c(1,2),c("1","2","3"), 
             ,
             c("CA","NY")]


apply(receita_cubo, c("ano", "prod"), FUN=function(x) {return(sum(x, na.rm=TRUE))})


#Operações com o cubo: Drilldown
apply(receita_cubo, c("ano", "mes", "prod"), 
      FUN=function(x) {return(sum(x, na.rm=TRUE))})


#Operações com o cubo:Pivot
apply(receita_cubo, c("ano", "mes"), 
      FUN=function(x) {return(sum(x, na.rm=TRUE))})


apply(receita_cubo, c("prod", "loc"),
      FUN=function(x) {return(sum(x, na.rm=TRUE))})

