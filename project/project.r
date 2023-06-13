##########################
# BAIXA OS DADOS
##########################
install.packages("Rtools")
install.packages("remotes")
install.packages("nnet")
install.packages('car')

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
library(nnet)
require(car)

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
# Análise Exploratória
##########################

# Transforma variáveis de caractere para factor
  # character_vars <- lapply(dados, class) == "character"
  # dados[, character_vars] <- lapply(dados[, character_vars], as.factor)

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
# Regressão Logistica multinomial
##########################
##Box plot com ggplot
#ggplot(dados, aes(y = IDADEanos)) +
#  geom_boxplot()
##Verificando a correlação
#cor(cars$speed,cars$dist)

#Distribuição é normal?
#shapiro.test(cars$Price)

#multinom_model <- multinom( ~ ., dados = tissue)


df <- data.frame(
  CAUSABAS = dados$CAUSABAS,
 idade = dados$IDADEanos,
 munRes = dados$munResNome,
 sexo = dados$SEXO,
 racaCor = dados$RACACOR
                 )


levels(df)
psych::pairs.panels(df)
cor(df)
m <- lm (as.numeric(CAUSABAS) ~ sexo + idade + munRes  ,data = df)
car::vif(m)



#Criando e testando o modelo
#Etapa 1

df <- df%>%filter(!idade == '')%>%filter(!sexo == '')%>%filter(!munRes == '')%>%filter(!CAUSABAS == '')
df$idade  <- as.numeric(df$idade)

set.seed(123)
train_linha_SIM <- sample(1:nrow(df), 0.8*nrow(df))  # índice da linha dos dados de treinamento
train_dado_SIM <- df[train_linha_SIM, ]  # dados do modelo de treinamento
test_dado_SIM  <- df[-train_linha_SIM, ]

train_dado_SIM<-train_dado_SIM%>%
  filter(!is.na(idade))

train_dado_SIM<-train_dado_SIM%>%
  filter(!is.na(sexo))

train_dado_SIM<-train_dado_SIM%>%
  filter(!is.na(munRes))

train_dado_SIM<-train_dado_SIM%>%
  filter(!is.na(CAUSABAS))

model_SIM <- glm(sexo~CAUSABAS+idade+racaCor, data = train_dado_SIM, family = "binomial")
summary(model_SIM)

#Avaliação do modelo
head(predict(model_SIM, type = "response"))
train_dado_SIM_resp<-predict(model_SIM, type = "response")

trn_pred_SIM <- ifelse(predict(model_SIM, type = "response") > 0.5, "Yes", "No")
head(trn_pred_SIM)

train_dado_SIM<-train_dado_SIM%>%
  mutate(sexo_ = ifelse(sexo=="Masculino","Yes","No"))

trn_tab_SIM <- table(predicted = trn_pred_SIM, actual = train_dado_SIM$sexo_[1:7713])
trn_tab_SIM

confusionMatrix(trn_tab_SIM, positive = "Yes")

test_prob_SIM <- predict(model_SIM, newdata = test_dado_SIM, type = "response")
test_roc_SIM <- roc(test_dado_SIM$sexo ~ test_prob_SIM, plot = TRUE, print.auc = TRUE)

