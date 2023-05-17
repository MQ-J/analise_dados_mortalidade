##########################
# BAIXA OS DADOS
##########################

install.packages("remotes")
remotes::install_github("rfsaldanha/microdatasus", force=TRUE)

library(microdatasus)

dados <- fetch_datasus(year_start = 2020, year_end = 2020, uf = "SP", information_system = "SIM-DO")

# Posix não aguenta este processamento
# dados <-process_sim(dados)

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

# Junta a base de dados de municípios à base de mortalidade
dados <- merge(dados, municipios, by.x = 'CODMUNRES', by.y = 'CODMUNIC')

# Ajusta idade
dados <- transform(dados, IDADE2 = ifelse(as.numeric(as.character(IDADE)) <= 400, 1, as.numeric(as.character(IDADE))))
dados <- transform(dados, IDADE2 = ifelse(IDADE2 > 1 & IDADE2 < 500, IDADE2 - 400, 100))


##########################
# Modelagem
##########################

# Verifica outlier
boxplot(dados$IDADE2)

#Gera o plot das colunas idade e racacor, com amostra de 100
select(dados, IDADE2, RACACOR) %>%
  sample_n(100) %>%
  collect() %>%
  plot()

#Analise exploratória
summary(dados)
