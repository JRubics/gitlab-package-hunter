# # Trust the falcosecurity GPG key, configure the apt repository, and update the package list
# curl -s https://falco.org/repo/falcosecurity-3672BA8F.asc | sudo apt-key add -
# echo "deb https://download.falco.org/packages/deb stable main" | sudo tee -a /etc/apt/sources.list.d/falcosecurity.list
# sudo apt-get update -y

# # Install kernel headers
# sudo apt-get -y install linux-headers-$(uname -r)

# # Install Falco
# sudo apt-get -y install falco=0.23.0

# git clone https://gitlab.com/gitlab-org/security-products/package-hunter.git
# cd package-hunter
# cp falco/falco_rules.local.yaml /etc/falco/ && service falco restart
# npm ci

# // copy files server.crt, client.crt, and client.key that have been created
# // during the configuration of Falco's gRPC API in this directory
# cp ~/server.crt ~/client.crt ~/client.key .

# DEBUG=pkgs* node src/server.js
sudo su
apt-get update -y
    # Install base packages.
    apt-get -y install dkms build-essential linux-headers-$(uname -r) apt-transport-https ca-certificates curl gnupg lsb-release

    # Register apt repositories for Falco and Docker.
    curl -s https://falco.org/repo/falcosecurity-3672BA8F.asc | apt-key add -
    echo "deb https://download.falco.org/packages/deb stable main" | tee -a /etc/apt/sources.list.d/falcosecurity.list
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    # Install Docker and Falco.
    apt-get -y update
    apt-get -y install docker-ce docker-ce-cli containerd.io falco=0.23.0

    # Install Node v12.
    wget https://nodejs.org/download/release/v12.22.0/node-v12.22.0-linux-x64.tar.gz
    tar -C /usr/local --strip-components 1 -xzf node-v12.22.0-linux-x64.tar.gz
    rm node-v12.22.0-linux-x64.tar.gz

    # Add user vagrant to docker group to allow it to manage Docker.
    usermod -aG docker vagrant

    # Generate certificates for Falco.
    ## Create a RANDFILE for the root user.
    openssl rand -writerand /root/.rnd
    ## Generate valid CA.
    openssl genrsa -passout pass:1234 -des3 -out ca.key 4096
    openssl req -passin pass:1234 -new -x509 -days 365 -key ca.key -out ca.crt -subj  "/C=SP/ST=Italy/L=Ornavasso/O=Test/OU=Test/CN=Root CA"
    ## Generate valid Server Key/Cert.
    openssl genrsa -passout pass:1234 -des3 -out server.key 4096
    openssl req -passin pass:1234 -new -key server.key -out server.csr -subj  "/C=SP/ST=Italy/L=Ornavasso/O=Test/OU=Server/CN=localhost"
    openssl x509 -req -passin pass:1234 -days 365 -in server.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out server.crt
    ## Remove passphrase from the Server Key.
    openssl rsa -passin pass:1234 -in server.key -out server.key
    ## Generate valid Client Key/Cert.
    openssl genrsa -passout pass:1234 -des3 -out client.key 4096
    openssl req -passin pass:1234 -new -key client.key -out client.csr -subj  "/C=SP/ST=Italy/L=Ornavasso/O=Test/OU=Client/CN=localhost"
    openssl x509 -passin pass:1234 -req -days 365 -in client.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out client.crt
    ## Remove passphrase from Client Key.
    openssl rsa -passin pass:1234 -in client.key -out client.key
    ## Move files to correct location.
    mkdir /etc/falco/certs
    mv server.key /etc/falco/certs/
    mv server.crt /etc/falco/certs/
    mv ca.crt /etc/falco/certs/
    mv client.key /etc/falco/certs/
    mv client.crt /etc/falco/certs/
    mv client.csr /etc/falco/certs/
    ## Make files world-readable.
    chmod +r /etc/falco/certs/*

    # Move Falco configuration file to correct location.
    cp /vagrant/falco/falco.yaml /etc/falco/

    # Install Falco driver
    falco-driver-loader

    # Start Falco
    service falco start
