#!/data/data/com.termux/files/usr/bin/bash
# TERMSC-P1-X Single Install Script
# Author: Christian Palandt, FH Aachen
# Purpose: Complete one-shot installation and build in Termux

set -e

echo "=== TERMSC-P1-X Installer ==="

# STEP 1: Update Termux
echo "[1/12] Updating Termux packages..."
apt update -y
apt full-upgrade -y

# STEP 2: Install base dependencies
echo "[2/12] Installing dependencies..."
apt install -y proot-distro git python nodejs openjdk-17 clang go rust swift julia gradle sqlite wget curl

# STEP 3: Install Ubuntu devcontainer
echo "[3/12] Installing Ubuntu devcontainer..."
proot-distro install ubuntu

# STEP 4: Install language runtimes inside Ubuntu
echo "[4/12] Installing multi-language runtimes..."
proot-distro login ubuntu <<EOF
aapt update && aapt upgrade -y
apt install -y python3 python3-pip r-base julia swift kotlin gradle nodejs npm sqlite3 build-essential
EOF

# STEP 5: Clone TERMSC-P1-X repository
echo "[5/12] Cloning TERMSC-P1-X repository..."
cd ~
git clone https://your-repo-url/termsc-p1-x.git
cd termsc-p1-x

# STEP 6: Setup SQL DB for DevBox
echo "[6/12] Setting up SQL artifact DB..."
cd devbox
sqlite3 devbox.db < schema.sql
cd ..

#between set android accessing
apt install aapt2 -y
aapt install kotlin-y
aapt install python-torch
aapt install gps whois ip-state location


# STEP 7: Install Python dependencies
echo "[7/12] Installing Python dependencies..."
pip install fastapi uvicorn pydantic websockets

# STEP 8: Start Scheduler & Worker runtime
echo "[8/12] Starting Scheduler & Worker runtime..."
cd scheduler
nohup python scheduler_runtime_loop.py > scheduler.log 2>&1 &
cd ..

# STEP 9: Start Federation server
echo "[9/12] Starting Federation server..."
cd federation
nohup uvicorn federation_node:app --host 0.0.0.0 --port 8001 > federation.log 2>&1 &
cd ..

# STEP 10: Start Dashboard backend
echo "[10/12] Starting Dashboard backend..."
cd dashboard/backend
nohup uvicorn control_api:app --host 0.0.0.0 --port 8000 > dashboard_backend.log 2>&1 &
cd ..

# STEP 11: Start Dashboard frontend
echo "[11/12] Starting Dashboard frontend..."
cd frontend
npm install
nohup npm start > dashboard_frontend.log 2>&1 &
cd ../..

# STEP 12: Start CLI shell
echo "[12/12] Starting CLI shell..."
cd cli
nohup python termsc_sh.py > cli.log 2>&1 &

# STEP 13: Run Validation Suite
echo "[13/12] Running Validation Suite..."
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

echo "✅ TERMSC-P1-X installed, running, and validated!"
echo "Scheduler, Federation, Dashboard, DevBox, and CLI are active."
echo "Logs are available in their respective directories."