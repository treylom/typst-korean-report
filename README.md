# typst-korean-report

한국어/영문 혼합 보고서를 위한 Typst 템플릿 + Claude Code 스킬 + 자동 검증 시스템.

> **Typst가 처음이라면** — 아래 [설치](#설치) 섹션만 따라하면 5분 내에 첫 PDF를 만들 수 있습니다.

## 미리보기

| 기술 보고서 | Daily Briefing | 비즈니스 |
|:---:|:---:|:---:|
| ![tech](examples/preview-tech.png) | ![daily](examples/preview-daily.png) | ![biz](examples/preview-biz.png) |

## 특징

- **한국어 타이포그래피 최적화** — Pretendard / Noto Sans KR / NanumGothic 자동 폴백
- **4가지 색상 팔레트** — 기술(Blue), 비즈니스(Dark), 학술(Purple), 강의(Teal)
- **유틸리티 함수** — callout, badge, info-block, 줄무늬 테이블
- **자동 검증 루프** — PyMuPDF 기반 고아 제목(orphan heading) 탐지 + quality_score 채점
- **Claude Code 스킬** — `.claude/skills/`에 복사하면 `/typst-report` 명령으로 바로 사용

## 설치

### 1. Typst 설치

```bash
# macOS
brew install typst

# Windows (winget)
winget install --id Typst.Typst

# Linux / WSL
curl -fsSL https://typst.community/typst-install/install.sh | bash

# 설치 확인
typst --version
```

### 2. 한국어 폰트 설치

```bash
# macOS — Pretendard (추천)
brew install --cask font-pretendard

# 또는 NanumGothic (대체)
brew install --cask font-nanum-gothic

# Linux / WSL
sudo apt install fonts-nanum

# 폰트 확인
typst fonts | grep -i "pretendard\|nanum\|noto"
```

### 3. 검증 도구 (선택)

```bash
# PyMuPDF — orphan heading 자동 탐지용
pip install pymupdf
```

### 4. 이 레포 클론

```bash
git clone https://github.com/treylom/typst-korean-report.git
cd typst-korean-report
```

## 빠른 시작

### 첫 PDF 만들기 (1분)

```bash
# 템플릿 복사
cp skill/references/template.typ my-report.typ

# 내용 수정 후 컴파일
typst compile my-report.typ my-report.pdf

# 워치 모드 (수정할 때마다 자동 재컴파일)
typst watch my-report.typ
```

### 예제 실행

```bash
# 기술 보고서 예제
typst compile examples/tech-report.typ examples/tech-report.pdf

# Daily Briefing 예제
typst compile examples/daily-briefing.typ examples/daily-briefing.pdf
```

## 디렉토리 구조

```
typst-korean-report/
├── README.md                          # 이 파일
├── skill/
│   ├── SKILL.md                       # Claude Code 스킬 정의
│   └── references/
│       └── template.typ               # 기본 템플릿
├── examples/
│   ├── tech-report.typ                # 기술 보고서 예제
│   ├── daily-briefing.typ             # Daily Briefing 예제 (베이지+블랙)
│   └── business-report.typ            # 비즈니스 보고서 예제
├── scripts/
│   └── verify-pdf.py                  # PyMuPDF 검증 스크립트
└── CLAUDE.md                          # Claude Code 프로젝트 규칙
```

## Claude Code 스킬로 사용하기

이 레포의 스킬을 Claude Code에 설치하면, 대화 중 "PDF 보고서 만들어줘"라고 말하는 것만으로 자동으로 Typst 보고서가 생성됩니다.

### 설치 방법

```bash
# 방법 1: 직접 복사
cp -r skill/ /path/to/your-project/.claude/skills/typst-report/

# 방법 2: 심볼릭 링크
ln -s $(pwd)/skill /path/to/your-project/.claude/skills/typst-report
```

### 사용 예시

Claude Code에서:
```
> Typst로 주간 보고서 PDF 만들어줘
> 베이지+블랙 테마로 Daily Briefing PDF 생성
> 이 데이터를 학술 보고서 형태로 정리해줘
```

스킬이 자동으로:
1. 데이터 분석 → checklist 생성
2. .typ 파일 생성 (템플릿 기반)
3. `typst compile` 실행
4. PyMuPDF로 검증 (orphan heading, 페이지 잘림)
5. quality_score ≥ 0.8 될 때까지 자동 수정 루프
6. 최종 PDF 출력

## 색상 팔레트

| 용도 | accent | 조합 | 사용 예 |
|------|--------|------|---------|
| 기술 보고서 | `#4A6FA5` (Blue) | + `#27AE60` (Green) | API 문서, 기술 분석 |
| 비즈니스 | `#2C3E50` (Dark) | + `#E67E22` (Orange) | 경영 보고서, 제안서 |
| 학술 | `#8E44AD` (Purple) | + `#2980B9` (Blue) | 논문, 연구 보고서 |
| 강의안 | `#16A085` (Teal) | + `#E74C3C` (Red) | 교육 자료, 핸드아웃 |
| Daily Briefing | `#1A1A1A` (Black) | + `#C8956C` (Beige) | 일일 브리핑, 모닝 레포트 |

## 유틸리티 함수

### callout

```typst
#callout(title: "중요", color: danger)[
  주의가 필요한 내용입니다.
]
```

### badge

```typst
완료 #badge("DONE", color: success) / 진행중 #badge("WIP", color: warning)
```

### 줄무늬 테이블

```typst
#figure(
  table(
    columns: (auto, 1fr, auto),
    fill: (_, y) => if y == 0 { accent.lighten(80%) }
                     else if calc.odd(y) { luma(245) },
    stroke: 0.5pt + luma(200),
    inset: 7pt,
    [*항목*], [*설명*], [*수치*],
    [A], [설명 A], [100],
    [B], [설명 B], [200],
  ),
  caption: [테이블 제목],
)
```

## 자동 검증 시스템

PDF 생성 후 자동 품질 검증:

```bash
python scripts/verify-pdf.py my-report.pdf
```

### 검증 항목

| 항목 | 가중치 | 설명 |
|------|--------|------|
| accuracy | 0.35 | 원본 데이터 대비 수치 일치율 |
| layout | 0.25 | 페이지 잘림 0건=1.0, 1건=0.7, 2+건=0.3 |
| completeness | 0.25 | checklist 항목 포함률 |
| compilation | 0.15 | error=0, warning-only=0.8, clean=1.0 |

**통과 기준: quality_score ≥ 0.8**

### Orphan Heading 탐지

페이지 마지막에 제목만 있고 내용이 다음 페이지로 넘어가는 "고아 제목"을 자동 감지합니다:

```bash
python scripts/verify-pdf.py report.pdf --check-orphans
```

해결 방법:
```typst
// 제목 + 내용을 함께 묶기
#block(breakable: false)[
  == 섹션 제목
  내용...
]

// 또는 제목 전에 페이지 나누기
#pagebreak()
== 섹션 제목
```

## 자주 하는 실수

| 실수 | 해결 |
|------|------|
| `font: "Noto Sans CJK KR"` | CJK 통합폰트 미설치 → `"Noto Sans KR"` 사용 |
| 테이블 컬럼 수 불일치 | `columns` 수와 셀 수가 정확히 맞아야 함 |
| `#` 이스케이프 누락 | 순위 등에서 `\#` 또는 `[*\#*]` 사용 |
| 이모지 깨짐 | 시스템 이모지 폰트 의존 → 텍스트 대체 권장 |
| WSL에서 PDF 권한 거부 | `/tmp/`에 생성 후 `cp`로 복사 |

## 라이선스

MIT License

## 기여

PR 환영합니다! 특히:
- 새로운 색상 팔레트 추가
- 추가 예제 템플릿
- 검증 스크립트 개선
- 다국어(일본어/중국어) 지원
