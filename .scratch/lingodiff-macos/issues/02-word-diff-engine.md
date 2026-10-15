# Issue 02: Word-by-Word Diff Algorithm in Pure Dart

Type: prototype
Status: resolved
Blocked by: 01

## Question

How should the word-by-word diff algorithm (mimicking `jsdiff` `diffWordsWithSpace`) be implemented in pure Dart with fast performance and proper token preservation for whitespace, punctuation, additions, and deletions?

## Answer

Implemented in pure Dart via `WordDiff.diffWordsWithSpace` in `lib/core/diff/word_diff.dart`. Employs a regex-based tokenizer preserving words, punctuation, and whitespace sequences, computes the optimal sequence using the Longest Common Subsequence (LCS) dynamic programming algorithm, backtracks changes, and coalesces adjacent chunks of matching `DiffType` (`added`, `removed`, `unchanged`). Verified with 100% passing tests for edge cases and text reconstruction.
