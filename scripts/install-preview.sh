#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Install a separate development widget, reusing a compatible local API.
set -euo pipefail
[[ $(id -u) -ne 0 ]] || { echo 'Run without sudo.' >&2; exit 1; }
command -v kpackagetool6 >/dev/null
here="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
stage="$(mktemp -d)"
trap 'rm -rf -- "$stage"' EXIT
cp -a "$here/widget/." "$stage/"
python3 - "$stage/metadata.json" <<'PY'
import json, sys
from pathlib import Path
path=Path(sys.argv[1])
metadata=json.loads(path.read_text())
metadata['KPlugin']['Id']='pt.webnerd.systemmonitor.preview'
metadata['KPlugin']['Name']='Webnerd System Monitor (Preview)'
path.write_text(json.dumps(metadata, indent=2)+'\n')
PY
id='pt.webnerd.systemmonitor.preview'
target="${XDG_DATA_HOME:-$HOME/.local/share}/plasma/plasmoids/$id"
if [[ -e "$target" || -L "$target" ]]; then
  state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/webnerd-system-monitor/backups"
  mkdir -p "$state_dir"
  backup="$(mktemp -d "$state_dir/preview-XXXXXXXX")"
  cp -a -- "$target" "$backup/widget"
  kpackagetool6 --type Plasma/Applet --upgrade "$stage"
else
  kpackagetool6 --type Plasma/Applet --install "$stage"
fi
echo 'Add Webnerd System Monitor (Preview) to the desktop.'
echo 'The original widget and collector have not been replaced.'
echo 'Remove this preview with: kpackagetool6 --type Plasma/Applet --remove pt.webnerd.systemmonitor.preview'
