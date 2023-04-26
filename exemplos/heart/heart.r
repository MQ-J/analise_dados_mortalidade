library(tidyverse)
library(dplyr)
library(caret) # calcula matriz de confusão
library(psych)
library(naivebayes) # executa o algoritmo naive bayes
library(ggplot2) # Para análise exploratória
library(pROC) # Para curva ROC

# PRÉ PROCESSAMENTO, CONHECENDO OS DADOS (e fazendo transformações quando necessário)

#age: idade
#sex: sexo
#cp: tipo de dor no peito (4 valores)
#pressão arterial em repouso
#trestbps: pressão arterial em repouso (em mm Hg na admissão ao hospital)
#chol: colesterol sérico em mg/dl
#fbs: glicemia em jejum > 120 mg/dl (1 = true; 0 = false)
#restecg: resultados eletrocardiográficos em repouso (valores 0,1,2)
#thalach: frequência cardíaca máxima atingida
#exang: angina induzida por exercício
#oldpeak: depressão do segmento ST induzida pelo exercício em relação ao repouso
#slope; a inclinação do segmento ST de exercício de pico
#ca: número de vasos principais (0-3) coloridos por fluorosopia
#thal: tal: 0 = normal; 1 = defeito corrigido; 2 = defeito reversível

# há outlier na idade?
boxplot(heart$age)

str(heart)

#sex, cp, fbs, restecg, exange, slope, ca, thal, and the target são categóricas.

heart<-heart %>%
  mutate_at(c(2,3,6,7,9,11,12,13,14),funs(as.factor))

#Analise exploratória
summary(heart)

#Ou usar:
#heart$target<-as.factor(heart$target)


#heart<-heart[,-c(7,12,13)]


ggplot(heart,aes(sex,target,color=target))+
  geom_jitter()

ggplot(heart,aes(cp,fill= target))+
  geom_bar(stat = "count",position = "dodge")

ggplot(heart, aes(age,fill=target))+
  geom_density(alpha=.5)


pairs.panels(heart[,-14])

#Data partition 0 
set.seed(1234)
index<-createDataPartition(heart$target, p=.8,list=FALSE)
heart_train<-heart[index,]
heart_test<-heart[-index,]
rm(index)

modelnv<-naive_bayes(target~.,data=heart_train)
modelnv

attributes(modelnv)

#Evaluate the model
pred<-predict(modelnv,heart_train)
confusionMatrix(pred,heart_train$target)

print(prop.table(table(heart_train$target)),digits = 2)

pred<-predict(modelnv,heart_test)
confusionMatrix(pred,heart_test$target)

#Fine tune the model:
modelnv1<-naive_bayes(target~.,data=heart_train,
                      usekernel = TRUE)
pred<-predict(modelnv1,heart_test)
confusionMatrix(pred,heart_test$target)

modelnv2<-train(target~., data=heart_train,
                method="naive_bayes",
                preProc=c("center","scale"))
modelnv2

pred<-predict(modelnv2,heart_test)
confusionMatrix(pred,heart_test$target)

#Montando a curva ROC
pred_heart<-predict(modelnv2,heart_test, type = "prob")[, 2]
heart_roc<-roc(heart_test$target ~ pred_heart, plot = TRUE, print.auc = TRUE)


