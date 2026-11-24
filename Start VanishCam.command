#!/bin/bash
# Launch VanishCam into OBS Virtual Camera for Teams and Google Meet.
set -euo pipefail
cd "$(dirname "$0")"

PY="./.venv/bin/python"
if [[ ! -x "$PY" ]]; then
  echo "VanishCam's Python environment is missing."
  echo "Expected: $(pwd)/.venv"
  exit 1
fi

if pgrep -xq OBS; then
  echo "Quit OBS Studio first."
  echo "VanishCam feeds OBS Virtual Camera itself. If OBS is also running its virtual camera, Meet and Teams see the OBS scene instead."
  exit 1
fi

ext_line="$(systemextensionsctl list 2>/dev/null | grep 'com.obsproject.obs-studio.mac-camera-extension' || true)"
if [[ -z "$ext_line" ]]; then
  echo "OBS Virtual Camera is not installed yet."
  echo "Opening OBS. Click Start Virtual Camera, allow the camera extension, then quit OBS and run this again."
  open -a OBS
  exit 1
fi

if grep -q "waiting for user" <<<"$ext_line"; then
  echo "macOS still needs you to allow OBS Virtual Camera."
  echo "In System Settings → General → Login Items & Extensions → Camera Extensions, turn OBS Virtual Camera on."
  echo "Then double-click this file again."
  open "x-apple.systempreferences:com.apple.LoginItems-Settings.extension" || true
  exit 1
fi

echo "VanishCam is starting."
echo "In Teams or Google Meet, choose the camera named: OBS Virtual Camera"
echo "Step out of frame for 4 seconds so it can learn the background."
echo "V sign vanishes you. R brings you back. Q quits."
echo

exec "$PY" vanish_cam.py --virtual-camera --virtual-backend obs --width 1280 --height 720 "$@"
