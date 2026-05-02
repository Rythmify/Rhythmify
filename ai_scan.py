"""
AI detection scanner using HuggingFace Inference API (free).
Model: Hello-SimpleAI/chatgpt-detector-roberta

Usage:
    python ai_scan.py <hf_token> <folder> [folder2 ...]

Example:
    python ai_scan.py hf_abc123 lib/features/messaging lib/features/settings

Get a free token at: huggingface.co/settings/tokens
"""

import sys
import time
import requests
from pathlib import Path

API_URL = "https://api-inference.huggingface.co/models/Hello-SimpleAI/chatgpt-detector-roberta"
EXTENSIONS = {".dart", ".kt", ".swift", ".java"}
MAX_CHARS = 512    # RoBERTa token limit (keep to ~500 chars to be safe)
RATE_DELAY = 1.5   # seconds between requests


def scan_file(api_key: str, file_path: Path) -> float | None:
    text = file_path.read_text(encoding="utf-8", errors="ignore").strip()
    if len(text) < 80:
        return None  # too short to be meaningful

    # Truncate to model limit
    if len(text) > MAX_CHARS:
        text = text[:MAX_CHARS]

    try:
        resp = requests.post(
            API_URL,
            headers={"Authorization": f"Bearer {api_key}"},
            json={"inputs": text},
            timeout=30,
        )
        if resp.status_code == 503:
            # Model is loading — wait and retry once
            print("  model loading, waiting 20s...")
            time.sleep(20)
            resp = requests.post(
                API_URL,
                headers={"Authorization": f"Bearer {api_key}"},
                json={"inputs": text},
                timeout=30,
            )
        resp.raise_for_status()

        # Response: [[{"label": "ChatGPT", "score": 0.87}, {"label": "Human", "score": 0.13}]]
        labels = resp.json()[0]
        ai_score = next((x["score"] for x in labels if x["label"].lower() != "human"), None)
        if ai_score is None:
            # fallback: 1 - human score
            human = next((x["score"] for x in labels if x["label"].lower() == "human"), 0)
            ai_score = 1 - human
        return round(ai_score * 100, 1)

    except requests.HTTPError as e:
        if resp.status_code == 429:
            print("  rate limited — waiting 60s...")
            time.sleep(60)
        else:
            print(f"  HTTP {resp.status_code}: {e}")
        return None
    except Exception as e:
        print(f"  error: {e}")
        return None


def scan_folder(api_key: str, folder: str) -> list[tuple[str, float]]:
    root = Path(folder)
    if not root.exists():
        print(f"Folder not found: {folder}")
        return []

    files = sorted(
        f for f in root.rglob("*") if f.suffix in EXTENSIONS and f.is_file()
    )
    if not files:
        print(f"No supported files found in {folder}")
        return []

    print(f"\nScanning {len(files)} files in '{folder}'\n")
    col = 68
    print(f"{'File':<{col}} {'AI %':>6}")
    print("─" * (col + 8))

    results = []
    for i, fp in enumerate(files):
        label = str(fp.relative_to(root.parent))
        pct = scan_file(api_key, fp)

        if pct is not None:
            results.append((label, pct))
            print(f"{label:<{col}} {pct:>5.1f}%")
        else:
            print(f"{label:<{col}} {'skip':>6}")

        if i < len(files) - 1:
            time.sleep(RATE_DELAY)

    return results


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        sys.exit(1)

    api_key = sys.argv[1]
    folders = sys.argv[2:]

    all_results: list[tuple[str, float]] = []
    for folder in folders:
        all_results.extend(scan_folder(api_key, folder))

    if not all_results:
        print("Nothing scanned.")
        return

    col = 68
    print("\n" + "═" * (col + 8))
    print(f"{'SUMMARY':<{col}}")
    print("═" * (col + 8))

    all_results.sort(key=lambda x: x[1], reverse=True)
    for label, pct in all_results:
        bar = "█" * int(pct / 5)
        print(f"{label:<{col}} {pct:>5.1f}%  {bar}")

    avg = sum(p for _, p in all_results) / len(all_results)
    print("─" * (col + 8))
    print(f"\n  Overall average : {avg:.1f}% AI")
    print(f"  Files scanned   : {len(all_results)}")
    highest = max(all_results, key=lambda x: x[1])
    lowest = min(all_results, key=lambda x: x[1])
    print(f"  Highest         : {highest[1]:.1f}%  ({highest[0]})")
    print(f"  Lowest          : {lowest[1]:.1f}%  ({lowest[0]})\n")


if __name__ == "__main__":
    main()
