# Changesets

Only for the plugin package — the docs package is private and ignored.

- **minor** for the Astro/Starlight support bump, worded like previous releases and like Starlight/HiDeoo:
  ```md
  ---
  "<plugin>": minor
  ---

  Adds support for Astro v7, drops support for Astro v6.

  ⚠️ **BREAKING CHANGE:** The minimum supported version of Starlight is now `0.42.0`.

  Please follow the [upgrade guide](https://github.com/withastro/starlight/releases/tag/%40astrojs%2Fstarlight%400.42.0) to update your project.
  ```
- **minor or patch** for Sätteri support if added ("Adds support for Astro's Sätteri Markdown processor.").
- **patch** for each real user-facing bug fix (one changeset each, describing the user-visible effect).
- **patch** for the internal refactor / removed dependencies.
- **No** changeset for package metadata changes (keywords, homepage, repository fields, LICENSE file).

Use absolute URLs in changesets — they end up in the published CHANGELOG.
