import subprocess
import sqlite3

DB_PATH = "../devbox/devbox.db"

def edit_artifact(artifact_id=None):
    import os
    filename = f"artifact_{artifact_id}.txt" if artifact_id else "new_artifact.txt"
    subprocess.call(["nano", filename])
    # Save back to DB
    with open(filename, "r") as f:
        content = f.read()
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    if artifact_id:
        c.execute("UPDATE artifacts SET content = ? WHERE id = ?", (content, artifact_id))
    else:
        c.execute("INSERT INTO artifacts (user_id, language, type, name, content, created) VALUES (?, ?, ?, ?, ?, datetime('now'))",
                  ("CLI_User", "python", "file", filename, content))
    conn.commit()
    conn.close()
    print(f"Saved {filename} to DevBox.")