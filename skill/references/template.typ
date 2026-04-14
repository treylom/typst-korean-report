// ============================================================
// Typst Report Template — Best Practice
// 사용법: 이 파일을 복사하여 내용 부분만 수정
// ============================================================

// === 1. Document & Page Setup ===
#set document(title: "보고서 제목", author: "김재경 (tofukyung)")
#set page(
  paper: "a4",
  margin: (x: 2.2cm, y: 2.5cm),
  header: context {
    if counter(page).get().first() > 1 [
      #set text(size: 8pt, fill: luma(120))
      보고서 제목
      #h(1fr)
      부제목
      #v(-3pt)
      #line(length: 100%, stroke: 0.3pt + luma(200))
    ]
  },
  footer: context [
    #set text(size: 8pt, fill: luma(120))
    #line(length: 100%, stroke: 0.3pt + luma(200))
    #v(2pt)
    김재경 (tofukyung) · 2026-04-05
    #h(1fr)
    #counter(page).display("1 / 1", both: true)
  ],
)

// === 2. Typography ===
#set text(font: ("Pretendard", "Noto Sans KR", "Malgun Gothic"), size: 10pt, lang: "ko")
#set heading(numbering: "1.")
#set par(justify: true, leading: 0.75em)

// === 3. Heading Styles ===
#show heading.where(level: 1): it => {
  v(0.8em)
  block(
    width: 100%,
    inset: (bottom: 6pt),
    stroke: (bottom: 2pt + rgb("#4A6FA5")),
  )[
    #text(size: 14pt, weight: "bold", fill: rgb("#2C3E50"))[#it.body]
  ]
  v(0.3em)
}
#show heading.where(level: 2): it => {
  v(0.5em)
  text(size: 11.5pt, weight: "bold", fill: rgb("#4A6FA5"))[#it.body]
  v(0.2em)
}

// === 4. Color Palette ===
#let accent = rgb("#4A6FA5")
#let accent-light = rgb("#E8EFF8")
#let success = rgb("#27AE60")
#let warning = rgb("#E67E22")
#let danger = rgb("#E74C3C")

// === 5. Utility Functions ===

/// Callout box with left border accent
#let callout(body, title: none, color: accent) = {
  block(
    width: 100%,
    inset: 12pt,
    radius: 4pt,
    fill: color.lighten(90%),
    stroke: (left: 3pt + color),
  )[
    #if title != none [
      #text(weight: "bold", fill: color)[#title] \
    ]
    #body
  ]
}

/// Inline badge label
#let badge(label, color: accent) = {
  box(
    inset: (x: 6pt, y: 2pt),
    radius: 3pt,
    fill: color.lighten(80%),
  )[#text(size: 8pt, weight: "bold", fill: color)[#label]]
}

/// Key-value info block (for metadata sections)
#let info-block(..items) = {
  block(
    width: 100%,
    inset: 14pt,
    radius: 6pt,
    fill: accent-light,
  )[
    #set text(size: 9pt, fill: luma(60))
    #for item in items.pos() [
      #item \
    ]
  ]
}

// ============================================================
// COVER PAGE
// ============================================================
#v(3cm)
#align(center)[
  #text(size: 28pt, weight: "bold", fill: rgb("#2C3E50"))[보고서 제목]
  #v(0.5em)
  #text(size: 16pt, fill: rgb("#7F8C8D"))[부제목 또는 설명]
  #v(2em)
  #line(length: 40%, stroke: 1pt + accent)
  #v(1.5em)
  #text(size: 12pt)[김재경 (tofukyung)]
  #v(0.3em)
  #text(size: 10pt, fill: luma(100))[2026-04-05]
  #v(2em)
  #info-block(
    [*환경* 환경 정보],
    [*도구* 도구 정보],
    [*방법론* 방법론 정보],
  )
]
#pagebreak()

// ============================================================
// TABLE OF CONTENTS
// ============================================================
#outline(indent: auto, depth: 2)
#pagebreak()

// ============================================================
// CONTENT START
// ============================================================

= Executive Summary

요약 내용.

#callout(title: "Key Findings", color: accent)[
  - 핵심 발견 1 #badge("수치", color: success)
  - 핵심 발견 2
  - 핵심 발견 3
]

= 본문 섹션

== 데이터

본문 내용.

== 결과

#figure(
  table(
    columns: (auto, 1fr, auto),
    fill: (_, y) => if y == 0 { accent.lighten(80%) }
                     else if calc.odd(y) { luma(245) },
    stroke: 0.5pt + luma(200),
    inset: 7pt,
    [*항목*], [*설명*], [*수치*],
    [항목 1], [설명 1], [100],
    [항목 2], [설명 2], [200],
  ),
  caption: [테이블 제목],
)

= 결론

#callout(title: "요약", color: success)[
  결론 내용.
]
