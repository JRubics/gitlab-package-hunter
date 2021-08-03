# Trust the falcosecurity GPG key, configure the apt repository, and update the package list
sudo curl -s https://falco.org/repo/falcosecurity-3672BA8F.asc | sudo apt-key add -
sudo echo "deb https://download.falco.org/packages/deb stable main" | sudo tee -a /etc/apt/sources.list.d/falcosecurity.list
# sudo apt-get update -y

# # Install kernel headers
# sudo apt-get -y install linux-headers-$(uname -r)

# # Install Falco
# sudo apt-get -y install falco=0.23.0

# falco -v
# git clone https://gitlab.com/gitlab-org/security-products/package-hunter.git
# cd package-hunter
# cp falco/falco_rules.local.yaml /etc/falco/ && service falco restart
# npm ci

# // copy files server.crt, client.crt, and client.key that have been created
# // during the configuration of Falco's gRPC API in this directory
# cp ~/server.crt ~/client.crt ~/client.key .

# DEBUG=pkgs* node src/server.js
