from flask import Flask, request, jsonify
import sqlite3
import uuid

app = Flask(__name__)
DB = "leases.db"
IP_POOL = [f"192.168.0.{i}" for i in range(100, 110)]  # 10 IPs

def init_db():
    conn = sqlite3.connect(DB)
    c = conn.cursor()
    c.execute('''CREATE TABLE IF NOT EXISTS leases (
        worker_id TEXT PRIMARY KEY,
        ip TEXT UNIQUE,
        lease_start TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )''')
    conn.commit()
    conn.close()

@app.route('/register', methods=['POST'])
def register_worker():
    worker_id = request.json.get('worker_id')
    conn = sqlite3.connect(DB)
    c = conn.cursor()
    
    # Check if already registered
    c.execute("SELECT ip FROM leases WHERE worker_id = ?", (worker_id,))
    row = c.fetchone()
    if row:
        return jsonify({"ip": row[0], "existing": True})

    # Assign new IP
    c.execute("SELECT ip FROM leases")
    used_ips = [r[0] for r in c.fetchall()]
    free_ips = list(set(IP_POOL) - set(used_ips))
    if not free_ips:
        return jsonify({"error": "No available IPs"}), 503

    assigned_ip = sorted(free_ips)[0]
    c.execute("INSERT INTO leases (worker_id, ip) VALUES (?, ?)", (worker_id, assigned_ip))
    conn.commit()
    conn.close()
    return jsonify({"ip": assigned_ip, "existing": False})

@app.route('/leases', methods=['GET'])
def get_leases():
    conn = sqlite3.connect(DB)
    c = conn.cursor()
    c.execute("SELECT * FROM leases")
    leases = [{"worker_id": row[0], "ip": row[1], "lease_start": row[2]} for row in c.fetchall()]
    conn.close()
    return jsonify(leases)

if __name__ == "__main__":
    init_db()
    app.run(host="0.0.0.0", port=5000)
