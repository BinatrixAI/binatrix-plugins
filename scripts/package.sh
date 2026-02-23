#!/usr/bin/env bash
# Build .plugin zip archives from plugin directories
# Usage: ./scripts/package.sh [plugin-name]
# If no plugin name given, packages all plugins in plugins/

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIST_DIR="$REPO_ROOT/dist"

mkdir -p "$DIST_DIR"

package_plugin() {
  local plugin_dir="$1"
  local plugin_name
  plugin_name="$(basename "$plugin_dir")"

  if [[ ! -f "$plugin_dir/.claude-plugin/plugin.json" ]]; then
    echo "Skipping $plugin_name — no .claude-plugin/plugin.json found"
    return
  fi

  local version
  version=$(python3 -c "import json; print(json.load(open('$plugin_dir/.claude-plugin/plugin.json'))['version'])" 2>/dev/null || echo "1.0.0")

  local output="$DIST_DIR/${plugin_name}-${version}.plugin"

  echo "Packaging $plugin_name v$version..."
  (cd "$plugin_dir" && zip -r "$output" . -x '*.DS_Store' -x '__MACOSX/*')
  echo "  -> $output"
}

if [[ $# -gt 0 ]]; then
  # Package specific plugin
  target="$REPO_ROOT/plugins/$1"
  if [[ ! -d "$target" ]]; then
    echo "Error: Plugin directory not found: $target"
    exit 1
  fi
  package_plugin "$target"
else
  # Package all plugins
  for plugin_dir in "$REPO_ROOT"/plugins/*/; do
    [[ -d "$plugin_dir" ]] && package_plugin "$plugin_dir"
  done
fi

echo ""
echo "Done. Archives in $DIST_DIR/"
ls -lh "$DIST_DIR"/*.plugin 2>/dev/null || echo "No archives found."
