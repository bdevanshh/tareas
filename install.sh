# Install the host-side tooling used by the Tareas backend (Taskfile runner).

set -euo pipefail

# go-task (task) ---------------------------------------------------------
if command -v task >/dev/null 2>&1; then
  echo "task already installed: $(task --version)"
else
  echo "Installing task..."
  curl -1sLf 'https://dl.cloudsmith.io/public/task/task/setup.deb.sh' | sudo -E bash
  sudo apt install task
  echo "Installed task to $BIN_DIR"
fi