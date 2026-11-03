#!/usr/bin/env python3
"""Measure the prose rhythm of Markdown/MDX docs.

Usage:
  rhythm.py FILE_OR_DIR... [--per-file] [--list-short]

Strips front matter, code, comments, tables, headings, list items, components
and link targets, then reports sentence statistics for the remaining prose.
The numbers are guard rails, not goals: padding can satisfy them. A human read
still decides whether a page is good.
"""
from __future__ import annotations

import re
import statistics
import sys
from pathlib import Path


def prose_paragraphs(text: str) -> list[str]:
    text = re.sub(r'^---\n.*?\n---\n', '', text, flags=re.S)
    text = re.sub(r'<!--.*?-->', '', text, flags=re.S)
    text = re.sub(r'```.*?```', '', text, flags=re.S)
    text = re.sub(r'^import .*$', '', text, flags=re.M)
    text = re.sub(r'<[^>]+>', '', text)
    text = re.sub(r'^:{2,}.*$', '', text, flags=re.M)
    text = re.sub(r'\[([^\]]+)\]\([^)]*\)', r'\1', text)
    text = re.sub(r'`[^`]*`', 'X', text)
    paragraphs = []
    for block in re.split(r'\n\s*\n', text):
        block = block.strip()
        if not block or block[0] in '#|-*0123456789>:':
            continue
        paragraphs.append(block)
    return paragraphs


def collect(paths: list[str]) -> list[Path]:
    files: list[Path] = []
    for raw in paths:
        path = Path(raw)
        if path.is_dir():
            files += sorted(p for p in path.rglob('*') if p.suffix in ('.md', '.mdx'))
        elif path.exists():
            files.append(path)
    return files


def analyse(files: list[Path], list_short: bool = False) -> dict | None:
    lengths: list[int] = []
    per_paragraph: list[int] = []
    you = contractions = words = 0
    for file in files:
        for paragraph in prose_paragraphs(file.read_text()):
            sentences = [s for s in re.split(r'(?<=[.!?])\s+', paragraph) if s.split()]
            per_paragraph.append(len(sentences))
            for sentence in sentences:
                count = len(sentence.split())
                lengths.append(count)
                words += count
                you += len(re.findall(r'\b(you|your)\b', sentence, re.I))
                contractions += len(re.findall(r"\w+'(t|s|re|ll|ve|d)\b", sentence))
                if list_short and count <= 6:
                    print(f'  short ({count}): {file.name}: {sentence[:90]}')
    if not lengths:
        return None
    mean = statistics.mean(lengths)
    return {
        'files': len(files),
        'sentences': len(lengths),
        'mean_sentence_words': round(mean, 1),
        'sentence_length_cv': round(statistics.pstdev(lengths) / mean, 2),
        'pct_sentences_le_6_words': round(100 * sum(n <= 6 for n in lengths) / len(lengths), 1),
        'pct_sentences_ge_25_words': round(100 * sum(n >= 25 for n in lengths) / len(lengths), 1),
        'sentences_per_paragraph': round(statistics.mean(per_paragraph), 2),
        'pct_one_sentence_paragraphs': round(100 * sum(n == 1 for n in per_paragraph) / len(per_paragraph), 1),
        'you_per_100_words': round(100 * you / words, 2),
        'contractions_per_100_words': round(100 * contractions / words, 2),
    }


def main() -> None:
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    per_file = '--per-file' in sys.argv
    list_short = '--list-short' in sys.argv
    files = collect(args)
    if not files:
        sys.exit(__doc__)
    if per_file:
        for file in files:
            result = analyse([file], list_short)
            print(file, result)
    print('TOTAL', analyse(files, list_short and not per_file))


if __name__ == '__main__':
    main()
