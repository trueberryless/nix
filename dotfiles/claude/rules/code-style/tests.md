---
paths:
  - "**/*.{test,spec,bench}.{ts,mts,js}"
  - "**/{test,tests,__tests__,e2e}/**/*"
  - "**/{vitest,playwright}.config.*"
---

# Code style: tests

- Use Vitest for unit and integration tests, and Playwright for browser e2e. Keep tests in `test/` or `tests/{unit,e2e}/`, with one file per module or feature (`libs/page.ts` → `tests/unit/page.test.ts`).
- Name the `describe` after the unit under test (`describe('getRelativeUrl', …)`) and nest it for variants (`describe('with a base', …)`).
- Test names describe behaviour in the present tense, with no "should": `'returns the blog root path'`, `'does not transform non-JS files'`, `'prefixes the path with a leading slash if needed'`.
- Group several related `expect`s in one test when they check the same behaviour across inputs (locales, modes). Keep separate behaviours in separate tests.
- For transforms, codegen and error output, prefer `toMatchInlineSnapshot()` so the expected value sits next to the input. Use `toMatchFileSnapshot()` for large outputs. Never snapshot something you could assert precisely.
- Keep real inputs in `fixtures/` (small projects or files) and build them in tests. Use helpers like `getTestConfig()` in a shared `tests/unit/utils.ts` instead of copy-pasted setup.
- Use a separate Vitest config/project per configuration variant (e.g. `tests/unit/i18n/vitest.config.ts`) instead of mutating global state between tests.
- Use `vi.stubEnv`/`vi.resetModules` + dynamic `import()` to test module-level config. Always restore in `afterEach` (`vi.unstubAllEnvs()`, `vi.restoreAllMocks()`).
- Playwright:
  - Use page-object classes exposed as custom fixtures (`test.extend<{ blogPage: BlogPage }>`).
  - Use role/label locators (`getByRole`, `getByLabel`), not CSS selectors.
  - Assert on user-visible outcomes.
- Every bug fix comes with a regression test that fails without the fix.
- No `.only` committed. No arbitrary timeouts: wait for a condition.
