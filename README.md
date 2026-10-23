# GarageShell 패키지 저장소

최신 버전: **0.2.0**. Model GShell의 C 터미널 엔진과 Infra GShell의 서버 작업 서비스를 포함합니다.

## 한 줄 설치·업데이트

대상 서버에서 실행합니다. Ubuntu 22.04+ / Debian 12+ / Oracle Linux 7, x86_64를 지원합니다.

```sh
curl -fsSL https://maker-h.github.io/garageshell-packages/install.sh | sh
```

공개 서명 키 지문을 확인한 뒤 서명된 저장소에서 최신 패키지를 설치합니다. 실행 중인 세션은 재시작하지 않습니다.

Ubuntu/WSL용 DEB와 Oracle Linux 7 x86_64용 RPM을 제공합니다. 이 저장소에는 배포 파일과 공개 서명 키만 저장합니다.

## Ubuntu / WSL

최초 1회 저장소를 등록합니다.

```bash
sudo install -d -m 755 /etc/apt/keyrings
curl -fsSL https://maker-h.github.io/garageshell-packages/garageshell.asc | sudo tee /etc/apt/keyrings/garageshell.asc > /dev/null
curl -fsSL https://maker-h.github.io/garageshell-packages/garageshell.sources | sudo tee /etc/apt/sources.list.d/garageshell.sources > /dev/null
sudo apt update
sudo apt install gshell
```

이후 업데이트는 `sudo apt update`와 `sudo apt install --only-upgrade gshell`로 합니다.

## Oracle Linux 7 x86_64

```bash
sudo curl -fsSL https://maker-h.github.io/garageshell-packages/garageshell.repo -o /etc/yum.repos.d/garageshell.repo
sudo yum install gshell
```

이후 업데이트는 `sudo yum update gshell`로 합니다. RPM은 독립 Python 런타임을 `/opt/garageshell/python`에 포함합니다.

## 설정과 실행

```bash
cp /usr/share/doc/gshell/gshellrc.example ~/.gshellrc
gshell --version
gshell start
gshell status
```

`~/.gshellrc`는 새 Bash 세션에서 읽습니다. 업데이트는 설정 파일과 실행 중인 PTY를 보존합니다. 서비스에 새 버전을 적용하려면 작업을 마친 뒤 `gshell stop`·`gshell start`를 실행합니다. `stop`은 현재 Bash/k9s 세션을 종료합니다.

## 서명

APT InRelease, RPM 패키지와 repomd.xml에 서명합니다. 서명 키 지문:

```text
889C8A79CC00FACB48F8D40BEFC4FAD4A91B3BBE
```

공개 키: [https://maker-h.github.io/garageshell-packages/garageshell.asc](https://maker-h.github.io/garageshell-packages/garageshell.asc)

자동 업데이트는 관리자가 APT unattended-upgrades 또는 OS의 패키지 갱신 정책에서 이 저장소를 선택해 설정합니다. 패키지 설치가 자동 재시작을 활성화하지는 않습니다.
