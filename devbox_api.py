from fastapi import FastAPI
import sqlite3
import subprocess
from pydantic import BaseModel

app = FastAPI()
DB_PATH = "../devbox/devbox.db"

class Artifact(BaseModel):
    user: str
    language: str
    type: str
    name: str
    content: str

@app.post("/devbox/create")
def create_artifact(a: Artifact):
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute(
        "INSERT INTO artifacts (user_id, language, type, name, content, created) VALUES (?, ?, ?, ?, ?, datetime('now'))",
        (a.user, a.language, a.type, a.name, a.content),
    )
    conn.commit()
    conn.close()
    return {"status": "ok"}

@app.get("/devbox/artifact/{artifact_id}")
def get_artifact(artifact_id: int):
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute("SELECT content FROM artifacts WHERE id = ?", (artifact_id,))
    row = c.fetchone()
    conn.close()
    return {"content": row[0] if row else ""}

@app.post("/devbox/run")
def run_artifact(a: Artifact):
    # Run in isolated subprocess depending on language
    output = ""
    try:
        if a.language.lower() == "python":
            result = subprocess.run(["python3", "-c", a.content], capture_output=True, text=True, timeout=10)
            output = result.stdout + result.stderr
        elif a.language.lower() == "r":
            result = subprocess.run(["Rscript", "-e", a.content], capture_output=True, text=True, timeout=10)
            output = result.stdout + result.stderr
        elif a.language.lower() == "julia":
            result = subprocess.run(["julia", "-e", a.content], capture_output=True, text=True, timeout=10)
            output = result.stdout + result.stderr
        # Add additional languages here: Kotlin, Java, Swift, Go, JS, HTML build logic
        else:
            output = f"Execution for {a.language} not implemented yet."
    except subprocess.TimeoutExpired:
        output = "Execution timed out!"
    return {"output": output}