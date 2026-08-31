# leaveguard-application

`LeaveGuard`의 Application 영역을 담당하는 레포지토리다.

사용자 얼굴 인식 결과(`member_id`)를 기반으로 개인별 출근 체크리스트를 조회하고, 객체 인식 결과와 날씨 정보 등을 종합하여 사용자가 챙겨야 할 항목을 Flutter UI에 표시한다.

## Overview

```text
Face Recognition
      │
      │ member_id
      ▼
┌─────────────────────┐
│ LeaveGuard Backend  │
├─────────────────────┤
│ Member Service      │
│ Checklist Service   │
│ Context Service     │
│ Rule Engine         │
└──────────┬──────────┘
           │
     ┌─────┴─────┐
     │           │
     ▼           ▼
 Database    Flutter App
```

## Repository Structure

```text
leaveguard-application/
├── app/
│   └── flutter/              # Flutter 기반 Wallpad UI
│
├── backend/
│   ├── api/                  # Application API
│   ├── services/             # Member / Checklist / Context Service
│   ├── rules/                # 상황 기반 Rule Engine
│   └── models/               # Application Data Model
│
├── database/
│   ├── schema/               # Database Schema
│   ├── migrations/           # Database Migration
│   └── seed/                 # 초기 데이터
│
├── config/
│   ├── members.yaml          # 사용자 설정
│   ├── checklist.yaml        # 체크리스트 설정
│   └── devices.yaml          # 디바이스 설정
│
├── docker/                   # ATLAS 개발환경 (atlas-dev 이미지)
│   ├── Dockerfile            # LG 원본
│   ├── Guide.md              # LG 원본 (Docker 설치·컨테이너 사용 안내)
│   └── (SDK·엔진·플러그인 등 빌드 재료 — 용량 문제로 git 제외, 별도 공유)
│
├── scripts/                  # 실행 및 개발 Utility Script
├── docs/                     # Architecture / API Documentation
├── docker-compose.yml        # 개발 컨테이너 실행 (레포 전체를 /app 마운트)
└── README.md
```

## Development Environment

개발·빌드는 전부 `atlas-dev` Docker 컨테이너 안에서 한다. (크로스컴파일러, `flutter-atlas`, `arc` 포함)

### 1. 최초 1회 — 이미지 빌드

`docker/` 폴더는 git에 올리지 않는다. LG가 제공한 개발환경 폴더(Dockerfile, Guide.md, 빌드 재료 일체)를 팀 드라이브에서 통째로 받아 `docker/` 이름으로 배치한다. 주요 재료:

| 재료 | 역할 |
| --- | --- |
| `atlas-sdk-*.sh` (430M) | ARM64 크로스컴파일 툴체인 (Yocto SDK) |
| `atlas_engine/` | 보드용 Flutter 엔진 바이너리 |
| `flutter-elinux-atlas/` | `flutter-atlas` CLI (Flutter SDK 관리·빌드) |
| `flutter-atlas-plugins/` | LG 공식 Flutter 플러그인 7종 |
| `arc-0.5.0.tgz` | 앱 빌드·IPK 패키징 CLI |

```bash
docker compose build          # 수십 분 소요. Docker 설치법은 docker/Guide.md 참고
```

### 2. 평소 개발

```bash
docker compose up -d
docker compose exec atlas-dev bash
# 컨테이너 안: 크로스컴파일 환경은 아래 한 줄로 활성화됨 (.bashrc에 자동 포함)
#   source /opt/atlas-sdk-x86_64/environment-setup-armv8a-atlas-linux
```

### 3. 앱 빌드 → 보드 배포

```bash
# 컨테이너 안에서: 앱 디렉터리에서 IPK 생성
arc build                     # → build/arm64/ipk/<앱ID>.ipk

# 보드(Raspberry Pi)에 설치·실행
scp <IPK> root@<보드IP>:/tmp/
ssh root@<보드IP> "abusctl call com.atlas.PackageManager1 Install <앱ID> /tmp/<앱ID>.ipk"
ssh root@<보드IP> "abusctl call com.atlas.AppManager1 Start <앱ID>"
# 재설치 시: AppManager1 Stop → PackageManager1 Remove → Install 순서
```

## Main Features

- 사용자별 출근 체크리스트 관리
- 얼굴 인식 결과 기반 사용자 식별
- 객체 탐지 결과 기반 준비물 상태 확인
- 날씨 정보 기반 추가 준비물 판단
- Rule Engine 기반 상황별 알림 생성
- Flutter 기반 Wallpad UI 제공

## Example

```text
사용자 : 아빠

✓ 휴대폰
✓ 지갑
✓ 약

⚠ 자동차 키가 보이지 않습니다.
⚠ 사원증이 보이지 않습니다.

☔ 오늘 비가 올 예정입니다.
   우산을 챙겨주세요.
```

## Related Repositories

```text
leaveguard-application   # Flutter / Backend / Database / Rule Engine
leaveguard-ai            # Face Recognition / Object Detection
leaveguard-platform      # Yocto / BSP / systemd / Deployment
```

## System Target

- Raspberry Pi based board
- LG Yocto-based Embedded Linux
- Local Edge AI inference
- Flutter Wallpad Application
- Local Database
