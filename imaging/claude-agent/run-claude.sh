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

# USE_SRT=0 bypasses the inner sandbox -- useful ONLY for debugging whether
# srt's bubblewrap initializes inside the container (see README "nested seam").
# Leave it at 1 for normal operation.
if [ "${USE_SRT:-1}" = "1" ]; then
  exec srt --settings "$HOME/.srt-settings.json" \
    claude --dangerously-skip-permissions "$@"
else
  echo "WARNING: srt layer disabled (USE_SRT=0). Container is the only boundary." >&2
  exec claude --dangerously-skip-permissions "$@"
fi
