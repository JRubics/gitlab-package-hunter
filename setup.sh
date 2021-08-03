sudo apt-get update -y
# Install base packages.
sudo apt-get -y install dkms build-essential linux-headers-$(uname -r) apt-transport-https ca-certificates gnupg lsb-release

# Register apt repositories for Falco and Docker.
curl -s https://falco.org/repo/falcosecurity-3672BA8F.asc | sudo apt-key add -
echo "deb https://download.falco.org/packages/deb stable main" | sudo tee -a /etc/apt/sources.list.d/falcosecurity.list

# Install Falco.
sudo apt-get -y update
sudo apt-get -y install falco=0.23.0

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
sudo mkdir /etc/falco/certs
sudo mv server.key /etc/falco/certs/
sudo mv server.crt /etc/falco/certs/
sudo mv ca.crt /etc/falco/certs/
sudo mv client.key /etc/falco/certs/
sudo mv client.crt /etc/falco/certs/
sudo mv client.csr /etc/falco/certs/
## Make files world-readable.
sudo chmod +r /etc/falco/certs/*

git clone https://gitlab.com/gitlab-org/security-products/package-hunter.git

cd package-hunter
sudo cp falco/falco_rules.local.yaml /etc/falco/ && service falco restart
npm ci

# copy files server.crt, client.crt, and client.key that have been created
# during the configuration of Falco's gRPC API in this directory
# cp server.crt client.crt client.key .

DEBUG=pkgs* nohup node src/server.js &
sleep 10
curl http://localhost:3000

# Install Falco driver
# falco-driver-loader
