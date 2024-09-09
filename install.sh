#!/bin/bash

# Update system packages and install prerequisites
echo "Updating system packages and installing prerequisites..."
sudo apt-get update -y
sudo apt-get install -y git curl python3 python3-pip zenity

# Install Go if not already installed
if ! command -v go &> /dev/null; then
    echo "Go not found. Installing Go..."
    wget https://golang.org/dl/go1.17.1.linux-amd64.tar.gz
    sudo tar -C /usr/local -xzf go1.17.1.linux-amd64.tar.gz
    export PATH=$PATH:/usr/local/go/bin
    echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.bashrc
    source ~/.bashrc
else
    echo "Go is already installed."
fi

# Install tools using Go
echo "Installing subfinder, httpx, waybackurls, and nuclei..."
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
go get -u github.com/tomnomnom/waybackurls
go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest

# Clone and set up subdomain takeover tool
echo "Cloning and setting up subdomain takeover tool..."
git clone https://github.com/EdOverflow/can-i-take-over-xyz.git
cd can-i-take-over-xyz
pip3 install -r requirements.txt
cd ..

echo "Installation complete! All tools are ready to use."
