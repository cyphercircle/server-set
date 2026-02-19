#!/bin/bash
set -e

# 1️⃣ Update & Install Packages
echo "[DEPLOY] Installing dependencies on local node..."
pkg update -y
pkg install -y python nodejs rust busybox git sqlite clang sshpass tmux

pip install --upgrade pip
pip install torch scipy numpy sympy networkx flask flask_socketio pyyaml
npm install -g brain.js express

# 2️⃣ Create Folder Structure
echo "[DEPLOY] Creating folders..."
mkdir -p ~/sbc2048/{devcontainer/{builders,cache,plugins},neural,ports,buffer/{stageA,stageB,stageC},cli,control,db,artifacts,cluster,dashboard}

# 3️⃣ Initialize Buffers & Caches
for stage in stageA stageB stageC; do
    busybox dd if=/dev/zero of=~/sbc2048/buffer/$stage/swap.bin bs=1M count=64
done
langs="python node rust perl dart r swift pascal d"
for L in $langs; do
    mkdir -p ~/sbc2048/devcontainer/cache/L2/$L
    busybox dd if=/dev/zero of=~/sbc2048/devcontainer/cache/L2/$L/cache.bin bs=1M count=128
done

# 4️⃣ Copy nodes.json to cluster folder
if [ ! -f ~/sbc2048/cluster/nodes.json ]; then
    echo "[DEPLOY] Creating default cluster nodes.json..."
    cat > ~/sbc2048/cluster/nodes.json <<EOF
{
  "nodes": [
    {"name": "MIT","ip":"192.168.1.101","areas":["Natural Science","Mathematics","Engineering"]},
    {"name": "TUM","ip":"192.168.1.102","areas":["Economics","Philosophy","Politics"]},
    {"name": "Tokyo University","ip":"192.168.1.103","areas":["Mathematics","Natural Science","Engineering"]}
  ]
}
EOF
fi

# 5️⃣ Launch Cluster Services
echo "[DEPLOY] Launching local services via tmux..."
tmux new-session -d -s devcli "python ~/sbc2048/cli/user_cli.py"
tmux new-session -d -s ports "python ~/sbc2048/ports/port_server.py"
for port in 9101 9102 9103 9104 9105; do
    tmux new-session -d -s neural_$port "python ~/sbc2048/neural/neural_port_server.py $port"
done
tmux new-session -d -s control "python ~/sbc2048/control/server.py"
tmux new-session -d -s admin "python ~/sbc2048/control/admin_api.py"
tmux new-session -d -s sync "python ~/sbc2048/cluster/sync.py"

# 6️⃣ Federation Sync Across Nodes
echo "[DEPLOY] Starting federation sync to all nodes..."
for node_ip in $(jq -r '.nodes[].ip' ~/sbc2048/cluster/nodes.json); do
    if [ "$node_ip" != "$(hostname -I | awk '{print $1}')" ]; then
        echo "[DEPLOY] Syncing to $node_ip..."
        sshpass -p "password" rsync -avz ~/sbc2048/ user@$node_ip:~/sbc2048/
        sshpass -p "password" ssh user@$node_ip "bash ~/sbc2048/deploy_node.sh"
    fi
done

echo "[DEPLOY] SBC2048 Federation deployed. Open dashboard at ~/sbc2048/dashboard/index.html"
