FROM apache/airflow:latest
WORKDIR /app
copy requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
copy . . 
CMD ["python", "dag_get_covid_data_process_parquet_save.py"]