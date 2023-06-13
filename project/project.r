##########################
# BAIXA OS DADOS
##########################
install.packages("Rtools")
install.packages("remotes")
install.packages("nnet")
install.packages('car')


pkgbuild::check_build_tools(debug = TRUE)

devtools::install_github("danicat/read.dbc")

remotes::install_github("rfsaldanha/microdatasus", force = TRUE)


library(microdatasus)

dados <- fetch_datasus(year_start = 2020, year_end = 2020, uf = "SP", information_system = "SIM-DO")

# Posix não aguenta este processamento
dados <-process_sim(dados)
dados <- dados%>%sample_n(100000)
  
##########################
# Preparação de dados
##########################

library(tidyverse)
library(dplyr)
library(caret) # calcula matriz de confusão
library(nnet)
require(car)

library(psych)
library(naivebayes) # executa o algoritmo naive bayes
library(ggplot2) # Para análise exploratória
library(pROC) # Para curva ROC

#Junta a base de dados de municípios à base de mortalidade
dados <- merge(dados, municipios, by.x = 'CODMUNRES', by.y = 'CODMUNIC')

# Remove colunas não usadas
dados <- subset(dados, select = -c(CONTADOR, CODIFICADO, ESTABDESCR, FONTESINF, NUDIASOBIN, FONTES, MORTEPARTO, NUDIASINF, STCODIFICA, TPNIVELINV, VERSAOSCB, VERSAOSIST))

# Ajusta Sexo
# Transforma os valores: 0 para I, de Indefinido; 1 para M, de Masculino; e 2 para F, Feminino.
levels(dados$SEXO) <- c("I", "M", "F")

# Ajusta Estado Civil
levels(dados$ESTCIV) <- c("Solteiro", "Casado", "Viuvo", "Separado judicialmente", "União estável", "Ignorado")

# Cria faixa de idades
dados<-dados%>%
  mutate(faixa_idade = ifelse(as.numeric(as.character(IDADEanos)) < 20, "< 20", ifelse(as.numeric(as.character(IDADEanos)) >= 20 & as.numeric(as.character(IDADEanos)) < 30, ">=20 e < 30", ifelse(as.numeric(as.character(IDADEanos)) >= 30 & as.numeric(as.character(IDADEanos)) < 60, ">=30 e < 60", ">=60"))))


# Transforma para factor todas as variáveis em caractere
character_vars <- lapply(dados, class) == "character"
dados[, character_vars] <- lapply(dados[, character_vars], as.factor)

##########################
# ANOTAÇÕES
##########################
 
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
# ANALISE EXPLORATÓRIA
##########################
 
# Plot do sexo por estado cívil
  # A maoiria das mulheres morre viúva
  # A maioria dos homens morre casado
  select(dados, SEXO, ESTCIV) %>%
   collect() %>%
   plot()

# Morreram mais homens que mulheres
plot(dados$SEXO)

# Análise exploratória do estado cívil
plot(dados$ESTCIV)

# Análise exploratória da raça
plot(dados$RACACOR)

# Causas de morte mais recorrentes:
# coronavírus, infarto, causas não específicadas,
# demais transtornos respiratórios, diabetes,
# neoplasia dos brônquios, infecção urinária,
# AVC e alzhieimer
dados %>% group_by(CAUSABAS) %>% count(sort = TRUE)

# Quantidade de óbitos pelo estado cícvil no sexo masculino - a maioria dos homens morre casado
ggplot(filter(dados, SEXO == 'Masculino'),aes(x=ESTCIV, fill=ESTCIV)) + geom_bar()

# Quantidade de óbitos pelo estado cícvil no sexo feminino - a maioria das mulheres morre viúva
ggplot(filter(dados, SEXO == 'Feminino'),aes(x=ESTCIV, fill=ESTCIV)) + geom_bar()

# Coronavirus
  # Mortes por covid por sexo
  ggplot(filter(dados, grepl("B342", CAUSABAS, fixed = TRUE))[1:20,],aes(x=SEXO, fill=SEXO)) + geom_bar()

# As ocupações que mais registraram mortes em 2020 foram:
  #Aposentados, donas de casa e pedreiros.
  dados %>% group_by(OCUP) %>% count(sort = TRUE)

# Municipios com maiores registros de mortes
dados %>% group_by(munResNome) %>% count(sort = TRUE)
 
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
# Regressão Logistica
##########################

head(dados$faixa_idade) 
summary(dados$faixa_idade)

dados<-dados%>%
  filter(!is.na(IDADEanos))

dados<-dados%>%
  filter(!is.na(dados$faixa_idade))

dadis <-dados %>% 
  filter(!is.na(SEXO))

dados<-dados%>%
  filter(!is.na(OCUP))

dados<-dados%>%
  filter(!is.na(munRes))

dados<-dados%>%
  filter(!is.na(CAUSABAS))

dados<-dados%>%
  filter(!is.na(ESTCIV))

df <- data.frame(
  CAUSABAS = substr(dados$CAUSABAS, 1,1),
  idade = dados$faixa_idade,
  
  sexo = dados$SEXO,
  racaCor = dados$RACACOR,
  estciv = ifelse(dados$ESTCIV=='Viúvo', 'Viúvo', 'Não Viúvo'),
  ocup = dados$OCUP
)

df <- df%>%sample_n(10000)


character_vars <- lapply(df, class) == "character"
df[, character_vars] <- lapply(df[, character_vars], as.factor)

head(df$estciv) 

#Criando e testando o modelo
#Etapa 1

set.seed(145)  # Define uma semente para reproduzibilidade
indice_treinamento <- sample(1:nrow(df), nrow(df) * 0.7)  # 70% dos dados para treinamento
dados_treinamento <- df[indice_treinamento, ]
dados_teste <- df[-indice_treinamento, ]

dados_teste <- dados_teste[dados_teste$ocup %in% dados_treinamento$ocup, ]

summary(df$estciv) 

modelo <- glm(as.factor(estciv) ~., data = dados_treinamento, family = binomial)

summary(modelo)

#Avaliação do modelo
previsoes <- predict(modelo, newdata = dados_teste, type = "response")

dados_teste<-dados_teste%>%
  mutate(resultado = ifelse(estciv=='Não Viúvo',"FALSE","TRUE"))

matriz_confusao <- table(dados_teste$resultado, previsoes > 0.5)
matriz_confusao

acuracia <- sum(diag(matriz_confusao)) / sum(matriz_confusao)
print(acuracia)

sensibilidade <- matriz_confusao[2, 2] / sum(matriz_confusao[2, ])
print(sensibilidade)

especificidade <- matriz_confusao[1, 1] / sum(matriz_confusao[1, ])
print(especificidade)

library(pROC)
roc_curva <- roc(dados_teste$estciv, previsoes)

# Plotar a curva ROC
plot(roc_curva, main = "Curva ROC")
