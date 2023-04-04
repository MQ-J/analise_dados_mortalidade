library(ggplot2)
library(dplyr)
library(DAAG)

data("cars")
View(cars)
ggplot(cars, aes(speed,dist))+
  geom_point()
#Podemos obter a reta de regressão
stop_dist_model = lm(dist ~ speed, data = cars)
stop_dist_model
stop_dist_model$coefficients
stop_dist_model$residuals
summary(stop_dist_model)
#Predição de valores novos
predict(stop_dist_model, newdata = data.frame(speed = 8))
#Para múltiplos valores
predict(stop_dist_model, newdata = data.frame(speed = c(8, 21, 50)))
#Não é suficiente fazer só isso!!!!!

#Para um modelo é preciso fazer todas as análises!

#Box plot com ggplot
ggplot(cars, aes(y = speed)) +
  geom_boxplot()

ggplot(cars, aes(y = dist)) +
  geom_boxplot()

#Distribuição é normal?
shapiro.test(cars$speed)
shapiro.test(cars$dist)


#Verificando a correlação
cor(cars$speed,cars$dist)

modelo_cars <- lm(dist ~ speed, data=cars)
#PESO=81.589*SEMAGESTAC + 97.577

summary(modelo_cars)


#Criando e testando o modelo
#Etapa 1
set.seed(100)
train_linha_cars <- sample(1:nrow(cars), 0.8*nrow(cars))  # índice da linha dos dados de treinamento
train_dado_cars <- cars[train_linha_cars, ]  # dados do modelo de treinamento
test_dado_cars  <- cars[-train_linha_cars, ]


#Padronizando os dados -não precisa..só para demonstrar
#cars<- as.data.frame(scale(cars))


# Etapa 2: construir o modelo de treinamento dos dados
lm_model_cars <- lm(dist ~ speed, data=train_dado_cars)  # construção do modelo
#Outra forma
#glm_model_cars <- glm(dist ~ speed, data = train_dado_cars, family = "gaussian")
#summary(glm_model_cars)

dist_pred_cars <- predict(lm_model_cars, test_dado_cars)  # predição da distância
#Etapa 3 - análise do modelo
#verificar se p-value é significativo e comparar r-squared com o modelo original
summary (lm_model_cars)
#Etapa 4: calcular a precisão da previsão e as taxas de erro
pred_real_cars <- data.frame(cbind(real_cars=test_dado_cars$dist, predicao_cars=dist_pred_cars))
acuracia_corr_cars <- cor(pred_real_cars)
head(pred_real_cars)
#taxas de erro
min_max_acuracia_cars <- mean(apply(pred_real_cars, 1, min) / apply(pred_real_cars, 1, max))  
mape_cars <- mean(abs((pred_real_cars$predicao - pred_real_cars$real))/pred_real_cars$real)
