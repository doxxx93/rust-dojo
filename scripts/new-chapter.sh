#!/bin/bash

# Usage: ./scripts/new-chapter.sh <book> <chapter>
# Example: ./scripts/new-chapter.sh the-book 1
#          ./scripts/new-chapter.sh the-book 3.1

set -e

if [ $# -ne 2 ]; then
    echo "Usage: $0 <book> <chapter>"
    echo "Example: $0 the-book 1"
    echo "         $0 the-book 3.1"
    exit 1
fi

BOOK=$1
CHAPTER_INPUT=$2
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

# 챕터 번호 파싱
if [[ $CHAPTER_INPUT == *.* ]]; then
    # 서브챕터 (예: 3.1)
    MAIN_CHAPTER=$(echo $CHAPTER_INPUT | cut -d'.' -f1)
    SUB_CHAPTER=$(echo $CHAPTER_INPUT | cut -d'.' -f2)

    # TOC에서 정보 가져오기
    MAIN_TITLE=$(jq -r ".chapters.\"$MAIN_CHAPTER\".title" "$TOC_FILE")
    SUB_TITLES=$(jq -r ".chapters.\"$MAIN_CHAPTER\".subs[]" "$TOC_FILE")

    if [ "$MAIN_TITLE" == "null" ]; then
        echo "Error: Chapter $MAIN_CHAPTER not found in TOC"
        exit 1
    fi

    # 서브챕터 타이틀 추출 (배열 인덱스는 0부터 시작)
    SUB_INDEX=$((SUB_CHAPTER - 1))
    SUB_TITLE=$(echo "$SUB_TITLES" | sed -n "$((SUB_INDEX + 1))p")

    if [ -z "$SUB_TITLE" ]; then
        echo "Error: Subchapter $CHAPTER_INPUT not found in TOC"
        exit 1
    fi

    # 폴더명 생성
    MAIN_SLUG=$(printf "%02d" $MAIN_CHAPTER)-$(echo "$MAIN_TITLE" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//')
    SUB_SLUG=$(printf "%02d" $SUB_CHAPTER)-$(echo "$SUB_TITLE" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//')

    CHAPTER_DIR="$BOOK/$MAIN_SLUG/$SUB_SLUG"
    DISPLAY_TITLE="$MAIN_CHAPTER.$SUB_CHAPTER $SUB_TITLE"

else
    # 메인 챕터만 (예: 1)
    MAIN_CHAPTER=$CHAPTER_INPUT

    # TOC에서 정보 가져오기
    MAIN_TITLE=$(jq -r ".chapters.\"$MAIN_CHAPTER\".title" "$TOC_FILE")
    SUBS=$(jq -r ".chapters.\"$MAIN_CHAPTER\".subs | length" "$TOC_FILE")

    if [ "$MAIN_TITLE" == "null" ]; then
        echo "Error: Chapter $MAIN_CHAPTER not found in TOC"
        exit 1
    fi

    # 폴더명 생성
    MAIN_SLUG=$(printf "%02d" $MAIN_CHAPTER)-$(echo "$MAIN_TITLE" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//')

    if [ "$SUBS" != "0" ] && [ "$SUBS" != "null" ]; then
        # 서브챕터가 있는 경우 - 메인 폴더만 생성
        CHAPTER_DIR="$BOOK/$MAIN_SLUG"
        DISPLAY_TITLE="$MAIN_CHAPTER. $MAIN_TITLE"
        echo "ℹ️  This chapter has $SUBS subchapters. Creating main chapter directory."
    else
        # 서브챕터 없는 경우
        CHAPTER_DIR="$BOOK/$MAIN_SLUG"
        DISPLAY_TITLE="$MAIN_CHAPTER. $MAIN_TITLE"
    fi
fi

# 디렉토리 존재 체크
if [ -d "$CHAPTER_DIR" ]; then
    echo "Error: $CHAPTER_DIR already exists"
    exit 1
fi

mkdir -p "$CHAPTER_DIR"

# 템플릿 생성
DATE=$(date +%Y-%m-%d)

cat > "$CHAPTER_DIR/README.md" <<EOF
# $DISPLAY_TITLE

> 시작: $DATE

## 요약



## 주요 개념



## 메모



## 코드 예제

\`\`\`rust
// 여기에 코드 작성
\`\`\`

## 참고 링크

- [공식 문서](https://doc.rust-lang.org/book/)
EOF

echo "✅ Created: $CHAPTER_DIR/README.md"
echo ""
echo "Next steps:"
echo "  cd $CHAPTER_DIR"
echo "  vim README.md"
