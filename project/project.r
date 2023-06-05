##########################
# BAIXA OS DADOS
##########################
install.packages("Rtools")
install.packages("remotes")


devtools::install_github("danicat/read.dbc")

pkgbuild::check_build_tools(debug = TRUE)
remotes::install_github("rfsaldanha/microdatasus", force = TRUE)


library(microdatasus)

dados <- fetch_datasus(year_start = 2020, year_end = 2020, uf = "SP", information_system = "SIM-DO")

# Posix não aguenta este processamento
dados <-process_sim(dados)
dados <- dados%>%sample_n(10000)
  
##########################
# Preparação de dados
##########################

library(tidyverse)
library(dplyr)
library(caret) # calcula matriz de confusão
library(psych)
library(naivebayes) # executa o algoritmo naive bayes
library(ggplot2) # Para análise exploratória
library(pROC) # Para curva ROC

#Junta a base de dados de municípios à base de mortalidade
dados <- merge(dados, municipios, by.x = 'CODMUNRES', by.y = 'CODMUNIC')

# Ajusta idade
# Transforma todas as idades menores ou iguais a 400 em 1 ano,e remove 400 das idades acima de 400.
# Com isso, temos normalizadas as idades, de 1 a 100 anos.
dados <- transform(dados, IDADE2 = ifelse(as.numeric(as.character(IDADE)) <= 400, 1, as.numeric(as.character(IDADE))))
dados <- transform(dados, IDADE2 = ifelse(IDADE2 > 1 & IDADE2 < 500, IDADE2 - 400, 100))

dados <- subset(dados, select = -c(CONTADOR, CODIFICADO, ESTABDESCR, FONTESINF, NUDIASOBIN, FONTES, MORTEPARTO, NUDIASINF, STCODIFICA, TPNIVELINV, VERSAOSCB, VERSAOSIST))
# Ajusta Sexo
# Transforma os valores: 0 para I, de Indefinido; 1 para M, de Masculino; e 2 para F, Feminino.
levels(dados$SEXO) <- c("I", "M", "F")

# Ajusta Estado Civil
levels(dados$ESTCIV) <- c("Solteiro", "Casado", "Viuvo", "Separado judicialmente", "União estável", "Ignorado")


dados<-dados%>%
  mutate(faixa_idade = ifelse(as.numeric(as.character(IDADEanos)) < 20, "< 20", ifelse(as.numeric(as.character(IDADEanos)) >= 20 & as.numeric(as.character(IDADEanos)) < 30, ">=20 e < 30", ifelse(as.numeric(as.character(IDADEanos)) >= 30 & as.numeric(as.character(IDADEanos)) < 40, ">=30 e < 40", ">=40"))))


## Colunas para remover
# CONTADOR - índice.
# CODIFICADO - Informa se formulario foi codificado
# CRITICA - Dado para controle interno 
# ESTABDESCR - Todas as linhas são NA
# EXPDIFDATA - Todas as linhas são NULL
# ETNIA - Todas as linhas são NULL
# FONTESINF - tudo NA
# FONTINFO - Tudo NULL
# NUDIASOBIN - Tudo NA
# TPASSINA - Tudo NULL
# FONTES - Demais campos de fontes substituem este.
# MORTEPARTO - Não faz parte do escopo da análise.
# NUDIASINF - Tudo NA
# NUMEXPORT - Tudo null
# STCODIFICA - Status de instalação - Irrelevante para a análise
# TIPOACID - Tudo NULL
# TIPOVIOL - Tudo NULL
# TPNIVELINV - Tipo de nível investigador - Irrelevante para a análise
# UFINFORM - Tudo NULL
# VERSAOSCB - Versão do seletor de causa básica - Irrelevante para a análise
# VERSAOSIST - Versão do sistema - Irrelevante para a análise

## Colunas relevantes
# MUNIOCOR - Municipio de ocorrencia do obito
# SEXO - Sexo do falecido


##########################
# Modelagem
##########################

# Verifica outlier
boxplot(dados$IDADE)

# Gera o plot das colunas idade e racacor, com amostra de 100
select(dados, SEXO, RACACOR) %>%
  sample_n(100) %>%
  collect() %>%
  plot()

# Analise exploratória do SEXO (só funciona com variaveis 'factor')
plot(as.factor(dados$SEXO))

# Análise exploatória da Idade
plot(as.factor(dados$IDADEanos))

plot(as.factor(dados$faixa_idade))

# Análise exploratória do estado cívil
plot(as.factor(dados$ESTCIV))

dados$ESTCIV

##########################
# ANALISE EXPLICITA
##########################

plot(as.factor(dados$munResNome))

install.packages("leaflet")

library(leaflet)

m <- leaflet()
m <- addTiles(m)
  
loop_index_1 <- 0
while (loop_index_1 < count(dados)){                       # Run for-loop
  loop_index_1 <- loop_index_1 + 1
  m <- addMarkers(m,
                  lng=as.numeric(dados$munResLon[loop_index_1]),
                  lat=as.numeric(dados$munResLat[loop_index_1]),
                  popup=as.numeric(dados$munResNome[loop_index_1]))
  
}
m

##########################
# ANALISE IMPLICITA
##########################
# Regressão
##########################
#Box plot com ggplot
ggplot(dados, aes(y = IDADEanos)) +
  geom_boxplot()
#Verificando a correlação
cor(cars$speed,cars$dist)

#Distribuição é normal?
shapiro.test(cars$Price)


