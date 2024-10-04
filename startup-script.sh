#!/bin/bash

apt-get update
apt-get install tmux

pip install virtualenv
python -m venv env
source env/bin/activate

pip install -e .

# setup ngrok
curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc \
	|  tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null \
	&& echo "deb https://ngrok-agent.s3.amazonaws.com buster main" \
	|  tee /etc/apt/sources.list.d/ngrok.list \
	&&  apt update \
	&&  apt install ngrok

echo -n Ngrok AuthToken: 
read -s authtoken

ngrok config add-authtoken ${authtoken}

echo -n Model:
read -s model

tmux new-session -d -s nllb
tmux split-window -h

# Run command1 in the first pane (left pane)
tmux send-keys -t nllb:0.0 'nllb-serve -mi ${model}' C-m

echo -n Edge:
read -s edge

# Run command2 in the second pane (right pane)
tmux send-keys -t nllb:0.1 'ngrok tunnel --label edge=${edge} http://localhost:6060' C-m


