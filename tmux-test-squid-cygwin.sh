#!/bin/bash
SESSION=squid

#
# If tmux session "squid" already exists, start a new one and connect to
# it.
#

if [[ ! -z $(tmux list-sessions | cut -d: -f1 | sed 's,$,:,' |
			   xargs | grep -i $SESSION) ]]
then
	tmux kill-session -t $SESSION
fi
tmux new-session -d -s $SESSION
tmux send-keys -t $SESSION:0.0 "net stop squid" C-m
tmux send-keys -t $SESSION:0.0 "kill -9 $(pidof squid)" C-m
tmux send-keys -t $SESSION:0.0 "tail -f /var/log/squid/access.log" C-m

tmux split-window -t $SESSION:0.0 -v
tmux resize-pane -t $SESSION:0.0 -U 15

tmux send-keys -t $SESSION:0.1 'while :; do d1="$(date)"; d2=$(du -sh /e/squidcachedir); echo $d1 $d2; sleep 10; done' C-m
tmux split-window -t $SESSION:0.1 -v
tmux resize-pane -t $SESSION:0.1 -U 10

tmux select-pane -t $SESSION:0.1 # keep pane index order sequential
tmux split-window -t $SESSION:0.1 -h

tmux send-keys -t $SESSION:0.2 "cd /etc/squid" C-m
tmux send-keys -t $SESSION:0.2 "/usr/sbin/squid -NCd1 -f squid.conf" C-m

tmux select-pane -t $SESSION:0.3
tmux split-window -t $SESSION:0.3 -h

tmux send-keys -t $SESSION:0.3 "curl -L --proxy 127.0.0.1:3128 -O http://installer-bin.streambox.com/httpd-2.4.23-win32-VC14.zip" C-m
tmux select-pane -t $SESSION:0.3

tmux select-pane -t $SESSION:0.3
tmux split-window -t $SESSION:0.3 -v
tmux send-keys -t $SESSION:0.4 "curl -L --proxy 127.0.0.1:3128 -O http://packages.chef.io/files/stable/chef/12.15.19/windows/2012r2/chef-client-12.15.19-1-x86.msi"  C-m

tmux send-keys -t $SESSION:0.5 "cd /etc/squid" C-m
tmux send-keys -t $SESSION:0.5 "vim squid.conf" C-m

tmux attach -t $SESSION
