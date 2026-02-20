from flask import Flask, request, jsonify
import sqlite3
import os

app = Flask(__name__)
PORT_REGISTRY = "~/sbc2048/ports/port_registry.db"
RESERVED_PORTS = {8000, 8001, 9101, 9102, 9103, 9104, 9105}  # UI & neural ports
SANDBOX_PORT_RANGE = range(9200, 9300)  # Reserved for sandboxes

@app.route('/allocate_port', methods=['POST'])
def allocate_port():
    process_id = request.json.get('process_id')
    service = request.json.get('service', 'sandbox')
    
    conn = sqlite3.connect(PORT_REGISTRY)
    c = conn.cursor()
    
    # Find available port
    c.execute("SELECT port FROM port_leases")
    used = set(row[0] for row in c.fetchall()) | RESERVED_PORTS
    available = [p for p in SANDBOX_PORT_RANGE if p not in used]
    
    if not available:
        return {"error": "No available ports"}, 503
    
    port = available[0]
    sandbox_dir = f"~/sbc2048/buffer/sandbox_{process_id}"
    
    c.execute(
        "INSERT INTO port_leases (process_id, port, service, sandbox_dir) VALUES (?, ?, ?, ?)",
        (process_id, port, service, sandbox_dir)
    )
    conn.commit()
    conn.close()
    
    return {"port": port, "sandbox_dir": sandbox_dir}

@app.route('/release_port/<process_id>', methods=['DELETE'])
def release_port(process_id):
    conn = sqlite3.connect(PORT_REGISTRY)
    c = conn.cursor()
    c.execute("DELETE FROM port_leases WHERE process_id = ?", (process_id,))
    conn.commit()
    conn.close()
    return {"status": "released"}

if __name__ == "__main__":
    os.makedirs(os.path.dirname(PORT_REGISTRY), exist_ok=True)
    app.run(host="0.0.0.0", port=5001)