# rust-dojo 🥋

Rust 문서 도장깨기

## 진행 상황

각 책별 진행상황은 Issues에서 확인하세요:

- [The Rust Programming Language](../../issues/1)
- [Rust by Example](../../issues/2)
- [Rustonomicon](../../issues/3)

## 사용법

### 새 챕터 시작

```bash
./scripts/new-chapter.sh the-book 01-getting-started
```

챕터 폴더와 템플릿이 자동 생성됩니다.

### PR 올리기

```bash
git add .
git commit -m "Complete: The Book Ch.1 Getting Started"
git push
```

PR 머지되면 자동으로 진행상황이 업데이트됩니다.

## 구조

```
rust-dojo/
├── the-book/           # The Rust Programming Language
├── rust-by-example/    # Rust by Example
├── rustonomicon/       # The Rustonomicon
└── scripts/            # 자동화 스크립트
```
