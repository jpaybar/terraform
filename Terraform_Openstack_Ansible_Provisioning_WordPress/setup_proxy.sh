#!/bin/bash

echo 'export http_proxy="http://10.40.56.3:8080"' | sudo tee -a /etc/environment
echo 'export https_proxy="http://10.40.56.3:8080"' | sudo tee -a /etc/environment
echo 'export no_proxy="localhost,127.0.0.1,192.168.56.0/24,192.168.56.224/27"' | sudo tee -a /etc/environment
