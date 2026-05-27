---
summary: "Homebrew Cask release steps for TokenUsage (Sparkle-disabled builds)."
read_when:
  - Publishing a TokenUsage release via Homebrew
  - Updating the Homebrew tap cask definition
---

# TokenUsage Homebrew Release Playbook

Homebrew is for the UI app via Cask. When installed via Homebrew, TokenUsage disables Sparkle and shows a "update via brew" hint in About.

## Prereqs
- Homebrew installed.
- Access to the tap repo: `../homebrew-tap`.

## 1) Release TokenUsage normally
Follow `docs/RELEASING.md` to publish `TokenUsage-<version>.zip` to GitHub Releases.

## 2) Update the Homebrew tap cask
In `../homebrew-tap`, add/update the cask at `Casks/tokenusage.rb`:
- `url` points at the GitHub release asset: `.../releases/download/v<version>/TokenUsage-<version>.zip`
- Update `sha256` to match that zip.
- Keep `depends_on arch: :arm64` and `depends_on macos: ">= :sonoma"` (TokenUsage is macOS 14+).

## 2b) Update the Homebrew tap formula (CLI)
In `../homebrew-tap`, add/update the formula at `Formula/tokenusage.rb`:
- `url` points at the GitHub release assets:
  - macOS: `.../releases/download/v<version>/TokenUsageCLI-v<version>-macos-arm64.tar.gz`
  - macOS: `.../releases/download/v<version>/TokenUsageCLI-v<version>-macos-x86_64.tar.gz`
  - Linux: `.../releases/download/v<version>/TokenUsageCLI-v<version>-linux-aarch64.tar.gz`
  - Linux: `.../releases/download/v<version>/TokenUsageCLI-v<version>-linux-x86_64.tar.gz`
- Update all `sha256` values to match those tarballs.

## 3) Verify install
```sh
brew uninstall --cask tokenusage || true
brew untap steipete/tap || true
brew tap steipete/tap
brew install --cask steipete/tap/tokenusage
open -a TokenUsage
```

## 4) Push tap changes
Commit + push in the tap repo.
