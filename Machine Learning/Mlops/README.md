# Aula de MLOps: Deploy de Modelo de ML com FastAPI, Swagger, Docker e Frontend

Este projeto demonstra um fluxo completo de deploy de um modelo de classificacao
treinado para prever se um carro de Formula 1 fara pit stop na proxima volta.

A aula cobre:

1. Exposicao do modelo treinado em uma API REST.
2. Swagger automatico para documentar e testar a API.
3. Container Docker para a API de inferencia.
4. Frontend em container Nginx conectado a API pela rede do Docker Compose.

## Estrutura dos arquivos

```text
.
|-- Aula_Classificacao.ipynb      # notebook de treino/explicacao
|-- rf_model.joblib               # modelo treinado serializado
|-- rf_model.pkl                  # mesmo modelo em formato pkl
|-- main.py                       # API FastAPI
|-- index.html                    # frontend HTML/CSS/JS
|-- nginx.conf                    # proxy do frontend para a API
|-- Dockerfile                    # imagem da API
|-- docker-compose.yml            # API + frontend
|-- requirements.txt              # dependencias Python
|-- examples_api_calls.py         # chamadas de exemplo em Python
`-- README.md                     # roteiro da aula
```

## Arquitetura

```text
Navegador
   |
   | http://localhost:3000
   v
Frontend Nginx
   |
   | /api/* dentro da rede Docker
   v
API FastAPI
   |
   | joblib.load(MODEL_PATH)
   v
rf_model.joblib / rf_model.pkl
```

Tambem e possivel acessar a API diretamente em `http://localhost:8000`.

## Portas da aplicacao

| Servico | URL |
|---|---|
| Frontend | http://localhost:3000 |
| API | http://localhost:8000 |
| Swagger da API | http://localhost:8000/docs |
| Swagger via frontend/proxy | http://localhost:3000/docs |
| Health check | http://localhost:8000/health |

## Modelo

O modelo carregado e um `RandomForestClassifier` com 15 features treinado na ultima aula:

```python
FEATURE_ORDER = [
    "Driver",
    "LapNumber",
    "Compound",
    "Stint",
    "TyreLife",
    "Position",
    "LapTime (s)",
    "Race",
    "Year",
    "LapTime_Delta",
    "Cumulative_Degradation",
    "PitStop",
    "RaceProgress",
    "Normalized_TyreLife",
    "Position_Change",
]
```

No payload da API, a feature `LapTime (s)` foi exposta como `LapTime_s`,
porque nomes de campos com espaco e parenteses sao ruins para JSON.

As variaveis categoricas (`Driver`, `Compound`, `Race`) devem chegar ja
codificadas, do mesmo modo como foram usadas no treinamento.

## Subindo os serviços

### 1. Subir tudo com Docker Compose

```bash
docker compose up --build
```

Se a sua instalacao ainda usa o binario antigo:

```bash
docker-compose up --build
```

### 2. Abrir no navegador

Abra:

```text
http://localhost:3000
```

### 3. Testar o Swagger

Abra:

```text
http://localhost:8000/docs
```

Clique em `POST /predict`, depois em `Try it out`, mantenha o exemplo sugerido
ou ajuste os valores, e clique em `Execute`.

### 4. Parar os containers

```bash
docker compose down
```

## Teste rapido com curl

```bash
curl -X POST http://localhost:8000/predict \
  -H "Content-Type: application/json" \
  -d '{
    "Driver": 3,
    "LapNumber": 11,
    "Compound": 1,
    "Stint": 1,
    "TyreLife": 14.0,
    "Position": 3,
    "LapTime_s": 84.953,
    "Race": 18,
    "Year": 2024,
    "LapTime_Delta": -16.660,
    "Cumulative_Degradation": 15.394,
    "PitStop": 0,
    "RaceProgress": 0.142857,
    "Normalized_TyreLife": 0.318182,
    "Position_Change": 5.0
  }'
```

Exemplo de resposta esperada:

```json
{
  "PitNextLap": 0,
  "probability_pit": 0.475,
  "probability_no_pit": 0.525,
  "confidence": "Baixa"
}
```

## Roteiro completo

### Parte 1 - Contexto de MLOps

Objetivo: mostrar que treinar modelo e apenas uma parte do ciclo.
Em producao precisamos entregar uma aplicação estavel para outros sistemas
consumirem o modelo.


- O notebook gera conhecimento e um artefato treinado.
- A API transforma o modelo em servico.
- O Swagger documenta o serviço.
- O Docker padroniza o ambiente.
- O Compose sobe API e frontend juntos.

### Parte 2 - Artefatos de modelo

Temos os artefatos gerados na ultima aula

```text
rf_model.joblib
rf_model.pkl
```

- `.pkl` e `.joblib` guardam o estado treinado do modelo.
- `joblib` e comum em projetos scikit-learn porque lida bem com arrays numpy.
- O arquivo deve ser tratado como artefato versionado.
- Nunca carregue pickle/joblib de fonte desconhecida, pois pode executar codigo.

No `main.py`, temos:

```python
MODEL_PATH=/app/rf_model.joblib
joblib.load(model_path)
```

> Em producao, o modelo precisa ser carregado uma vez na inicializacao, nao a
> cada requisicao.

### Parte 3 - Aplicação da API

No Arquivo `main.py` temos a classe `LapRecord`.

Nesta classe temos:

- Pydantic valida tipos e limites antes da inferencia.
- O JSON usa nomes estaveis.
- O endpoint `/predict` recebe um registro.
- O endpoint `/predict/batch` recebe varios registros.
- O endpoint `/model/info` ajuda observabilidade e governanca.
- O endpoint `/health` ajuda Docker, orquestradores e monitoramento.

Exemplo de payload:

```json
{
  "Driver": 3,
  "LapNumber": 11,
  "Compound": 1,
  "Stint": 1,
  "TyreLife": 14.0,
  "Position": 3,
  "LapTime_s": 84.953,
  "Race": 18,
  "Year": 2024,
  "LapTime_Delta": -16.660,
  "Cumulative_Degradation": 15.394,
  "PitStop": 0,
  "RaceProgress": 0.142857,
  "Normalized_TyreLife": 0.318182,
  "Position_Change": 5.0
}
```

### Parte 4 - Swagger

Suba a aplicacao e acesse:

```text
http://localhost:8000/docs
```

No swagger temos:

1. Lista automatica de endpoints.
2. Schema do `LapRecord`.
3. Exemplo de payload.
4. Botao `Try it out`.
5. Resposta com probabilidades.

Mensagem importante:

> Swagger nao e apenas documentacao bonita. Ele reduz atrito entre quem cria o
> modelo e quem consome o modelo.

### Parte 5 - Dockerfile da API

No arquivo `Dockerfile` temos as seguintes camadas:

```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY main.py .
COPY rf_model.joblib .
COPY rf_model.pkl .
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

Pontos a comentar:

- A imagem base define o ambiente Python.
- `requirements.txt` fixa versoes.
- O modelo treinado (.joblib e .pkl) vai junto da imagem para simplificar.
- `MODEL_PATH` permite trocar o caminho do modelo por variavel de ambiente.
- `HEALTHCHECK` permite ao Docker verificar se a API esta saudavel.
- O container usa usuario nao-root.

### Parte 6 - Docker Compose

Ao abrir o `docker-compose.yml` temos os dois servicos:

- `api`: constroi a imagem Python e expoe `8000`.
- `frontend`: usa Nginx e expoe `3000`.

 Proxy:

```text
Navegador -> localhost:3000/api/predict -> Nginx -> api:8000/predict
```

Ponto essencial de MLOps e deploy: containers conversam por rede
interna, nao por `localhost`.

### Parte 7 - Frontend

Abra `index.html`.

1. O status da API no topo.
2. Predicao de um unico registro.
3. Predicao em lote.
4. Botao de metadados do modelo.
5. JSON bruto retornado pela API.

Neste frontend temos:

- O frontend chama `/api`.
- O Nginx redireciona `/api` para o container da API.
- O usuario acessa apenas `localhost:3000`.

### Parte 8 - Execucao guiada

Sequencia recomendada:

```bash
docker compose up --build
```

Depois abrir:

```text
http://localhost:3000
http://localhost:8000/docs
```

Atividades:

1. Testar o formulario com o payload padrao.
2. Alterar `TyreLife`, `LapNumber`, `Compound` e observar variacoes.
3. Executar `/predict` pelo Swagger.
4. Executar `/predict/batch` pelo Swagger.
5. Ver logs da API:

```bash
docker compose logs -f api
```

6. Parar tudo:

```bash
docker compose down
```

### Parte 9 - Troubleshooting

### Porta ocupada

Se `8000` ou `3000` estiverem ocupadas, altere as portas no
`docker-compose.yml`:

```yaml
ports:
  - "8001:8000"
```

### Modelo nao carregado

Verifique:

```bash
docker compose logs api
```

E confirme se `rf_model.joblib` existe na pasta do projeto.

### Frontend abre, mas API aparece offline

Verifique:

```bash
docker compose ps
docker compose logs api
docker compose logs frontend
```

O frontend chama a API por `/api`, entao o `nginx.conf` precisa estar montado
corretamente no container.
