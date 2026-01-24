#!/data/data/com.termux/files/usr/bin/bash
# TERMSC-P1-X Master Bootstrap Script
# Author: Christian Palandt, FH Aachen
# Purpose: Fully install and run TERMSC-P1-X on Termux

set -e

echo "[1/12] Updating Termux packages..."
pkg update -y
pkg upgrade -y

echo "[2/12] Installing base dependencies..."
pkg install -y proot-distro git python nodejs openjdk-17 clang go rust swift julia gradle sqlite wget

echo "[3/12] Installing Ubuntu devcontainer..."
proot-distro install ubuntu
echo "[4/12] Logging into Ubuntu container to install language runtimes..."
proot-distro login ubuntu <<EOF
apt update && apt upgrade -y
apt install -y python3 python3-pip r-base julia swift kotlin gradle nodejs npm sqlite3 build-essential
EOF

echo "[5/12] Cloning TERMSC-P1-X repository..."
cd ~
git clone https://your-repo-url/termsc-p1-x.git
cd termsc-p1-x

echo "[6/12] Setting up SQL artifact DB..."
cd devbox
sqlite3 devbox.db < schema.sql
cd ..

echo "[7/12] Installing Python dependencies..."
pip install fastapi uvicorn pydantic websockets

echo "[8/12] Starting Scheduler & Worker Runtime..."
cd scheduler
nohup python scheduler_runtime_loop.py > scheduler.log 2>&1 &

echo "[9/12] Starting Federation server..."
cd ../federation
nohup uvicorn federation_node:app --host 0.0.0.0 --port 8001 > federation.log 2>&1 &

echo "[10/12] Starting Dashboard backend..."
cd ../dashboard/backend
nohup uvicorn control_api:app --host 0.0.0.0 --port 8000 > dashboard_backend.log 2>&1 &

echo "[11/12] Starting Dashboard frontend..."
cd ../frontend
npm install
nohup npm start > dashboard_frontend.log 2>&1 &

echo "[12/12] Starting CLI shell..."
cd ../../cli
nohup python termsc_sh.py > cli.log 2>&1 &

echo "✅ TERMSC-P1-X bootstrap complete!"
echo "Scheduler, Federation, Dashboard, DevBox, and CLI are running in background."
echo "Check logs in their respective directories."