from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.python_operator import PythonOperator
import pandas as pd
import requests
from io import StringIO

# Defina os parâmetros padrão da DAG
default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2023, 1, 1),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

# Instancie a DAG
dag = DAG(
    'covid_data_processing',
    default_args=default_args,
    description='DAG para baixar, processar e salvar dados COVID-19',
    schedule_interval=timedelta(days=1),  # Execute diariamente
)

# Task 1: Baixar os dados do arquivo
def download_data(**kwargs):
    url = "https://s3-us-west-1.amazonaws.com/starschema.covid/CT_US_COVID_TESTS.csv"
    response = requests.get(url)
    return response.text

download_task = PythonOperator(
    task_id='download_data',
    python_callable=download_data,
    provide_context=True,
    dag=dag,
)

# Task 2: Ler o arquivo usando pandas e salvar os dados em um dataframe
def read_data(**kwargs):
    ti = kwargs['ti']
    data = ti.xcom_pull(task_ids='download_data')
    df = pd.read_csv(StringIO(data))
    ti.xcom_push(key='covid_data', value=df)

read_task = PythonOperator(
    task_id='read_data',
    python_callable=read_data,
    provide_context=True,
    dag=dag,
)

# Task 3: Analisar e processar os dados
def process_data(**kwargs):
    ti = kwargs['ti']
    df = ti.xcom_pull(task_ids='read_data')

    # Análise e pré-processamento dos dados aqui
    # Remova colunas com mais de 20% de dados faltantes
    df = df.dropna(thresh=len(df) * 0.8, axis=1)

    # Preencha colunas com menos de 20% de dados faltantes com a média
    df = df.apply(lambda col: col.fillna(col.mean()) if col.isnull().mean() < 0.2 else col, axis=0)

    ti.xcom_push(key='processed_data', value=df)

process_task = PythonOperator(
    task_id='process_data',
    python_callable=process_data,
    provide_context=True,
    dag=dag,
)

# Task 4: Salvar os dados em formato parquet com uma coluna adicional de data de execução
def save_to_parquet(**kwargs):
    ti = kwargs['ti']
    df = ti.xcom_pull(task_ids='process_data')

    # Adicione uma coluna de data de execução
    df['execution_date'] = kwargs['execution_date']

    # Salvar os dados em um arquivo parquet
    pd.to_parquet(df, '/usr/local/airflow/data/covid_data.parquet')

save_to_parquet_task = PythonOperator(
    task_id='save_to_parquet',
    python_callable=save_to_parquet,
    provide_context=True,
    dag=dag,
)

# Defina a ordem de execução das tarefas
download_task >> read_task >> process_task >> save_to_parquet_task
