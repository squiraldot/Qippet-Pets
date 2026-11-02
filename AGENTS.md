# Repository working agreements

These rules apply to all future work in this repository.

- Work only on the `main` branch. Make small, focused commits with Conventional Commit messages. Never create feature branches or pull requests, and never force-push.
- After every push, inspect the corresponding GitHub Actions run. If it fails, read the failing job logs, fix the problem directly on `main`, push again, and repeat until green.
- Every feature must ship with tests. `flutter analyze` must remain clean.
- Never commit secrets, signing credentials, keystores, or generated private keys.
- Do not stop to ask questions. Make a reasonable assumption and record it in `docs/DECISIONS.md`.
- Keep `docs/PROGRESS.md` updated after each task.
