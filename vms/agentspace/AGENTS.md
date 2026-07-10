## Environment

- We are inside a NixOS QEMU VM.
  - Never run `nix-collect-garbage` because we are using a `/nix/store` overlayfs. If we're out of space, alert the user.
  - If a configuration of our environment is blocking a task, ask the user for changes.
  - Use a path under `$WORKSPACE` for scratch space.
- `nix` is available with flakes enabled, we can use `nix run nixpkgs#foo` to run missing tools.
- nodejs is available, prefer `npx` for running npm commands instead of installing.
- When creating a VM, make sure assigned storage and memory is less than what is available. Keep testing VMs small.
- When deciding how to build or test the project, review: `flake.nix`, `Makefile`, `justfile`
- When running a nix flake for the first time, minimize downloading nixpkgs repeatedly. For example, we can use `--override-flake` from another source that we've already run (unless we need the latest or specific nixpkgs).

## Style

- Testing:
  - Prefer unit tests, or end-to-end tests. Avoid mock tests unless we already have provisions for this.
  - Temporary tests for validation are acceptable, but keep them separate and remove them before completion.
  - Tests confirming removal of legacy functionality should be considered temporary.
- When something is saved while incomplete, add an `XXX: <Explanation>` comment to remind us to address it before merging.
- When there is a future opportunity for improvement, add a `TODO: <Explanation>` comment for a future task.

## Process

- Ask the user before introducing a new dependency, unless the task expects this.
- If we are in `main`, make fresh branch/bookmark for the task.
- For large incremental tasks, create separate commits per milestone.
- Write commit messages in a similar style to recent logs for the same directory.
  - Default to `<component>: <short description>` with additional details in the body.

## Retrospective

- Upon completion, review the session and offer suggestions for how this could have been easier in retrospect. For example, any environment changes or availability of tools or framing of the task.
