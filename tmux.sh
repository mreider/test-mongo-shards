#!/bin/bash

tmux new-session -d -s logs 'tail -f shard1.log'
tmux split-window -h 'tail -f shard2.log'
tmux split-window -v 'tail -f configsvr.log'
tmux select-pane -t 0
tmux split-window -v 'tail -f mongos.log'
tmux select-pane -t 2
tmux split-window -v 'tail -f service-a.log'
tmux select-pane -t 4
tmux split-window -v 'tail -f service-b.log'
tmux -2 attach-session -d