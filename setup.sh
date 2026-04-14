#!/bin/bash
# typst-korean-report 초기 설치 스크립트
# 사용법: bash setup.sh

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

ok()   { echo -e "${GREEN}[OK]${NC} $*"; }
warn() { echo -e "${YELLOW}[!]${NC} $*"; }
fail() { echo -e "${RED}[X]${NC} $*"; }

echo ""
echo "=== typst-korean-report 설치 ==="
echo ""

# 1. Typst 설치 확인
if command -v typst &>/dev/null; then
  ok "Typst $(typst --version 2>&1 | head -1)"
else
  warn "Typst 미설치 — 설치 중..."
  case "$(uname -s)" in
    Darwin)
      if command -v brew &>/dev/null; then
        brew install typst
        ok "Typst 설치 완료 (brew)"
      else
        fail "Homebrew 필요: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        exit 1
      fi
      ;;
    Linux)
      if grep -qi microsoft /proc/version 2>/dev/null; then
        echo "WSL 감지"
      fi
      curl -fsSL https://typst.community/typst-install/install.sh | bash
      ok "Typst 설치 완료"
      ;;
    *)
      fail "수동 설치 필요: https://github.com/typst/typst/releases"
      exit 1
      ;;
  esac
fi

# 2. 한국어 폰트 확인
echo ""
FONTS=$(typst fonts 2>/dev/null || echo "")

if echo "$FONTS" | grep -qi "pretendard"; then
  ok "Pretendard 폰트 발견"
elif echo "$FONTS" | grep -qi "noto sans kr"; then
  ok "Noto Sans KR 폰트 발견"
elif echo "$FONTS" | grep -qi "nanumgothic"; then
  ok "NanumGothic 폰트 발견"
else
  warn "한국어 폰트 미발견 — 설치 중..."
  case "$(uname -s)" in
    Darwin)
      brew install --cask font-pretendard 2>/dev/null || brew install --cask font-nanum-gothic 2>/dev/null || warn "폰트 수동 설치 필요"
      ;;
    Linux)
      sudo apt install -y fonts-nanum 2>/dev/null || warn "폰트 수동 설치 필요: sudo apt install fonts-nanum"
      ;;
  esac
fi

# 3. PyMuPDF (선택)
echo ""
if python3 -c "import fitz" 2>/dev/null; then
  ok "PyMuPDF 설치됨"
else
  warn "PyMuPDF 미설치 (검증 스크립트용, 선택사항)"
  read -p "  설치할까요? (y/N) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    pip install pymupdf
    ok "PyMuPDF 설치 완료"
  fi
fi

# 4. 테스트 컴파일
echo ""
echo "--- 테스트 컴파일 ---"
if typst compile examples/daily-briefing.typ /tmp/test-typst-kr.pdf 2>&1; then
  ok "테스트 PDF 생성 성공: /tmp/test-typst-kr.pdf"
else
  warn "테스트 컴파일 실패 — 폰트 설정 확인 필요"
  echo "  typst fonts | grep -i 'pretendard\|nanum\|noto'"
fi

echo ""
echo "=== 설치 완료 ==="
echo ""
echo "  다음 단계:"
echo "    cp skill/references/template.typ my-report.typ"
echo "    typst compile my-report.typ my-report.pdf"
echo ""
