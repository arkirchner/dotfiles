{ pkgs }:

# Attach or create tmux session named the same as current directory.
pkgs.writeShellScriptBin "tat" (builtins.readFile ../../bin/tat)

