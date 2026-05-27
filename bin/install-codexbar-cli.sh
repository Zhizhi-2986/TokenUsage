#!/usr/bin/env bash
set -euo pipefail

APP="/Applications/TokenUsage.app"
HELPER="$APP/Contents/Helpers/TokenUsageCLI"
TARGETS=("/usr/local/bin/tokenusage" "/opt/homebrew/bin/tokenusage")

if [[ ! -x "$HELPER" ]]; then
  echo "TokenUsageCLI helper not found at $HELPER. Please reinstall TokenUsage." >&2
  exit 1
fi

install_script=$(mktemp)
cat > "$install_script" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
HELPER="__HELPER__"
TARGETS=("/usr/local/bin/tokenusage" "/opt/homebrew/bin/tokenusage")

for t in "${TARGETS[@]}"; do
  mkdir -p "$(dirname "$t")"
  ln -sf "$HELPER" "$t"
  echo "Linked $t -> $HELPER"
done
EOF

perl -pi -e "s#__HELPER__#$HELPER#g" "$install_script"

osascript -e "do shell script \"bash '$install_script'\" with administrator privileges"
rm -f "$install_script"

echo "TokenUsage CLI installed. Try: tokenusage usage"
