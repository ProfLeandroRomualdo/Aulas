"""
Exemplos de consumo da F1 Pit Stop Predictor API.

Pre-requisito:
    docker compose up --build

Uso:
    py examples_api_calls.py
"""

from __future__ import annotations

import json
import os

import requests


BASE_URL = os.getenv("API_URL", "http://localhost:8000")

PAYLOAD_SINGLE = {
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
    "Position_Change": 5.0,
}

PAYLOAD_BATCH = {
    "records": [
        PAYLOAD_SINGLE,
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
            "Cumulative_Degradation": -67.300,
            "PitStop": 0,
            "RaceProgress": 0.756410,
            "Normalized_TyreLife": 0.233333,
            "Position_Change": -1.0,
        },
    ]
}


def print_section(title: str) -> None:
    print("\n" + "=" * 72)
    print(title)
    print("=" * 72)


def print_json(data: object) -> None:
    print(json.dumps(data, indent=2, ensure_ascii=False))


def request(method: str, path: str, **kwargs: object) -> requests.Response:
    response = requests.request(method, f"{BASE_URL}{path}", timeout=10, **kwargs)
    response.raise_for_status()
    return response


def main() -> None:
    print(f"API_URL = {BASE_URL}")

    print_section("1. Health check")
    print_json(request("GET", "/health").json())

    print_section("2. Metadados do modelo")
    print_json(request("GET", "/model/info").json())

    print_section("3. Predicao de um registro")
    prediction = request("POST", "/predict", json=PAYLOAD_SINGLE).json()
    print_json(prediction)
    print(
        "Decisao:",
        "VAI AO PIT" if prediction["PitNextLap"] == 1 else "NAO VAI AO PIT",
        f"| prob_pit={prediction['probability_pit']:.1%}",
        f"| confianca={prediction['confidence']}",
    )

    print_section("4. Predicao em batch")
    batch = request("POST", "/predict/batch", json=PAYLOAD_BATCH).json()
    print_json(batch)

    print_section("5. cURL equivalente")
    print(
        """curl -X POST http://localhost:8000/predict \\
  -H "Content-Type: application/json" \\
  -d '{"Driver":3,"LapNumber":11,"Compound":1,"Stint":1,"TyreLife":14.0,"Position":3,"LapTime_s":84.953,"Race":18,"Year":2024,"LapTime_Delta":-16.660,"Cumulative_Degradation":15.394,"PitStop":0,"RaceProgress":0.142857,"Normalized_TyreLife":0.318182,"Position_Change":5.0}'"""
    )


if __name__ == "__main__":
    main()
