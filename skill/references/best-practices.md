# Typst Korean Report — Best Practices (Feedback 기반)

실전 사용에서 축적된 패턴과 주의사항입니다. 스킬 실행 시 이 파일도 함께 참조됩니다.

## 1. 고아 제목(Orphan Heading) 방지 — 필수

모든 헤딩 + 바로 따르는 테이블/콜아웃을 `#block(breakable: false)`로 묶어야 합니다.

```typst
// 올바른 예: 제목과 테이블을 함께 묶기
#block(breakable: false)[
  == 섹션 제목
  #figure(
    table(...),
    caption: [테이블 제목],
  )
]
```

**규칙:**
- 제목 다음에 테이블/콜아웃이 오면 → 반드시 `#block(breakable: false)[]`로 묶기
- 순수 제목 (테이블 없이 본문만 따르는 경우) → 래핑 불필요
- 매우 긴 테이블 (1페이지 초과) → `breakable: false` 적용 금지 (테이블 내부에서 자연스럽게 분할되어야 함)
- `block`으로 감쌌는데도 넘치면 → 제목 전에 `#pagebreak()` 삽입

**검증:**
- PyMuPDF로 페이지별 마지막/첫 줄 비교해서 고아 제목 자동 탐지
- 컴파일 후 페이지 수가 1~2장 늘어나는 것은 정상 (조판 품질 향상의 대가)

## 2. 디버깅 순서

quality_score 0.8 미만일 때, 가장 빠른 디버깅 경로:

1. **폰트 이름 확인** — `typst fonts | grep -i "pretendard\|nanum\|noto"`
2. **테이블 컬럼 수** — `columns` 수와 실제 셀 수가 정확히 맞는지
3. 위 두 개가 가장 흔한 에러 원인

## 3. WSL 환경 주의사항

WSL에서 Windows 경로(`/mnt/c/...`)에 직접 PDF를 쓰면 권한 에러가 발생합니다.

```bash
# 잘못된 방법
typst compile report.typ /mnt/c/Users/.../report.pdf  # 권한 거부!

# 올바른 방법
typst compile report.typ /tmp/report.pdf  # 먼저 /tmp/에 생성
cp /tmp/report.pdf /mnt/c/Users/.../      # 그 다음 복사
```

## 4. Markdown → Typst 변환 시

변환기(`md_to_typst.py` 등)를 사용할 때는 반드시 후처리 함수로 헤딩+테이블을 자동 묶어야 합니다:

```python
def wrap_sections_breakable_false(typst_content):
    """헤딩 + #figure( 또는 #callout( 패턴을 #block(breakable: false)로 래핑"""
    # 구현은 프로젝트에 따라 다름
    pass
```

## 5. 이모지 사용

- Typst에서 이모지는 시스템 폰트에 의존합니다
- OS에 따라 렌더링이 다를 수 있어 텍스트로 대체하는 것을 권장합니다
- 예: "✅" 대신 `#text(fill: rgb("#27AE60"), weight: "bold")[OK]`
