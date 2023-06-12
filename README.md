# Mortalidade no Brasil no ano de 2020

A proposta deste projeto é aplicar o ciclo de vida do dado em uma base de dados do Ministério da Saúde do Brasil. A base escolhida para análise contém os registros de mortalidade no Brasil no ano de 2020.

O ciclo de vida do dado, citado anteriormente, diz respeito às fases que um conjunto de dados percorre dentro da ciência de dados. Cada fase deste ciclo é abordada em um capítulo deste relatório.

<p align="center">
  <img src="https://github.com/MQ-J/analise_dados_mortalidade/assets/61765516/cde2974a-a80d-4d9a-acb8-900233792a2d" />
</p>

## Produção
A base de mortalidade geral foi coletada do sistema OpenDataSus, por meio do pacote microdatasus, feito para liguagem R. A outra base, com os municípios brasileiros, foi baixada manualmente do Moodle Câmpus, ambiente virtual de apoio ao ensino presencial e a distância do IFSP.
Os arquvios vieram em formato CSV.

## Armazenamento
Ambas as bases foram armazenadas em datasets da Posit Cloud.

## Transformação
A transformação necessária na base do Ministério da Saúde, como a codificação utilizada, ficou por parte do pacote microdatasus.

## Análise de dados
A fase de análise foi baseada no modelo CRISP-DM, padrão internacional de mineração de dados. CRISP-DM é o acrônimo para CRoss Industry Standard Process for Data Mining, que em tradução direta pode ser entendido como um padrão de processos de mineração de dados entre indústrias.

Ele especifica os passos necessários para o aproveito de dados a fim de se obter informações e conhecimento sobre eles.

Este padrão se constitui em seis fases:
- Entendimento do negócio
- Entendimento dos dados
- Preparação de dados
- Modelagem
- Avaliação
- Implantação

### Entendimento do negócio
O Ministério da Saúde brasileiro desenvolveu o SIM, Sistema de Informação sobre Mortalidade, que unifica declarações de óbito emitidas no país desde 1979. Seu conjunto de informações serve de apoio para o desenvolvimento de políticas públicas com respeito a saúde da população.

### Entendimento dos dados
Extraímos os dados de mortalidade geral em 2020, que conta com informações sobre a causa do óbito, local de ocorrência, e características fisícas e socioeconômicas dos indivíduos de forma anonimizada.

Todos os óbitos registrados na base são do estado de São Paulo, não fetais.

### Preparação de dados

#### Identificando os municípios
Durante a preparação dos dados, Foi feita junção da base de mortalidade com uma base de dados sobre os municípios brasileiros. A ação foi necessária pois na base de mortalidade os municípios são referenciados pelo seu código, e a partir da junção foi possível identificá-los.

#### Gerenciamento de dados ausentes
- apagar a linha?
- ou substituir valor?

#### Padronização dos dados
- IDADE: Todas as idades em dias, meses e de até um ano foram agrupadas na catgoria "até um ano". Demais idades seguem em anos, até agrupar idades maiores ou iguais a 100 em "cem ou mais".

### Modelagem

#### Análise exploratória da Idade

![image](https://github.com/MQ-J/analise_dados_mortalidade/assets/61765516/dbacae94-dab0-42fe-a74b-4f9a427c17ad)

#### Análise exploratória do estado cívil

![image](https://github.com/MQ-J/analise_dados_mortalidade/assets/61765516/5b9fc852-f1f4-458f-826b-d176539ac52e)

### Avaliação

### Implantação

## Descarte

## Referências
### Bases de dados utilizadas
- [Mortalidade Geral 2020](https://opendatasus.saude.gov.br/dataset/sim-1979-2019/resource/c622b337-a522-4243-bf19-6c971e809cff)
- [Municícios brasileiros](https://eadcampus.spo.ifsp.edu.br/pluginfile.php/961605/mod_resource/content/2/municipios.csv)
- [Estrutura do SIM](https://diaad.s3.sa-east-1.amazonaws.com/sim/Mortalidade_Geral+-+Estrutura.pdf)
### Trabalhos semelhantes
- [Capítulos da Classificação Estatística Internacional de Doenças e
Problemas Relacionados à Saúde / CID-10](https://www.saude.sc.gov.br/index.php/informacoes-gerais-documentos/video-e-webconferencias/webconferencias-2010/treinamento-sim/3659-manual-mortalidade-2007/file)
### Ferramentas utilizadas
- [Posit Cloud](https://posit.cloud/): Ambiente de desenvolvimento de modelos e armazenamento de datasets.
- [microdatasus](https://github.com/rfsaldanha/microdatasus): Pacote R para download de arquivos do OpenDataSUS.
- [md2pdf](https://md2pdf.netlify.app/): Conversão do REDME do depositório em um arquivo PDF.
