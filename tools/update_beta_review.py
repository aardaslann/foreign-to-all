"""Refresh the speech worksheet while preserving human review columns by line."""
import csv
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
folder = ROOT / "docs/beta-language-review"
path = folder / "review.csv"
with path.open(encoding="utf-8-sig", newline="") as stream:
    reader = csv.DictReader(stream)
    fields = reader.fieldnames
    old = {(row["voice"], row["text"]): row for row in reader}
lines = json.loads((folder / "spoken-lines.json").read_text(encoding="utf-8"))["lines"]
clips = json.loads((ROOT / "audio/voice/manifest.json").read_text(encoding="utf-8"))["lines"]
rows = []
for line in lines:
    key = (line["voice"], line["text"])
    row = {field: "" for field in fields}
    row.update(old.pop(key, {}))
    row.update({field: line[field] for field in ["city", "chapter", "voice", "language", "text", "context"]})
    row["clip"] = clips.get(line["voice"] + "|" + " ".join(line["text"].split()), "")
    if not row.get("review_status"):
        row["review_status"] = "pending"
    rows.append(row)
# Retired lines with review notes remain in the worksheet for traceability.
for row in old.values():
    if any(row.get(field) for field in ["reviewer", "language_notes", "culture_notes", "suggested_line"]):
        row["review_status"] = "retired: " + row.get("review_status", "pending")
        rows.append(row)
with path.open("w", encoding="utf-8", newline="") as stream:
    writer = csv.DictWriter(stream, fieldnames=fields)
    writer.writeheader()
    writer.writerows(rows)
print(f"Review worksheet: {len(lines)} current lines; human notes retained")
