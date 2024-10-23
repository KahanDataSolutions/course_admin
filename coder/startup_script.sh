# Create placeholder directories
mkdir -p developer/
mkdir -p environment/

echo "Download files from GitHub"
curl -o environment/docker-compose.yml https://raw.githubusercontent.com/KahanDataSolutions/course_admin/refs/heads/main/environment/docker-compose.yml
curl -o environment/pg_hba.conf https://raw.githubusercontent.com/KahanDataSolutions/course_admin/refs/heads/main/environment/pg_hba.conf
curl -o environment/postgresql.conf https://raw.githubusercontent.com/KahanDataSolutions/course_admin/refs/heads/main/environment/postgresql.conf
    
# Install the latest code-server.
# Append "--version x.x.x" to install a specific version of code-server.
curl -fsSL https://code-server.dev/install.sh | sh -s -- --method=standalone --prefix=/tmp/code-server

# Start code-server in the background.
/tmp/code-server/bin/code-server --auth none --port 13337 >/tmp/code-server.log 2>&1 &
    
# Install Git & Python
sudo apt-get update -y
sudo apt install git -y
sudo apt install python3-pip -y
sudo apt-get install python3-venv -y

# Install Docker
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

sudo usermod -aG docker $USER
sudo newgrp docker
sudo systemctl restart docker

# Capture VM IP Address
curl ifconfig.me > environment/ip_address.txt

# Setup Virtual Environment
cd environment
python3 -m venv playground-env
echo "" >> ~/.bashrc
echo "alias playground-env='source /home/admin/environment/playground-env/bin/activate'" >> ~/.bashrc
source ~/.bashrc

# Activate Virtual Environment
playground-env

# Install SlingData
pip install sling
echo "" >> ~/.bashrc
echo 'export DBUS_SESSION_BUS_ADDRESS=/dev/null' >> ~/.bashrc
source ~/.bashrc

# Install dbt Core (Postgres)
pip install --upgrade requests
pip install dbt-postgres==1.8.2

# Pull Docker Images
sudo docker compose pull
