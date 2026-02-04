# rust-dojo 🥋

Rust 문서 도장깨기

## 진행 상황

각 책별 진행상황은 Issues에서 확인하세요:

- [The Rust Programming Language](../../issues/1)
- [Rust by Example](../../issues/2)
- [Rustonomicon](../../issues/3)

## 빠른 시작

### 1. 새 챕터 시작

```bash
# 메인 챕터
./scripts/new-chapter.sh the-book 1

# 서브챕터
./scripts/new-chapter.sh the-book 3.1
```

### 2. 학습 내용 작성

생성된 `README.md`를 편집하여 학습 내용을 정리합니다.

### 3. 커밋 및 푸시

```bash
git add .
git commit -m "Complete: The Book Ch.1 Getting Started"
git push
```

푸시하면 자동으로 진행상황이 업데이트됩니다.

## 상세 가이드

프로젝트 구조, 새 책 추가 방법, 트러블슈팅 등은 [CLAUDE.md](CLAUDE.md)를 참고하세요.

## 참고 자료

- [The Rust Book](https://doc.rust-lang.org/book/)
- [Rust by Example](https://doc.rust-lang.org/rust-by-example/)
- [Rustonomicon](https://doc.rust-lang.org/nomicon/)
