"""
F1 Pit Stop Predictor - API de inferencia para aula de MLOps.

Objetivo:
- carregar um modelo treinado serializado em .joblib ou .pkl;
- expor predicoes via FastAPI;
- gerar Swagger automaticamente em /docs;
- servir como backend para um frontend containerizado.
"""

from __future__ import annotations

import os
from pathlib import Path
from typing import Any

import joblib
import numpy as np
import pandas as pd
from fastapi import FastAPI, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field


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

DEFAULT_MODEL_CANDIDATES = [
    "rf_model.joblib",
    "rf_model.pkl",
    "app/model/rf_model.joblib",
    "app/model/rf_model.pkl",
]


class ModelState:
    model: Any | None = None
    path: str | None = None
    error: str | None = None


state = ModelState()


app = FastAPI(
    title="F1 Pit Stop Predictor API",
    description="""
API de inferencia para demonstrar um deploy de Machine Learning em producao.

O modelo recebe 15 variaveis de telemetria de Formula 1 e prediz se o carro
fara pit stop na proxima volta (`PitNextLap`). As variaveis categoricas ja
devem chegar codificadas como inteiros, seguindo o mesmo pre-processamento do
treinamento.

Endpoints principais:

- `GET /health`: status da aplicacao e do modelo carregado.
- `GET /model/info`: metadados do modelo e das features.
- `POST /predict`: predicao para um registro.
- `POST /predict/batch`: predicao para lote de registros.
""",
    version="1.0.0",
    contact={"name": "MLOps Lab"},
    openapi_tags=[
        {"name": "Saude", "description": "Status da API e do modelo"},
        {"name": "Modelo", "description": "Metadados do modelo em uso"},
        {"name": "Predicao", "description": "Inferencia online"},
    ],
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


def resolve_model_path() -> Path:
    env_path = os.getenv("MODEL_PATH")
    candidates = [env_path] if env_path else []
    candidates.extend(DEFAULT_MODEL_CANDIDATES)

    for candidate in candidates:
        if not candidate:
            continue
        path = Path(candidate)
        if path.exists():
            return path

    raise FileNotFoundError(
        "Nenhum artefato de modelo encontrado. Defina MODEL_PATH ou mantenha "
        "rf_model.joblib/rf_model.pkl no diretorio da aplicacao."
    )


@app.on_event("startup")
def load_model() -> None:
    try:
        model_path = resolve_model_path()
        state.model = joblib.load(model_path)
        state.path = str(model_path)
        state.error = None
        print(f"Modelo carregado de {model_path}")
    except Exception as exc:
        state.model = None
        state.path = None
        state.error = str(exc)
        print(f"Falha ao carregar modelo: {exc}")


class LapRecord(BaseModel):
    Driver: int = Field(..., ge=0, description="Piloto codificado por LabelEncoder.")
    LapNumber: int = Field(..., ge=1, le=100, description="Numero da volta atual.")
    Compound: int = Field(
        ..., ge=0, le=3, description="Pneu codificado: 0=HARD, 1=INTERMEDIATE, 2=MEDIUM, 3=SOFT."
    )
    Stint: int = Field(..., ge=1, description="Numero do stint atual.")
    TyreLife: float = Field(..., ge=0, description="Voltas acumuladas no pneu atual.")
    Position: int = Field(..., ge=1, le=20, description="Posicao do piloto na corrida.")
    LapTime_s: float = Field(..., gt=0, description="Tempo de volta em segundos.")
    Race: int = Field(..., ge=0, description="Corrida codificada por LabelEncoder.")
    Year: int = Field(..., ge=2018, le=2035, description="Ano da temporada.")
    LapTime_Delta: float = Field(..., description="Diferenca contra a referencia de tempo.")
    Cumulative_Degradation: float = Field(..., description="Degradacao acumulada calculada.")
    PitStop: int = Field(..., ge=0, le=1, description="1 se houve pit stop na volta atual.")
    RaceProgress: float = Field(..., ge=0, le=1, description="Progresso da corrida entre 0 e 1.")
    Normalized_TyreLife: float = Field(..., ge=0, le=1, description="Vida do pneu normalizada.")
    Position_Change: float = Field(..., description="Variacao de posicao contra a volta anterior.")

    model_config = {
        "json_schema_extra": {
            "example": {
                "Driver": 3,
                "LapNumber": 11,
                "Compound": 1,
                "Stint": 1,
                "TyreLife": 14.0,
                "Position": 3,
                "LapTime_s": 84.953,
                "Race": 18,
                "Year": 2024,
                "LapTime_Delta": -16.66,
                "Cumulative_Degradation": 15.394,
                "PitStop": 0,
                "RaceProgress": 0.142857,
                "Normalized_TyreLife": 0.318182,
                "Position_Change": 5.0,
            }
        }
    }


class BatchRequest(BaseModel):
    records: list[LapRecord] = Field(..., min_length=1, max_length=200)

    model_config = {
        "json_schema_extra": {
            "example": {
                "records": [
                    LapRecord.model_config["json_schema_extra"]["example"],
                    {
                        "Driver": 1,
                        "LapNumber": 59,
                        "Compound": 0,
                        "Stint": 3,
                        "TyreLife": 7.0,
                        "Position": 2,
                        "LapTime_s": 72.379,
                        "Race": 5,
                        "Year": 2025,
                        "LapTime_Delta": 3.944,
                        "Cumulative_Degradation": -67.3,
                        "PitStop": 0,
                        "RaceProgress": 0.75641,
                        "Normalized_TyreLife": 0.233333,
                        "Position_Change": -1.0,
                    },
                ]
            }
        }
    }


class PredictionResult(BaseModel):
    PitNextLap: int
    probability_pit: float
    probability_no_pit: float
    confidence: str


class BatchPredictionResult(BaseModel):
    total_records: int
    predictions: list[PredictionResult]
    summary: dict[str, float | int]


def require_model() -> Any:
    if state.model is None:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=f"Modelo nao carregado: {state.error}",
        )
    return state.model


def record_to_frame(record: LapRecord) -> pd.DataFrame:
    values = [
        record.Driver,
        record.LapNumber,
        record.Compound,
        record.Stint,
        record.TyreLife,
        record.Position,
        record.LapTime_s,
        record.Race,
        record.Year,
        record.LapTime_Delta,
        record.Cumulative_Degradation,
        record.PitStop,
        record.RaceProgress,
        record.Normalized_TyreLife,
        record.Position_Change,
    ]
    return pd.DataFrame([values], columns=FEATURE_ORDER)


def confidence_label(probability: float) -> str:
    distance_from_middle = abs(probability - 0.5)
    if distance_from_middle >= 0.25:
        return "Alta"
    if distance_from_middle >= 0.10:
        return "Media"
    return "Baixa"


def predict_record(record: LapRecord) -> PredictionResult:
    model = require_model()
    features = record_to_frame(record)
    prediction = int(model.predict(features)[0])

    if not hasattr(model, "predict_proba"):
        probability_pit = float(prediction)
        probability_no_pit = 1.0 - probability_pit
    else:
        probabilities = model.predict_proba(features)[0]
        classes = list(getattr(model, "classes_", [0, 1]))
        probability_no_pit = float(probabilities[classes.index(0)]) if 0 in classes else 0.0
        probability_pit = float(probabilities[classes.index(1)]) if 1 in classes else 0.0

    return PredictionResult(
        PitNextLap=prediction,
        probability_pit=round(probability_pit, 4),
        probability_no_pit=round(probability_no_pit, 4),
        confidence=confidence_label(probability_pit),
    )


@app.get("/", tags=["Saude"])
def root() -> dict[str, str]:
    return {
        "status": "online",
        "name": "F1 Pit Stop Predictor API",
        "docs": "/docs",
        "health": "/health",
    }


@app.get("/health", tags=["Saude"])
def health() -> dict[str, Any]:
    return {
        "status": "healthy" if state.model is not None else "degraded",
        "model_loaded": state.model is not None,
        "model_path": state.path,
        "model_error": state.error,
        "n_features": len(FEATURE_ORDER),
    }


@app.get("/model/info", tags=["Modelo"])
def model_info() -> dict[str, Any]:
    model = require_model()
    info: dict[str, Any] = {
        "model_type": type(model).__name__,
        "model_path": state.path,
        "target": "PitNextLap",
        "classes": {"0": "Nao vai ao pit", "1": "Vai ao pit"},
        "feature_order": FEATURE_ORDER,
        "n_features_in": getattr(model, "n_features_in_", None),
        "classes_in_model": [int(c) for c in getattr(model, "classes_", [])],
    }

    if hasattr(model, "n_estimators"):
        info["n_estimators"] = int(model.n_estimators)
    if hasattr(model, "feature_importances_"):
        importances = {
            feature: round(float(value), 4)
            for feature, value in zip(FEATURE_ORDER, model.feature_importances_)
        }
        info["feature_importances"] = dict(
            sorted(importances.items(), key=lambda item: item[1], reverse=True)
        )

    return info


@app.post("/predict", response_model=PredictionResult, tags=["Predicao"])
def predict(record: LapRecord) -> PredictionResult:
    try:
        return predict_record(record)
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=500, detail=f"Erro na predicao: {exc}") from exc


@app.post("/predict/batch", response_model=BatchPredictionResult, tags=["Predicao"])
def predict_batch(batch: BatchRequest) -> BatchPredictionResult:
    try:
        predictions = [predict_record(record) for record in batch.records]
        total_pit = sum(item.PitNextLap for item in predictions)
        avg_probability = float(np.mean([item.probability_pit for item in predictions]))

        return BatchPredictionResult(
            total_records=len(predictions),
            predictions=predictions,
            summary={
                "total_pit": total_pit,
                "total_no_pit": len(predictions) - total_pit,
                "pct_pit": round(total_pit / len(predictions) * 100, 2),
                "avg_probability_pit": round(avg_probability, 4),
            },
        )
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=500, detail=f"Erro na predicao em lote: {exc}") from exc
