#!/usr/bin/env bash

# Determine if we're in a terminal or GUI context
if [ -t 0 ]; then
  # We're in a terminal
  exec alacritty -e yazi "$@"
else
  # We're in a GUI context
  exec thunar "$@"
fi
