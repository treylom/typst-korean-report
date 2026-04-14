# typst-korean-report

Typst 한국어 보고서 템플릿 + Claude Code 스킬.

## 규칙
- PDF 생성 시 `skill/SKILL.md`의 워크플로우를 따를 것
- 고아 제목(orphan heading)은 절대 허용하지 않음 — `#block(breakable: false)` 또는 `#pagebreak()` 사용
- 한국어 폰트 우선순위: Pretendard → Noto Sans KR → NanumGothic
- quality_score 0.8 미만이면 재컴파일
