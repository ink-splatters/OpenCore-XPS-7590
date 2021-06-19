#!/usr/bin/env zsh

if [[ $# -gt 0 && "$1" != "--enc" && "$1" != "--dec" ]]; then
  echo 'bootstraps git lfs'
  echo 'encodes / decodes config.plist'
  echo 'usage: $0 [--enc|--dec]'
  exit 0
fi

set -e

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# ---- utils ----

run() {
  echo "$@" | tee >(xargs -I{} zsh -c "echo \"\e[92m{}\e[0m\"") | xargs -I{} bash -c "{}"
}

err() {
  echo "\e[1m\e[31merror: $*\e[0m"
}

warn() {
  echo "\e[1m\e[33m-- $*\e[0m"
}

out() {
  echo "\e[34m-- $*\e[0m"
}

lfs_track() {
  run "git lfs track $@"
}

check_exists() {
  if ! command -v "$1" >/dev/null 2>&1; then
    err "ain't gonna work without git!"
    exit 1
  fi
}

prepare() {
  check_exists shasum
  check_exists openssl

  warn "make sure now your password is in the clipboard! password fingerprint:"
  pbpaste | shasum -a 256 | tr -d ' -' | shasum -a 256

  echo
  echo "press <Space> to continue or <Ctrl + C> to abort..."
  read -s -d ' '
}

iv_file="$script_dir/OC/config.iv"

encrypt() {
  warn "encrypting (ignored) config.plist containing PlatformInfo. you should be knowing what you are doing!"
  warn "note that openssl initialization vector file: $iv_file will be now overriten!"
  prepare

  # shellcheck disable=SC2140
  run "openssl rand -hex 16 | tee >(xargs echo "iv:") > $iv_file"
  run "pbpaste | shasum -a 256 | tr -d \" -\" | openssl enc -aes-256-cbc -nosalt -e -kfile /dev/stdin -iv $(cat $iv_file) -in \"$script_dir/OC/config.plist\" -out \"$script_dir/OC/config.enc\""
  out "Done!"

}

decrypt() {
  prepare

  set +e
  run "pbpaste | shasum -a 256 | tr -d \" -\" | openssl enc -aes-256-cbc -nosalt -d -kfile /dev/stdin -iv $(cat $iv_file) -in \"$script_dir/OC/config.enc\" 1> \"$script_dir/OC/config.dec\" 2> /dev/stdout"
  if [[ $? != 0 ]]; then
    err "decryption failed!"
    rm -f "$script_dir/OC/confic.dec"
    exit 1
  fi
  out "decrypted file stored: $script_dir/OC/config.dec. you should manually rename it to config.plist if needed"
  set -e

}

process_files() {
  local filter=("*.efi" "*.icns" ".*Contents/MacOS.*" "*.bin" "*.lbl" "*.l2x" "*.png" )

  for f in "${filter[@]}"; do lfs_track $f; done
  echo

  out "adding files..."
  run git add "OC" "BOOT" "README" .gitattributes 
}

init_lfs() {

  out "initializing lfs..."
  check_exists git

  run git lfs update
}

# -- flow

if [[ "$1" == "--dec" ]]; then
  decrypt
  exit 0
fi

if [[ "$1" == "--enc" ]]; then
  encrypt
  exit 0
fi

process_files

out "bootstrap finished. ready to commit!"
