from fastapi import FastAPI, Query
from typing import List
import os

app = FastAPI(
    title="Log Search API",
    description="API para buscar termos no arquivo HDFS_2k.log",
    version="1.0.0"
)

LOG_FILE = "HDFS_2k.log"

@app.get("/", tags=["Root"])
def read_root():
    return {"message": "API de busca de logs ativa. Acesse /docs para a documentação."}

@app.get("/search", response_model=List[str], tags=["Logs"])
async def search_logs(query: str = Query(..., description="Texto para buscar nos logs")):
    """
    Busca um termo específico dentro do arquivo de logs e retorna todas as linhas correspondentes.
    """
    if not os.path.exists(LOG_FILE):
        return {"error": f"Arquivo {LOG_FILE} não encontrado no servidor."}
    
    results = []
    with open(LOG_FILE, "r") as f:
        for line in f:
            if query.lower() in line.lower():
                results.append(line.strip())
    
    return results

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)