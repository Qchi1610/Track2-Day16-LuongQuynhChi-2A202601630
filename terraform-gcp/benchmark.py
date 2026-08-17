import json
import time
from pathlib import Path

import lightgbm as lgb
import pandas as pd
from sklearn.metrics import accuracy_score, f1_score, precision_score, recall_score, roc_auc_score
from sklearn.model_selection import train_test_split


DATASET = Path.home() / "ml-benchmark" / "creditcard.csv"
RESULT = Path("benchmark_result.json")


def main():
    started = time.perf_counter()
    data = pd.read_csv(DATASET)
    load_seconds = time.perf_counter() - started

    x = data.drop(columns="Class")
    y = data["Class"]
    x_train, x_test, y_train, y_test = train_test_split(
        x, y, test_size=0.2, random_state=42, stratify=y
    )

    model = lgb.LGBMClassifier(
        n_estimators=200,
        learning_rate=0.05,
        num_leaves=31,
        n_jobs=1,
        random_state=42,
        verbosity=-1,
    )
    started = time.perf_counter()
    model.fit(x_train, y_train)
    training_seconds = time.perf_counter() - started

    probabilities = model.predict_proba(x_test)[:, 1]
    predictions = (probabilities >= 0.5).astype(int)

    started = time.perf_counter()
    model.predict_proba(x_test.iloc[:1])
    latency_ms = (time.perf_counter() - started) * 1000

    batch = x_test.iloc[:1000]
    started = time.perf_counter()
    model.predict_proba(batch)
    inference_seconds = time.perf_counter() - started

    result = {
        "machine_type": "e2-micro",
        "load_data_seconds": load_seconds,
        "training_seconds": training_seconds,
        "best_iteration": model.best_iteration_ or model.n_estimators,
        "auc_roc": roc_auc_score(y_test, probabilities),
        "accuracy": accuracy_score(y_test, predictions),
        "f1_score": f1_score(y_test, predictions),
        "precision": precision_score(y_test, predictions),
        "recall": recall_score(y_test, predictions),
        "inference_latency_ms_1_row": latency_ms,
        "inference_seconds_1000_rows": inference_seconds,
        "inference_throughput_rows_per_second": len(batch) / inference_seconds,
    }
    RESULT.write_text(json.dumps(result, indent=2), encoding="utf-8")
    print(json.dumps(result, indent=2))
    print(f"Saved to {RESULT.resolve()}")


if __name__ == "__main__":
    main()
