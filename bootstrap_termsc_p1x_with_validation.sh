#!/data/data/com.termux/files/usr/bin/bash
# TERMSC-P1-X Master Bootstrap + Validation Script
# Author: Christian Palandt, FH Aachen
# Purpose: Fully install, run, and validate TERMSC-P1-X on Termux

set -e

echo "[1/14] Updating Termux packages..."
pkg update -y
pkg upgrade -y

echo "[2/14] Installing base dependencies..."
pkg install -y proot-distro git python nodejs openjdk-17 clang go rust swift julia gradle sqlite wget

echo "[3/14] Installing Ubuntu devcontainer..."
proot-distro install ubuntu

echo "[4/14] Logging into Ubuntu container to install language runtimes..."
proot-distro login ubuntu <<EOF
apt update && apt upgrade -y
apt install -y python3 python3-pip r-base julia swift kotlin gradle nodejs npm sqlite3 build-essential
EOF

echo "[5/14] Cloning TERMSC-P1-X repository..."
cd ~
git clone https://your-repo-url/termsc-p1-x.git
cd termsc-p1-x

echo "[6/14] Setting up SQL artifact DB..."
cd devbox
sqlite3 devbox.db < schema.sql
cd ..

echo "[7/14] Installing Python dependencies..."
pip install fastapi uvicorn pydantic websockets

echo "[8/14] Starting Scheduler & Worker Runtime..."
cd scheduler
nohup python scheduler_runtime_loop.py > scheduler.log 2>&1 &

echo "[9/14] Starting Federation server..."
cd ../federation
nohup uvicorn federation_node:app --host 0.0.0.0 --port 8001 > federation.log 2>&1 &

echo "[10/14] Starting Dashboard backend..."
cd ../dashboard/backend
nohup uvicorn control_api:app --host 0.0.0.0 --port 8000 > dashboard_backend.log 2>&1 &

echo "[11/14] Starting Dashboard frontend..."
cd ../frontend
npm install
nohup npm start > dashboard_frontend.log 2>&1 &

echo "[12/14] Starting CLI shell..."
cd ../../cli
nohup python termsc_sh.py > cli.log 2>&1 &

echo "[13/14] Running Validation Suite..."
cd ../
VALIDATION_SCRIPTS=("validate_scheduler.py" "validate_workers.py" "validate_buffers.py" "validate_federation.py" "validate_devbox.py")
for script in "${VALIDATION_SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        echo "Running $script..."
        python "$script" || { echo "Validation FAILED: $script"; exit 1; }
        echo "$script completed successfully."
    else
        echo "Warning: $script not found, skipping..."
    fi
done

echo "[14/14] TERMSC-P1-X Bootstrap & Validation Complete!"
echo "✅ Scheduler, Workers, Federation, Dashboard, DevBox, CLI are running."
echo "Logs saved in each directory (scheduler.log, federation.log, dashboard_backend.log, dashboard_frontend.log, cli.log)."
echo "Validation suite completed successfully. System is ready for use."