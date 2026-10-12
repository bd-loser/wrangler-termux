#!/usr/bin/env bash
# Install Cloudflare wrangler on Termux/Android.
#
# wrangler hard-depends on `workerd` (the local V8 runtime for `wrangler
# dev`), whose npm package has no android binary and throws at import,
# killing the CLI before any subcommand runs. deploy/secret/tail never
# execute workerd, so we defer its platform lookup behind a stub path at
# install time and the CLI works fully for everything except local dev.
#
#   curl -fsSL https://raw.githubusercontent.com/bd-loser/wrangler-termux/main/install.sh | bash
set -eu

echo "→ npm i -g wrangler --ignore-scripts"
npm i -g wrangler --ignore-scripts

MAIN="$(npm root -g)/wrangler/node_modules/workerd/lib/main.js"
if [ ! -f "$MAIN" ]; then
  echo "error: $MAIN not found — wrangler layout changed" >&2
  exit 1
fi

node -e '
const fs = require("fs");
const p = process.argv[1];
const s = fs.readFileSync(p, "utf8");
const OLD = "var { binPath } = generateBinPath();";
const NEW = "/* termux-patch (bd-loser/wrangler-termux): no workerd build for android; only `wrangler dev` needs it */ var binPath; try { binPath = generateBinPath().binPath; } catch { binPath = \"/dev/null\"; }";
if (s.includes("termux-patch")) { console.log("already patched"); process.exit(0); }
if (!s.includes(OLD)) {
  console.error("error: workerd bootstrap changed; update the patch pattern in install.sh");
  process.exit(1);
}
fs.writeFileSync(p, s.replace(OLD, NEW));
console.log("patched workerd bootstrap");
' "$MAIN"

if wrangler --version >/dev/null 2>&1; then
  echo "OK: $(wrangler --version) — deploy/secret/whoami/tail work; 'wrangler dev' does not (needs the workerd binary)."
else
  echo "error: wrangler still fails to start" >&2
  exit 1
fi
