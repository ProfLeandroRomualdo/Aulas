from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from airflow.operators.bash_operator import BashOperator
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
    'covid_data_processing_cassandra',
    default_args=default_args,
    description='DAG para baixar, processar e salvar dados COVID-19 no Cassandra',
    schedule_interval=timedelta(days=1),  # Execute diariamente
)

# Task 0: Instala o Cassandra-driver
install_cassandra_driver_task = BashOperator(
    task_id='install_cassandra_driver',
    bash_command='pip install cassandra-driver',
    dag=dag,
)

from cassandra.cluster import Cluster

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


# Task 4: Criar tabela no Cassandra
def create_cassandra_table(**kwargs):
    ti = kwargs['ti']
    df = ti.xcom_pull(task_ids='process_data')

    # Conecte-se ao cluster do Cassandra
    cluster = Cluster(['657']) # id do cassandra
    session = cluster.connect()

    # Crie um keyspace (se necessário)
    session.execute("CREATE KEYSPACE IF NOT EXISTS covid_data WITH REPLICATION = {'class': 'SimpleStrategy', 'replication_factor': 1}")

    # Use o keyspace
    session.set_keyspace('covid_data')

    # Extraia as colunas e tipos do DataFrame
    columns = list(df.columns)
    dtypes = list(df.dtypes)

    # Crie uma tabela dinamicamente com base nas colunas e tipos do DataFrame
    table_create_query = f"CREATE TABLE IF NOT EXISTS covid_tests (date DATE PRIMARY KEY, {', '.join([f'{col} {dtype}' for col, dtype in zip(columns, dtypes)])})"
    session.execute(table_create_query)

    # Feche a conexão
    cluster.shutdown()

create_cassandra_table_task = PythonOperator(
    task_id='create_cassandra_table',
    python_callable=create_cassandra_table,
    provide_context=True,
    dag=dag,
)

# Task 5: Salvar os dados no Cassandra
def save_to_cassandra(**kwargs):
    ti = kwargs['ti']
    df = ti.xcom_pull(task_ids='process_data')

    # Conecte-se novamente ao cluster do Cassandra
    cluster = Cluster(['657'])
    session = cluster.connect()

    # Use o keyspace
    session.set_keyspace('covid_data')

    # Insira os dados na tabela
    for _, row in df.iterrows():
        session.execute("""
            INSERT INTO covid_tests (date, {columns})
            VALUES (%s, {values})
        """.format(columns=", ".join(df.columns[1:]), values=", ".join(["%s"] * len(df.columns[1:]))), tuple(row[1:]))
    
    # Feche a conexão
    cluster.shutdown()

save_to_cassandra_task = PythonOperator(
    task_id='save_to_cassandra',
    python_callable=save_to_cassandra,
    provide_context=True,
    dag=dag,
)

# Defina a ordem de execução das tarefas
download_task >> read_task >> process_task >> create_cassandra_table_task >> save_to_cassandra_task
