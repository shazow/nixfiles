## Environment

- We are inside a NixOS QEMU VM.
- If a configuration of our environment is blocking a task, ask the user for changes.
- `nix` is available with flakes enabled, we can use `nix run nixpkgs#foo` to run missing tools.
- nodejs is available, prefer `npx` for running npm commands instead of installing.
- When creating a VM, make sure assigned memory is less than available memory.
- When deciding how to build or test the project, review: `flake.nix`, `Makefile`, `justfile`
- When running a nix flake for the first time, minimize downloading nixpkgs repeatedly. For example, we can use `--override-flake` from another source that we've already run (unless we need the latest or specific nixpkgs).

## Style

- Only reformat files we are working on. Avoid unrelated changes.
- Keep changes small with architecture that is congruent with the surrounding code.
- Testing: Prefer unit tests, or end-to-end tests. Avoid mock tests unless we already have provisions for this. Throw-away tests for validation are acceptable, but keep them separate and remove them before completion.

## Process

- Ask the user before introducing a new dependency, unless the task expects this.
- If we're using jujutsu (`.jj` is present), invoke a status command after each step to leverage the snapshotting functionality, create/move task bookmarks track against a branch.
- If we are in `main`, make fresh branch/bookmark for the task.
- We can roll back to previous snapshots if the code state gets messy. Before rolling back, write `NOTES.md` with what we learned and what went wrong and make a commit so we have a commit reference we can review later.
- Whenever we make progress, consider making a commit.
- Upon completion, review the session and offer suggestions for how this could have been easier in retrospect. For example, any environment changes or availability of tools or framing of the task.
