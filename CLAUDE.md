# rust-dojo Developer Guide

이 문서는 rust-dojo 프로젝트의 구조와 사용법을 설명합니다. Claude나 다른 개발자가 프로젝트를 이해하고 확장할 수 있도록 작성되었습니다.

## 프로젝트 구조

```
rust-dojo/
├── README.md                           # 프로젝트 소개 (사용자용)
├── CLAUDE.md                           # 상세 가이드 (개발자용)
├── .dojo/                              # 메타데이터
│   ├── the-book.json                   # The Rust Book TOC
│   ├── rust-by-example.json            # (예정)
│   └── rustonomicon.json               # (예정)
├── scripts/
│   ├── new-chapter.sh                  # 새 챕터 생성
│   └── generate-issue.sh               # Issue 본문 생성
├── .github/workflows/
│   └── update-progress.yml             # 자동 체크박스 업데이트
└── the-book/                           # 책별 디렉토리
    ├── 01-getting-started/
    │   └── README.md
    └── 03-common-programming-concepts/
        ├── README.md                   # 챕터 전체 요약
        ├── 01-variables-and-mutability/
        │   └── README.md
        └── 02-data-types/
            └── README.md
```

## 기본 워크플로우

### 1. 새 챕터 시작

```bash
# 메인 챕터 (서브챕터 없는 경우)
./scripts/new-chapter.sh the-book 1
# → the-book/01-getting-started/README.md 생성

# 메인 챕터 (서브챕터 있는 경우)
./scripts/new-chapter.sh the-book 3
# → the-book/03-common-programming-concepts/README.md 생성

# 서브챕터
./scripts/new-chapter.sh the-book 3.1
# → the-book/03-common-programming-concepts/01-variables-and-mutability/README.md 생성
```

### 2. 학습 내용 작성

생성된 `README.md`를 편집하여 학습 내용을 정리합니다.

```markdown
# 1. Getting Started

> 시작: 2024-02-04

## 요약

Rust 설치 및 첫 프로그램 작성

## 주요 개념

- rustup: Rust 버전 관리 도구
- cargo: Rust 빌드 시스템 및 패키지 매니저

## 메모

...

## 코드 예제

\`\`\`rust
fn main() {
    println!("Hello, world!");
}
\`\`\`
```

### 3. 커밋 및 푸시

```bash
git add the-book/01-getting-started/
git commit -m "Complete: The Book Ch.1 Getting Started"
git push
```

### 4. 자동 진행상황 업데이트

푸시하면 GitHub Actions가 자동으로:
1. 변경된 챕터 디렉토리 감지
2. 해당 Issue 찾기
3. 체크박스 자동 체크 ✅
4. 코멘트 추가

## TOC JSON 구조

`.dojo/<book-name>.json` 파일은 책의 목차를 정의합니다.

### 기본 구조

```json
{
  "title": "The Rust Programming Language",
  "chapters": {
    "1": {
      "title": "Getting Started",
      "subs": []
    },
    "3": {
      "title": "Common Programming Concepts",
      "subs": [
        "Variables and Mutability",
        "Data Types",
        "Functions",
        "Comments",
        "Control Flow"
      ]
    }
  }
}
```

### 필드 설명

- **title**: 책 제목 (Issue 제목에 사용)
- **chapters**: 챕터 번호를 키로 하는 객체
  - **title**: 챕터 제목
  - **subs**: 서브챕터 배열 (없으면 빈 배열)

### 폴더명 생성 규칙

스크립트는 다음과 같이 폴더명을 생성합니다:

1. 챕터 번호를 2자리로 패딩: `1` → `01`
2. 제목을 소문자로 변환
3. 특수문자를 `-`로 치환
4. 연속된 `-`를 하나로 합침

**예시:**
- `"Getting Started"` → `01-getting-started`
- `"Variables and Mutability"` → `01-variables-and-mutability`
- `"Using Box<T> to Point to Data on the Heap"` → `01-using-box-t-to-point-to-data-on-the-heap`

## 새 책 추가하기

새로운 책을 추가하려면 다음 단계를 따릅니다.

### 1. TOC JSON 파일 생성

`.dojo/<book-name>.json` 파일을 생성합니다.

```bash
# 예: Rust by Example
cat > .dojo/rust-by-example.json <<'EOF'
{
  "title": "Rust by Example",
  "chapters": {
    "1": {
      "title": "Hello World",
      "subs": [
        "Comments",
        "Formatted print"
      ]
    },
    "2": {
      "title": "Primitives",
      "subs": []
    }
  }
}
EOF
```

### 2. Issue 생성

```bash
# Issue 본문 생성
./scripts/generate-issue.sh rust-by-example > /tmp/issue-body.txt

# Issue 생성
gh issue create --title "[Rust by Example] Progress Tracker" --body-file /tmp/issue-body.txt

# 생성된 Issue 번호 확인 (예: #4)
```

### 3. Actions 워크플로우 업데이트

`.github/workflows/update-progress.yml`에 새 책 매핑 추가:

```yaml
case "$BOOK" in
  "the-book")
    ISSUE_NUM=1
    ;;
  "rust-by-example")
    ISSUE_NUM=4  # 생성된 Issue 번호
    ;;
  ...
esac
```

### 4. README.md 업데이트

`README.md`에 새 책 링크 추가:

```markdown
## 진행 상황

- [The Rust Programming Language](../../issues/1)
- [Rust by Example](../../issues/4)
```

### 5. 테스트

```bash
./scripts/new-chapter.sh rust-by-example 1
# → rust-by-example/01-hello-world/README.md 생성 확인

git add .
git commit -m "Add: Rust by Example setup"
git push
# → Actions 실행 확인
```

## GitHub Actions 동작 원리

### 트리거

- `push` 이벤트 (main 또는 master 브랜치)

### 동작 순서

1. **변경된 파일 감지**
   ```bash
   git diff --name-only HEAD^..HEAD
   ```

2. **챕터 디렉토리 추출**
   - `the-book/01-getting-started/README.md` → `the-book/01-getting-started`
   - `the-book/03-common-programming-concepts/01-variables/README.md` → `the-book/03-common-programming-concepts/01-variables`

3. **Issue 번호 매핑**
   - 책 이름으로 Issue 번호 결정

4. **챕터 번호 파싱**
   - 메인 챕터: `01-getting-started` → `1.`
   - 서브 챕터: `03-common-concepts/01-variables` → `3.1`

5. **체크박스 업데이트**
   - Issue 본문에서 해당 패턴 찾아 `- [ ]` → `- [x]` 변경
   - `gh issue edit` 명령으로 업데이트

6. **코멘트 추가**
   - 완료된 챕터, 커밋 정보 추가

## 스크립트 상세 설명

### new-chapter.sh

**용도:** 새 챕터 디렉토리 및 템플릿 생성

**의존성:**
- `jq` (JSON 파싱) - 없으면 `brew install jq`

**동작:**
1. TOC JSON 파일 읽기
2. 챕터 번호로 제목 찾기
3. 폴더명 생성 (slug)
4. 디렉토리 및 README.md 템플릿 생성

**에러 처리:**
- TOC 파일 없음
- 챕터 번호 없음
- 디렉토리 이미 존재

### generate-issue.sh

**용도:** TOC JSON 기반 Issue 본문 생성

**출력 형식:**
```markdown
# The Rust Programming Language

## Progress

- [ ] 1. Getting Started
- [ ] 3. Common Programming Concepts
  - [ ] 3.1 Variables and Mutability
  - [ ] 3.2 Data Types
...
```

**사용 예:**
```bash
# 생성
./scripts/generate-issue.sh the-book > /tmp/issue.txt

# Issue 생성
gh issue create --title "[The Book] Progress" --body-file /tmp/issue.txt

# 기존 Issue 업데이트
./scripts/generate-issue.sh the-book | gh issue edit 1 --body-file -
```

## 트러블슈팅

### Actions가 체크박스를 업데이트하지 않음

**증상:** 푸시했는데 Issue가 업데이트 안 됨

**확인 사항:**
1. Actions 실행 여부 확인
   ```bash
   gh run list
   ```

2. Actions 로그 확인
   ```bash
   gh run view --log
   ```

3. 폴더 구조 확인
   - README.md가 올바른 위치에 있는지
   - 폴더명이 TOC JSON과 일치하는지

4. Issue 패턴 확인
   - Issue의 체크박스 형식이 올바른지
   - 들여쓰기(서브챕터는 2칸)가 맞는지

### 챕터 번호 매칭 안됨

**증상:** Actions는 실행되지만 체크박스가 체크 안됨

**원인:** 폴더명과 Issue의 챕터 번호 불일치

**해결:**
```bash
# Issue 재생성
./scripts/generate-issue.sh the-book | gh issue edit 1 --body-file -
```

### jq 명령어 없음

**증상:** `jq: command not found`

**해결:**
```bash
brew install jq
```

### 폴더명 중복

**증상:** `Error: directory already exists`

**해결:**
```bash
# 폴더 삭제 후 재생성
rm -rf the-book/01-getting-started
./scripts/new-chapter.sh the-book 1

# 또는 직접 편집
cd the-book/01-getting-started
vim README.md
```

## 향후 확장 아이디어

### mdBook 통합

나중에 mdBook으로 변환하려면:

1. **SUMMARY.md 생성 스크립트**
   ```bash
   ./scripts/export-mdbook.sh
   ```

2. **book.toml 설정**
   ```toml
   [book]
   title = "rust-dojo"
   src = "."
   ```

3. **GitHub Pages 배포**
   ```yaml
   # .github/workflows/deploy-book.yml
   - run: mdbook build
   - uses: peaceiris/actions-gh-pages@v3
   ```

### 진행률 뱃지

README.md에 진행률 뱃지 추가:

```markdown
![Progress](https://img.shields.io/badge/progress-15%2F21-blue)
```

Actions에서 자동 업데이트 가능.

### 학습 통계

- 총 학습 시간
- 주간 학습량
- 챕터별 소요 시간

커밋 타임스탬프로 분석 가능.

## 참고 자료

- [The Rust Book](https://doc.rust-lang.org/book/)
- [Rust by Example](https://doc.rust-lang.org/rust-by-example/)
- [Rustonomicon](https://doc.rust-lang.org/nomicon/)
- [GitHub Actions 문서](https://docs.github.com/en/actions)
- [mdBook](https://rust-lang.github.io/mdBook/)
