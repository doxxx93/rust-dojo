#!/bin/bash

# Usage: ./scripts/generate-issue.sh <book>
# Example: ./scripts/generate-issue.sh the-book

set -e

if [ $# -ne 1 ]; then
    echo "Usage: $0 <book>"
    echo "Example: $0 the-book"
    exit 1
fi

BOOK=$1
TOC_FILE=".dojo/$BOOK.json"

if [ ! -f "$TOC_FILE" ]; then
    echo "Error: TOC file not found: $TOC_FILE"
    exit 1
fi

# jq 체크
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed."
    echo "Install: brew install jq"
    exit 1
fi

# 책 제목 가져오기
BOOK_TITLE=$(jq -r ".title" "$TOC_FILE")

# Issue 본문 생성
echo "# $BOOK_TITLE"
echo ""
echo "## Progress"
echo ""

# 챕터 순회
CHAPTERS=$(jq -r '.chapters | keys[]' "$TOC_FILE" | sort -n)

for chapter in $CHAPTERS; do
    TITLE=$(jq -r ".chapters.\"$chapter\".title" "$TOC_FILE")
    SUBS=$(jq -r ".chapters.\"$chapter\".subs[]" "$TOC_FILE" 2>/dev/null)

    echo "- [ ] $chapter. $TITLE"

    # 서브챕터가 있으면 표시
    if [ -n "$SUBS" ]; then
        sub_num=1
        while IFS= read -r sub_title; do
            if [ -n "$sub_title" ]; then
                echo "  - [ ] $chapter.$sub_num $sub_title"
                ((sub_num++))
            fi
        done <<< "$SUBS"
    fi
done

echo ""
echo "---"
echo ""
echo "챕터 완료 시 자동으로 체크박스가 업데이트됩니다."
