#!/usr/bin/env bash
# $mod+grave: toggle a drop-down scratch terminal. It's backed by a named
# tmux session ("quick") running fish - so besides the instant i3
# scratchpad show/hide locally, you can also pick the exact same session
# up from any other terminal with: tmux attach -t quick

if ! i3-msg -t get_tree | grep -q '"instance": *"scratchterm"'; then
  setsid alacritty --class Alacritty,scratchterm -e tmux new-session -A -s quick fish >/dev/null 2>&1 &
  disown
  for _ in $(seq 1 20); do
    i3-msg -t get_tree | grep -q '"instance": *"scratchterm"' && break
    sleep 0.1
  done
fi

i3-msg -q scratchpad show
