## Python tooling

- Prefer `uv` for Python scripts, dependencies, and virtual environments instead of manually running `python -m venv` and `pip install`.
- For one-off scripts with dependencies, use `uv run --with <package> python ...` (for example, `uv run --with pymupdf python ...` for PDF editing). Avoid creating a manual virtual environment just for these tasks.
- Respect existing project tooling and dependency conventions.

## JavaScript / TypeScript tooling

- Default to `pnpm` for JavaScript and TypeScript package management and tooling, including new projects and one-off commands. Use its `pn` shorthand in commands.
- Use `pn exec <command>` for project-installed tools and `pnx <package>` (the shorthand for `pnpm dlx`) for one-off tools instead of `npx`.
- Respect the project's existing package manager (for example, npm, Bun, or Yarn), as indicated by its `packageManager` field, lockfile, or documented conventions. Do not switch package managers or introduce a competing lockfile.
