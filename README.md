# O Projeto
A proposta deste projeto é aplicar o CRISP-DM, padrão internacional de mineração de dados, em uma base de dados do Ministério da Saúde do Brasil. O arquivo selecionado para análise contém os registros de mortalidade no Brasil no ano de 2020.

A linguagem de programação utilizada foi a R, devido suas bibliotecas de análise de dados.

## Sobre o CRISP-DM
CRISP-DM é o acrônimo para CRoss Industry Standard Process for Data Mining, que em tradução direta pode ser entendido como um padrão de processos de mineração de dados entre indústrias.

Ele especifica os passos necessários para o aproveito de dados a fim de se obter informações e conhecimento sobre eles.

Este padrão se constitui em seis fases:
- Entendimento do negócio
- Entendimento dos dados
- Preparação de dados
- Modelagem
- Avaliação
- Implantação

## Entendimento do negócio
O Ministério da Saúde brasileiro desenvolveu o SIM, Sistema de Informação sobre Mortalidade, que unifica declarações de óbito emitidas no país desde 1979. Seu conjunto de informações serve de apoio para o desenvolvimento de políticas públicas com respeito a saúde da população.

## Entendimento dos dados
Extraímos os dados de mortalidade geral em 2020, que conta com informações sobre a causa do óbito, local de ocorrência, e características fisícas e socioeconômicas dos indivíduos de forma anonimizada.

Todos os óbitos registrados na base são do estado de São Paulo, não fetais.

## Preparação de dados

### Identificando os municípios
Durante a preparação dos dados, Foi feita junção da base de mortalidade com uma base de dados sobre os municípios brasileiros. A ação foi necessária pois na base de mortalidade os municípios são referenciados pelo seu código, e a partir da junção foi possível identificá-los.

### Remoção de colunas
Muitas colunas da base de mortalidade vieram com valores NA, ou não eram relevantes para a análise do projeto. A remoção destas colunas foi feita usando a função `subset`.
```R
dados <- subset(dados, select = -c(CONTADOR, CODIFICADO, ESTABDESCR, FONTESINF, NUDIASOBIN, FONTES, MORTEPARTO, NUDIASINF, STCODIFICA, TPNIVELINV, VERSAOSCB, VERSAOSIST))
```

### Gerenciamento de dados ausentes
- apagar a linha?
- ou substituir valor?



### Padronização dos dados
- IDADE
````R
dados <- transform(dados, IDADE2 = ifelse(as.numeric(as.character(IDADE)) <= 400, 1, as.numeric(as.character(IDADE))))
dados <- transform(dados, IDADE2 = ifelse(IDADE2 > 1 & IDADE2 < 500, IDADE2 - 400, 100))
````

## Modelagem

### Análise exploratória da Idade
````R
plot(as.factor(dados$IDADEanos))
````
![image](https://github.com/MQ-J/analise_dados_mortalidade/assets/61765516/dbacae94-dab0-42fe-a74b-4f9a427c17ad)

### Análise exploratória do estado cívil
````R
````

## Avaliação

## Implantação

# Referências

- [Mortalidade Geral 2020](https://opendatasus.saude.gov.br/dataset/sim-1979-2019/resource/c622b337-a522-4243-bf19-6c971e809cff)
- [Estrutura do SIM](https://diaad.s3.sa-east-1.amazonaws.com/sim/Mortalidade_Geral+-+Estrutura.pdf)
- [Capítulos da Classificação Estatística Internacional de Doenças e
Problemas Relacionados à Saúde / CID-10](https://www.saude.sc.gov.br/index.php/informacoes-gerais-documentos/video-e-webconferencias/webconferencias-2010/treinamento-sim/3659-manual-mortalidade-2007/file)
