#!/bin/bash

# Usage: ./scripts/new-chapter.sh <book> <chapter-name>
# Example: ./scripts/new-chapter.sh the-book 01-getting-started

if [ $# -ne 2 ]; then
    echo "Usage: $0 <book> <chapter-name>"
    echo "Example: $0 the-book 01-getting-started"
    exit 1
fi

BOOK=$1
CHAPTER=$2
CHAPTER_DIR="$BOOK/$CHAPTER"

if [ -d "$CHAPTER_DIR" ]; then
    echo "Error: $CHAPTER_DIR already exists"
    exit 1
fi

mkdir -p "$CHAPTER_DIR"

# 템플릿 복사
DATE=$(date +%Y-%m-%d)
CHAPTER_TITLE=$(echo $CHAPTER | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++)sub(/./,toupper(substr($i,1,1)),$i)}1')

cat > "$CHAPTER_DIR/README.md" <<EOF
# $CHAPTER_TITLE

> 시작: $DATE

## 요약



## 주요 개념



## 메모



## 코드 예제

\`\`\`rust
// 여기에 코드 작성
\`\`\`

## 참고 링크

-
EOF

echo "✅ Created: $CHAPTER_DIR/README.md"
echo ""
echo "Next steps:"
echo "  cd $CHAPTER_DIR"
echo "  vim README.md"
