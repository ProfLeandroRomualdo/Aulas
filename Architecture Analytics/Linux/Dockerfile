# Usa uma imagem oficial leve do Python
FROM python:3.11-slim

# Define o diretório de trabalho dentro do container
WORKDIR /app

# Copia o arquivo de requisitos e instala as dependências
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copia o código da API e o arquivo de dados
COPY main.py .
COPY HDFS_2k.log .

# Expõe a porta que a API irá rodar
EXPOSE 8000

# Comando para iniciar a aplicação usando uvicorn
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]