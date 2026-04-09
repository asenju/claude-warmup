#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"
guard_script="${repo_root}/scripts/pacific_warmup_guard.sh"

run_guard() {
  NOW_UTC="$1" "${guard_script}"
}

assert_exit_code() {
  local expected="$1"
  local timestamp="$2"

  set +e
  run_guard "${timestamp}" >/tmp/pacific_warmup_guard_test.out 2>&1
  local actual=$?
  set -e

  if [[ "${actual}" -ne "${expected}" ]]; then
    echo "expected exit code ${expected} for ${timestamp}, got ${actual}" >&2
    cat /tmp/pacific_warmup_guard_test.out >&2 || true
    exit 1
  fi
}

assert_exit_code 0 "2026-04-08T13:15:00Z"
assert_exit_code 78 "2026-04-08T14:15:00Z"
assert_exit_code 0 "2026-12-09T14:15:00Z"
assert_exit_code 78 "2026-12-09T13:15:00Z"
assert_exit_code 78 "2026-04-11T13:15:00Z"

echo "pacific_warmup_guard tests passed"
