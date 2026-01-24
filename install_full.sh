apt update -y
apt install python openjdk-17 git clang go rust sqlite -y

proot-distro install ubuntu
proot-distro login ubuntu <<EOF
apt update
apt install -y python3 python3-pip r-base julia swift kotlin gradle \
               nodejs npm sqlite3 build-essential
EOF