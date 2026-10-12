# wrangler-termux

Run [`wrangler`](https://developers.cloudflare.com/workers/wrangler/) on Termux (Android).

`wrangler` hard-imports `workerd` (local dev runtime); its npm package has no
android binary and throws at import — the CLI dies before any command runs.
`deploy`, `secret`, `whoami`, `tail` never execute workerd, so this installer
defers its platform lookup behind a stub. Full CLI except `wrangler dev`.

```
curl -fsSL https://raw.githubusercontent.com/bd-loser/wrangler-termux/main/install.sh | bash
```

Idempotent. Patches the installed wrangler in place; re-run after
`npm update -g wrangler` (the installer detects a changed upstream
bootstrap and fails loudly instead of half-patching).

Tested: wrangler 4.149.0, Termux aarch64, node 26. Used to deploy
[bd-loser/opencode-relay](https://github.com/bd-loser/opencode-relay).
