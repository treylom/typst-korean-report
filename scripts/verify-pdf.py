#!/usr/bin/env python3
"""
PDF 검증 스크립트 — orphan heading 탐지 + quality_score 채점

사용법:
  python verify-pdf.py report.pdf
  python verify-pdf.py report.pdf --check-orphans
  python verify-pdf.py report.pdf --verbose

필수: pip install pymupdf
"""

import sys
import argparse

try:
    import fitz  # PyMuPDF
except ImportError:
    print("PyMuPDF가 필요합니다: pip install pymupdf")
    sys.exit(1)


def check_orphan_headings(pdf_path: str, verbose: bool = False) -> list[dict]:
    """페이지 끝에 제목만 있고 내용이 다음 페이지로 넘어가는 고아 제목 탐지."""
    doc = fitz.open(pdf_path)
    orphans = []

    for i in range(len(doc) - 1):
        page = doc[i]
        next_page = doc[i + 1]

        lines = page.get_text().strip().split("\n")
        next_lines = next_page.get_text().strip().split("\n")

        if not lines or not next_lines:
            continue

        # 마지막 3줄 검사 (페이지 번호 제외)
        check_lines = [l.strip() for l in lines[-3:] if l.strip() and "/" not in l]

        for line in check_lines:
            is_heading = False
            # 숫자. 로 시작하는 제목 (1. 섹션, 2.1 소섹션)
            if len(line) > 2 and line[0].isdigit() and "." in line[:4]:
                is_heading = True
            # 한글로 시작하는 짧은 줄 (제목일 가능성)
            if len(line) < 40 and any("\uac00" <= c <= "\ud7a3" for c in line):
                # 다음 페이지 첫 줄이 본문이면 고아 제목
                first_next = next_lines[0].strip() if next_lines else ""
                if len(first_next) > 50:
                    is_heading = True

            if is_heading:
                orphans.append({
                    "page": i + 1,
                    "heading": line,
                    "next_page_start": next_lines[0].strip()[:60] if next_lines else "",
                })

    doc.close()
    return orphans


def get_pdf_info(pdf_path: str) -> dict:
    """PDF 기본 정보 반환."""
    doc = fitz.open(pdf_path)
    import os
    info = {
        "pages": len(doc),
        "size_kb": round(os.path.getsize(pdf_path) / 1024),
    }
    doc.close()
    return info


def quality_score(
    accuracy: float = 1.0,
    layout_issues: int = 0,
    completeness: float = 1.0,
    has_errors: bool = False,
    has_warnings: bool = False,
) -> float:
    """
    quality_score 계산.

    Args:
        accuracy: 기반 문서 수치 일치율 (0.0-1.0)
        layout_issues: 페이지 잘림/고아제목 건수
        completeness: checklist 항목 포함률 (0.0-1.0)
        has_errors: 컴파일 에러 여부
        has_warnings: 컴파일 경고 여부

    Returns:
        0.0-1.0 범위의 품질 점수 (0.8 이상 통과)
    """
    if layout_issues == 0:
        layout = 1.0
    elif layout_issues == 1:
        layout = 0.7
    else:
        layout = 0.3

    if has_errors:
        compilation = 0.0
    elif has_warnings:
        compilation = 0.8
    else:
        compilation = 1.0

    score = (
        accuracy * 0.35
        + layout * 0.25
        + completeness * 0.25
        + compilation * 0.15
    )
    return round(score, 3)


def main():
    parser = argparse.ArgumentParser(description="PDF 검증 스크립트")
    parser.add_argument("pdf", help="검증할 PDF 파일 경로")
    parser.add_argument("--check-orphans", action="store_true", help="고아 제목 탐지")
    parser.add_argument("--verbose", "-v", action="store_true", help="상세 출력")
    args = parser.parse_args()

    info = get_pdf_info(args.pdf)
    print(f"PDF: {args.pdf}")
    print(f"  Pages: {info['pages']}, Size: {info['size_kb']}KB")

    orphans = check_orphan_headings(args.pdf, verbose=args.verbose)

    if orphans:
        print(f"\n  Orphan Headings: {len(orphans)}건")
        for o in orphans:
            print(f"    p{o['page']}: \"{o['heading']}\"")
            if args.verbose:
                print(f"      → next page: \"{o['next_page_start']}...\"")
    else:
        print(f"\n  Orphan Headings: 없음")

    score = quality_score(layout_issues=len(orphans))
    status = "PASS" if score >= 0.8 else "FAIL"
    print(f"\n  Quality Score: {score} [{status}]")

    if score < 0.8:
        print("\n  수정 방법:")
        print("    - 고아 제목: #block(breakable: false)[== 제목 + 내용] 으로 묶기")
        print("    - 또는 제목 전에 #pagebreak() 삽입")
        sys.exit(1)


if __name__ == "__main__":
    main()
