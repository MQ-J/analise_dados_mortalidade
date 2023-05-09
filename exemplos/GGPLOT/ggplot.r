library(dplyr)
library(data.table)
library(ff)
system("java -version")
install.packages("sparklyr")
packageVersion("sparklyr")
library(sparklyr)
spark_install("3.3")

sc <- spark_connect(master = "local", version = "3.3")

#Filtra do arquivo
sinasc <- Leitos_2020%>%
  slice_head(n = 50000)

# copia para variável
dados <- copy_to(sc, sinasc)

#mostra no console
dados

#Gera o plot das colunas peso e idademãe, com amostra de 100
select(dados, LEITOS_EXISTENTE, UF) %>%
  sample_n(100) %>%
  collect() %>%
  plot()

#disconecta ? precisa disso ?
spark_disconnect_all()
