#!/usr/bin/env bash
#
# run-claude.sh -- container entrypoint.
#
# Layer 1 (the OS boundary) is the hardened rootless container itself.
# Layer 2 (defense in depth) is srt, which wraps the whole Claude process and
# enforces the network allowlist + filesystem rules from ~/.srt-settings.json.
# Two independent boundaries: one failing shouldn't reach the host.

set -euo pipefail

# CUDA writes its JIT compile cache here; ensure it exists on the tmpfs.
mkdir -p "${CUDA_CACHE_PATH:-/tmp/cuda-cache}"

# Layer 2 (srt) is currently DISABLED BY DEFAULT (USE_SRT defaults to 0).
# Re-enable the inner sandbox per-run with USE_SRT=1, or flip this default back
# to 1 to make srt the standard again. With srt off, Layer 1 (the hardened
# rootless container) is the only boundary and network egress is unrestricted.
if [ "${USE_SRT:-0}" = "1" ]; then
  exec srt --settings "$HOME/.srt-settings.json" \
    claude --dangerously-skip-permissions "$@"
else
  echo "WARNING: srt layer disabled (USE_SRT=0). Container is the only boundary." >&2
  exec claude --dangerously-skip-permissions "$@"
fi
