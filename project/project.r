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

#Junta a base de dados de municípios à base de mortalidade
dados <- merge(dados, municipios, by.x = 'CODMUNRES', by.y = 'CODMUNIC')

# Ajusta idade
# Transforma todas as idades menores ou iguais a 400 em 1 ano,e remove 400 das idades acima de 400.
# Com isso, temos normalizadas as idades, de 1 a 100 anos.
dados <- transform(dados, IDADE2 = ifelse(as.numeric(as.character(IDADE)) <= 400, 1, as.numeric(as.character(IDADE))))
dados <- transform(dados, IDADE2 = ifelse(IDADE2 > 1 & IDADE2 < 500, IDADE2 - 400, 100))

# Ajusta Sexo
# Transforma os valores: 0 para I, de Indefinido; 1 para M, de Masculino; e 2 para F, Feminino.
levels(dados$SEXO) <- c("I", "M", "F")

# Ajusta Estado Civil
levels(dados$ESTCIV) <- c("Solteiro", "Casado", "Viuvo", "Separado judicialmente", "União estável", "Ignorado")

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
boxplot(dados$IDADE2)

# Gera o plot das colunas idade e racacor, com amostra de 100
select(dados, SEXO, RACACOR) %>%
  sample_n(100) %>%
  collect() %>%
  plot()

# Analise exploratória do SEXO
plot(dados$SEXO)

# Análise exploatória da Idade
plot(dados$IDADE2)

# Análise exploratória do estado cívil
plot(dados$ESTCIV)
