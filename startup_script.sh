set -e

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

    # Install PostgreSQL
    sudo apt-get update -y
    sudo apt install postgresql postgresql-contrib -y

    # Allow all IPs in pg_hba.conf
    sudo sed -i '96 a host    all             all             0.0.0.0/0            md5' /etc/postgresql/13/main/pg_hba.conf
    sudo systemctl restart postgresql
    sudo systemctl enable postgresql
   

    # Create placeholder directories
    mkdir -p developer/
    mkdir -p environment/
    

    # Capture IP Address
    hostname -I >> environment/ip_address.txt

    # Install Cloudbeaver
    sudo docker pull dbeaver/cloudbeaver:latest
    sudo docker run --name cloudbeaver -d -p 8200:8978 -v /opt/cloudbeaver/workspace dbeaver/cloudbeaver:latest --restart always

    # Install Metabase
    sudo docker pull metabase/metabase:latest
    sudo docker run --name metabase --rm -p 3000:3000 metabase/metabase -d --restart always


    # Install SlingData
    pip install sling
    echo 'export DBUS_SESSION_BUS_ADDRESS=/dev/null' >> ~/.bashrc
    source ~/.bashrc
