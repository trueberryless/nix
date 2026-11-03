# Measuring the feel

There is no tool that tells you whether prose reads as human. Detectors that score text for statistical traces cannot see the problem this skill addresses: a page can score "clean" and still be choppy and compressed. What does separate natural technical writing from the compressed kind is rhythm, and rhythm can be measured.

`scripts/rhythm.py` reads Markdown or MDX files, strips everything that is not prose (front matter, code, comments, tables, headings, list items, components, link targets), and prints sentence statistics.

```sh
python3 ~/.claude/skills/technical-docs/scripts/rhythm.py docs/content            # totals
python3 ~/.claude/skills/technical-docs/scripts/rhythm.py docs/content --per-file # per file
python3 ~/.claude/skills/technical-docs/scripts/rhythm.py docs/content/guides --list-short  # print sentences of six words or fewer
```

It needs only Python 3.9 or newer, with no dependencies.

## The numbers

| Metric | Choppy, compressed docs | Natural guides | Targets for guides, concepts and getting started |
| --- | --- | --- | --- |
| Mean sentence length (words) | about 10 to 11 | about 16 to 17 | 14 to 18 |
| Sentences of six words or fewer | about 25% | about 5% | at most about 10% |
| Sentences of 25 words or more | about 2% | about 13% | 8% to 15% |
| "you" and "your" per 100 words | about 0.5 | about 4 | 2.5 or more in guides, 3 or more in getting started |
| Sentences per paragraph | about 1.7 | about 1.7 to 2.7 | 2 to 3 |
| Share of one-sentence paragraphs | about 55% | about 15% to 50% | under 30% |
| Sentence length variation (CV) | varies | about 0.4 to 0.5 | 0.35 to 0.55 |

Reference pages, provider pages and examples can sit lower on "you" and higher on short sentences, because they are more list-like. The mean sentence length there should still be above about 13, and the share of very short sentences under about 15%.

## How to use them

- Run the script before you start to get a baseline, and after each section to see the movement.
- Treat the numbers as guard rails. They tell you where to look, not what to write. Padding can satisfy them and still read badly, and a good page can miss one of them for a reason.
- `--list-short` shows the very short sentences. Judge each one. Many are legitimate (a one-line unavailability note, an instruction in a recipe). The ones to fix are chains of short sentences stating separate facts, and fragments that point at the previous sentence.
- A high CV with a low mean and many short sentences is a bad sign: a few long sentences among a crowd of short ones inflate variation.
- The final authority is a human read (see phase 7 of the workflow).

## Other mechanical checks

- Invisible characters, odd spaces and look-alike characters sometimes sneak into text. A quick scan for non-ASCII characters in the files you changed (apart from intentional ones such as symbols in tables) is cheap.
- Em dashes: check the project's convention. If there is none, avoid them.
- Run the project's linter, docs tests, docs build and link check with fragments. A broken anchor is a real defect.
- Search for leftover placeholders and for words from `voice-and-flow.md` section 8 that you meant to remove ("simply", "just", "can" used as a hedge, "in order to").
- Search the pages you wrote for history words: `grep -niE "\b(no longer|previously|used to|formerly|originally|recently|newly|now (supports|requires|returns|uses)|as of|in older versions|has been (replaced|removed|changed)|we (changed|decided|added))\b"`. Judge every hit. Some are harmless ("used to verify deliveries", "as of" in a version requirement), some are sentences to rewrite as current state, and some are deliberate exceptions (blog post, changelog, migration guide).

Do not try to defeat or satisfy an AI-text detector. Statistical traces cannot be removed by wording tricks, and chasing them damages the writing. Write well and verify the facts.
