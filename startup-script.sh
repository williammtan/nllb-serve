#!/bin/bash

apt-get update
apt-get tmux

pip install virtualenv
python -m venv env
source env/bin/activate

pip install -e .

# setup ngrok
curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc \
	| sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null \
	&& echo "deb https://ngrok-agent.s3.amazonaws.com buster main" \
	| sudo tee /etc/apt/sources.list.d/ngrok.list \
	&& sudo apt update \
	&& sudo apt install ngrok

echo -n Ngrok AuthToken: 
read -s authtoken

ngrok config add-authtoken ${authtoken}

echo -n Model:
read -s model

tmux new-session -d -s nllb_serve 'nllb-serve -mi ${model}'

echo -n Edge:
read -s edge

tmux split-window -h -t nllb_serve 'ngrok tunnel --label edge=${edge} http://localhost:6060'

