---
name: typst-report
description: Use when creating PDF reports, documents, or formatted output from data/analysis. Triggers on "보고서", "PDF", "typst", "리포트", "문서화", ".typ 파일". Covers Korean typography, styled tables, callouts, cover pages, and compilation.
---

# Typst Report — Best Practice Guide

Typst로 한국어/영문 혼합 보고서를 생성하는 스킬. `typst compile`로 PDF 출력.

## Quick Reference

```bash
# 컴파일
typst compile report.typ report.pdf

# 폰트 확인
typst fonts | grep -i "pretendard\|noto\|nanum"

# 워치 모드 (개발용)
typst watch report.typ
```

## 사용 가능한 한국어 폰트

| 용도 | 1순위 | 2순위 | 3순위 |
|------|-------|-------|-------|
| 본문 (산세리프) | Pretendard | Noto Sans KR | NanumGothic |
| 본문 (세리프) | NanumMyeongjo | Batang | — |
| 코드 | D2Coding | NanumGothicCoding | — |
| 시스템 | Malgun Gothic | Gulim | Dotum |

## 보고서 템플릿 구조

모든 보고서에 적용할 기본 구조. `references/template.typ` 참조.

### 1. Page Setup + Typography

```typst
#set document(title: "제목", author: "저자")
#set page(
  paper: "a4",
  margin: (x: 2.2cm, y: 2.5cm),
  header: context { ... },  // 2페이지부터 표시
  footer: context { ... },  // 페이지 번호
)
#set text(font: ("Pretendard", "Noto Sans KR"), size: 10pt, lang: "ko")
#set heading(numbering: "1.")
#set par(justify: true, leading: 0.75em)
```

### 2. Heading 스타일링

```typst
// h1: 하단 보더 + 큰 글씨
#show heading.where(level: 1): it => {
  v(0.8em)
  block(width: 100%, inset: (bottom: 6pt),
    stroke: (bottom: 2pt + accent)
  )[#text(size: 14pt, weight: "bold", fill: rgb("#2C3E50"))[#it.body]]
  v(0.3em)
}
// h2: 색상 강조
#show heading.where(level: 2): it => {
  v(0.5em)
  text(size: 11.5pt, weight: "bold", fill: accent)[#it.body]
  v(0.2em)
}
```

### 3. 유틸리티 함수

```typst
// 색상 팔레트
#let accent = rgb("#4A6FA5")
#let success = rgb("#27AE60")
#let warning = rgb("#E67E22")
#let danger = rgb("#E74C3C")

// Callout 박스 (왼쪽 보더 강조)
#let callout(body, title: none, color: accent) = {
  block(width: 100%, inset: 12pt, radius: 4pt,
    fill: color.lighten(90%), stroke: (left: 3pt + color)
  )[
    #if title != none [#text(weight: "bold", fill: color)[#title] \ ]
    #body
  ]
}

// Badge (인라인 라벨)
#let badge(label, color: accent) = {
  box(inset: (x: 6pt, y: 2pt), radius: 3pt, fill: color.lighten(80%)
  )[#text(size: 8pt, weight: "bold", fill: color)[#label]]
}
```

### 4. 테이블 스타일링

```typst
#figure(
  table(
    columns: (auto, 1fr, auto),
    // 헤더행 색상 + 홀수행 줄무늬
    fill: (_, y) => if y == 0 { accent.lighten(80%) }
                     else if calc.odd(y) { luma(245) },
    stroke: 0.5pt + luma(200),
    inset: 7pt,
    // 특정 행 강조 (1위 등)
    // fill에 조건 추가: else if y == 1 { success.lighten(90%) }
    [*컬럼A*], [*컬럼B*], [*컬럼C*],
    [...], [...], [...],
  ),
  caption: [테이블 캡션],
)
```

### 5. 커버 페이지

```typst
#v(3cm)
#align(center)[
  #text(size: 28pt, weight: "bold", fill: rgb("#2C3E50"))[보고서 제목]
  #v(0.5em)
  #text(size: 16pt, fill: rgb("#7F8C8D"))[부제목]
  #v(2em)
  #line(length: 40%, stroke: 1pt + accent)
  #v(1.5em)
  #text(size: 12pt)[저자명]
  #v(0.3em)
  #text(size: 10pt, fill: luma(100))[날짜]
  #v(2em)
  #block(width: 80%, inset: 16pt, radius: 6pt, fill: accent.lighten(92%))[
    #set text(size: 9pt, fill: luma(60))
    *환경* ... \
    *도구* ...
  ]
]
#pagebreak()
```

### 6. 목차

```typst
#outline(indent: auto, depth: 2)
#pagebreak()
```

## 워크플로우 (autoresearch 검증 루프 포함)

```
STEP 1: 콘텐츠 준비
  - 기반 문서(MD/데이터) 읽기
  - 핵심 수치·표·주장 목록화 → checklist 생성

STEP 2: .typ 파일 생성 (template.typ 기반)

STEP 3: 컴파일 + 검증 루프 (autoresearch 패턴)
  baseline = quality_score(pdf)    # 초기 측정

  FOR round IN 1..3:               # 최대 3회 반복
    IF quality_score >= 0.8: PASS → STEP 4 진행

    # 검증 항목 4가지
    issues = []

    # (1) 고아 제목 + 페이지 잘림 확인 (PyMuPDF 필수)
    typst compile → PyMuPDF로 페이지별 텍스트 추출
    
    FOR each page:
      lines = page.get_text().strip().split('\n')
      last_3_lines = lines[-3:]
      # 고아 제목 탐지: 페이지 마지막에 제목만 있고 내용 없음
      IF last_line이 제목 패턴(숫자. 한글, 영문 대문자 시작)이고
         다음 페이지 첫 줄이 테이블/본문 → ORPHAN issue 추가
      # 고아 제목이 있으면 해당 섹션을 #block(breakable: false)로 감싸거나
      # 제목 직전에 #pagebreak() 삽입
    
    해결 원칙:
    - 모든 "== 제목" 다음에 테이블이 오면 → #block(breakable: false)[== 제목 + 테이블] 묶음
    - 제목만 페이지 끝에 오는 것은 절대 불가
    - block으로 감쌌는데도 넘치면 → 제목 전에 #pagebreak() 삽입

    # (2) 기반 문서 대비 정확성
    checklist의 모든 수치가 PDF에 포함됐는지 대조
    누락/불일치 → issue 추가

    # (3) 레이아웃 품질
    빈 페이지 없는지, 커버→목차→본문 순서 정상인지
    callout/badge 렌더링 정상인지

    # (4) 컴파일 경고/에러
    warning만 → 무시 가능 (폰트 fallback)
    error → 즉시 수정

    # 수정 + 재측정
    fix_issues(typ, issues)
    new_score = quality_score(pdf)

    IF new_score > prev_score: keep
    ELSE: discard (롤백)

STEP 4: 최종 PDF 출력
```

### quality_score 채점 기준

```
quality_score = (
  accuracy    × 0.35 +   # 기반 문서 수치 일치율 (0.0-1.0)
  layout      × 0.25 +   # 페이지 잘림 0건=1.0, 1건=0.7, 2+건=0.3
  completeness× 0.25 +   # checklist 항목 포함률
  compilation × 0.15     # error=0, warning-only=0.8, clean=1.0
)
통과 기준: quality_score >= 0.8
```

## 용도별 팔레트

| 용도 | accent | 추천 조합 |
|------|--------|----------|
| 기술 보고서 | `#4A6FA5` (Blue) | + success `#27AE60` |
| 비즈니스 | `#2C3E50` (Dark) | + `#E67E22` warning |
| 학술 | `#8E44AD` (Purple) | + `#2980B9` |
| 강의안 | `#16A085` (Teal) | + `#E74C3C` danger |

## Common Mistakes

| 실수 | 해결 |
|------|------|
| `font: "Noto Sans CJK KR"` | CJK 통합폰트 미설치 → `"Noto Sans KR"` 사용 |
| 테이블 컬럼 수 불일치 | columns 수와 셀 수가 정확히 맞아야 함 |
| `#` 이스케이프 누락 | 순위 등에서 `\#` 또는 `[*\#*]` 사용 |
| 이모지 깨짐 | 시스템 이모지 폰트에 따라 다름, 텍스트로 대체 권장 |
| PDF 권한 거부 | WSL → Windows 경로 쓰기 시 발생 → `/tmp/`에 생성 후 `cp` |


## Auto-Learned Patterns

- [2026-04-05] quality_score 0.8 미만 시 typst 컴파일 재시도 전에 font 이름과 테이블 컬럼 수를 먼저 확인하는 것이 가장 빠른 디버깅 경로다 (source: 2026-04-05-0206.md)
- [2026-04-05] typst-report 스킬에서 PDF 권한 거부 오류는 WSL→Windows 경로 쓰기 문제 — /tmp/에 먼저 생성 후 cp 패턴으로 해결 (source: 2026-04-05-0130.md)
