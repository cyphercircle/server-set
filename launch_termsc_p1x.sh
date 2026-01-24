#!/data/data/com.termux/files/usr/bin/bash
# TERMSC-P1-X One-Command Launch
# Author: Christian Palandt, FH Aachen
# Purpose: Start all TERMSC-P1-X services in Termux in correct order

set -e

echo "=== Launching TERMSC-P1-X Services ==="

# Scheduler & Worker Runtime
echo "[1/6] Starting Scheduler & Worker Runtime..."
cd ~/termsc-p1-x/scheduler
nohup python scheduler_runtime_loop.py > scheduler.log 2>&1 &

# Federation Server
echo "[2/6] Starting Federation Server..."
cd ~/termsc-p1-x/federation
nohup uvicorn federation_node:app --host 0.0.0.0 --port 8001 > federation.log 2>&1 &

# Dashboard Backend
echo "[3/6] Starting Dashboard Backend..."
cd ~/termsc-p1-x/dashboard/backend
nohup uvicorn control_api:app --host 0.0.0.0 --port 8000 > dashboard_backend.log 2>&1 &

# Dashboard Frontend
echo "[4/6] Starting Dashboard Frontend..."
cd ~/termsc-p1-x/dashboard/frontend
npm install
nohup npm start > dashboard_frontend.log 2>&1 &

# CLI Shell
echo "[5/6] Starting CLI Shell..."
cd ~/termsc-p1-x/cli
nohup python termsc_sh.py > cli.log 2>&1 &

# Validation Suite
echo "[6/6] Running Validation Suite..."
cd ~/termsc-p1-x
VALIDATION_SCRIPTS=("scheduler/validate_scheduler.py" "workers/validate_workers.py" "scheduler/validate_buffers.py" "federation/validate_federation.py" "devbox/validate_devbox.py")
for script in "${VALIDATION_SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        echo "Running $script..."
        python "$script" || { echo "Validation FAILED: $script"; exit 1; }
        echo "$script completed successfully."
    else
        echo "Warning: $script not found, skipping..."
    fi apt update -y
done

echo "✅ TERMSC-P1-X Services Launched Successfully!"
echo "All services are running in background. Logs are available in each module folder."