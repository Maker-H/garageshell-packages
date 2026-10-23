#!/bin/sh
# Public package bootstrap. Installs/updates GShell without restarting sessions.
set -eu
base=https://maker-h.github.io/garageshell-packages
fingerprint=889C8A79CC00FACB48F8D40BEFC4FAD4A91B3BBE

fail() { printf '%s\n' "$*" >&2; exit 1; }
root() {
    if [ "$(id -u)" -eq 0 ]; then "$@"; else sudo "$@"; fi
}
[ "$(uname -s)" = Linux ] || fail 'Linux/WSL 서버에서 실행해 주세요.'
[ "$(uname -m)" = x86_64 ] || fail '현재 공개 패키지는 x86_64(amd64)용입니다.'
[ -r /etc/os-release ] || fail '배포판 정보를 찾을 수 없습니다.'
. /etc/os-release
case "$ID" in
    ubuntu|debian) manager=apt ;;
    ol) manager=yum ;;
    *) fail '지원 환경: Ubuntu 22.04 이상, Debian 12 이상, Oracle Linux 7 이상(x86_64).' ;;
esac
major=${VERSION_ID%%.*}
case "$major" in ''|*[!0-9]*) fail '배포판 버전을 확인할 수 없습니다.' ;; esac
case "$ID" in
    ubuntu) [ "$major" -ge 22 ] || fail 'Ubuntu 22.04 이상이 필요합니다.' ;;
    debian) [ "$major" -ge 12 ] || fail 'Debian 12 이상이 필요합니다.' ;;
    ol) [ "$major" -ge 7 ] || fail 'Oracle Linux 7 이상이 필요합니다.' ;;
esac
if [ "$(id -u)" -ne 0 ]; then
    command -v sudo >/dev/null || fail 'sudo가 필요합니다. 또는 root로 실행해 주세요.'
fi
command -v curl >/dev/null || fail 'curl을 먼저 설치해 주세요.'
temporary=$(mktemp -d)
trap 'rm -rf "$temporary"' EXIT HUP INT TERM
curl -fsSL "$base/garageshell.asc" -o "$temporary/garageshell.asc"
if ! command -v gpg >/dev/null && ! command -v gpg2 >/dev/null; then
    if [ "$manager" = apt ]; then
        root apt-get update
        root apt-get install -y gnupg ca-certificates
    else
        root yum install -y gnupg2 ca-certificates
    fi
fi
gpg_command=$(command -v gpg2 || command -v gpg)
mkdir -m 700 "$temporary/keyring"
"$gpg_command" --homedir "$temporary/keyring" --batch --import "$temporary/garageshell.asc" >/dev/null 2>&1
actual=$("$gpg_command" --homedir "$temporary/keyring" --batch --with-colons --fingerprint 2>/dev/null | awk -F: '$1 == "fpr" {print $10; exit}')
[ "$actual" = "$fingerprint" ] || fail 'GarageShell 공개 서명 키 지문이 일치하지 않습니다.'
if [ "$manager" = apt ]; then
    curl -fsSL "$base/garageshell.sources" -o "$temporary/garageshell.sources"
    root install -d -m 755 /etc/apt/keyrings
    root install -m 644 "$temporary/garageshell.asc" /etc/apt/keyrings/garageshell.asc
    root install -m 644 "$temporary/garageshell.sources" /etc/apt/sources.list.d/garageshell.sources
    root apt-get update
    root apt-get install -y gshell
else
    curl -fsSL "$base/garageshell.repo" -o "$temporary/garageshell.repo"
    root rpm --import "$temporary/garageshell.asc"
    root install -m 644 "$temporary/garageshell.repo" /etc/yum.repos.d/garageshell.repo
    root yum install -y gshell
fi
/usr/bin/gshell --version
printf '%s\n' 'GShell 설치/업데이트 완료. 실행 중인 세션은 재시작하지 않았습니다.'
