#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: delete_gitignored.sh [--dry-run] repo-dir

Deletes files and directories matched by the repository .gitignore (ignores any global rules).
Use --dry-run to list what would be removed without deleting anything.
EOF
}

dry_run=false

repo_arg=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) dry_run=true ;;
    -h|--help)
      usage
      exit 0
      ;;
    --*)
      usage
      exit 1
      ;;
    *)
      if [[ -n "$repo_arg" ]]; then
        usage
        exit 1
      fi
      repo_arg="$1"
      ;;
  esac
  shift
done

if [[ -z "$repo_arg" ]]; then
  usage
  exit 1
fi

repo_dir="$repo_arg"
repo_root="$(git -C "$repo_dir" rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$repo_root" ]]; then
  echo "Not inside a git repository." >&2
  exit 1
fi

ignore_file="$repo_root/.gitignore"
if [[ ! -f "$ignore_file" ]]; then
  echo "No .gitignore found at $ignore_file." >&2
  exit 1
fi

# --no-standard-ignore ensures we only honor the repo's .gitignore and ignore any global rules.
paths=()
tmp_out="$(mktemp)"
tmp_err="$(mktemp)"
cleanup() { rm -f "$tmp_out" "$tmp_err"; }
trap cleanup EXIT

ls_args=(
  ls-files -z
  --others
  --ignored
  --exclude-from="$ignore_file"
  --directory
  --no-empty-directory
)

run_ls() {
  git -C "$repo_root" -c core.excludesFile=/dev/null "$@" >"$tmp_out" 2>"$tmp_err"
}

# First attempt: default settings (global ignores disabled for this command only).
if ! run_ls "${ls_args[@]}"; then
  if grep -qi 'fsmonitor' "$tmp_err"; then
    # Retry with fsmonitor disabled for this command only to silence daemon errors.
    if ! run_ls -c core.fsmonitor=false "${ls_args[@]}"; then
      cat "$tmp_err" >&2
      exit 1
    fi
  else
    cat "$tmp_err" >&2
    exit 1
  fi
elif grep -qi 'fsmonitor' "$tmp_err"; then
  # Command succeeded but fsmonitor complained; rerun with fsmonitor disabled for this command only.
  if ! run_ls -c core.fsmonitor=false "${ls_args[@]}"; then
    cat "$tmp_err" >&2
    exit 1
  fi
fi

while IFS= read -r -d '' path; do
  paths+=("$path")
done <"$tmp_out"

if [[ ${#paths[@]} -eq 0 ]]; then
  echo "No paths matched $ignore_file."
  exit 0
fi

echo "Paths ignored by $ignore_file:"
for path in "${paths[@]}"; do
  printf '  %s\n' "$path"
done

if $dry_run; then
  echo "Dry run: nothing deleted."
  exit 0
fi

(
  cd "$repo_root"
  printf '%s\0' "${paths[@]}" | xargs -0 rm -rf --
)

echo "Deleted ${#paths[@]} path(s)."
