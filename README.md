# Dotfiles

These dotfiles are managed with [mise](https://mise.jdx.dev/dotfiles.html)
2026.10.3 or newer, using one dotfile group per application.

Each group's directory mirrors `$HOME`: for example,
`zsh/.zshenv` deploys to `~/.zshenv`, and
`yazi/.local/bin/omarchy-yazi-reload` deploys to
`~/.local/bin/omarchy-yazi-reload`. Groups use `symlink-each`, so
application-managed files can coexist with managed links.

Every group uses `manifest = "git"`: only files in Git's index are deployed.
Gitignored or untracked files are not deployed. Herdr logs, session state,
and release notes are also explicitly excluded; Herdr manages these locally.

## Everyday workflow

Run dotfile commands from this repository:

```sh
cd ~/dotfiles
mise dot status
mise dot diff
```

Edit a linked file normally, then review and commit it with Git:

```sh
$EDITOR ~/.config/nvim/init.lua
git diff
git add nvim/.config/nvim/init.lua
git commit -m "nvim: update configuration"
git push
```

No apply step is needed after editing an existing symlink. Run apply after
adding or moving tracked files, or after changing `mise.toml`:

```sh
mise dot apply --dry-run --verbose
mise dot apply
```

For deletions, exclusions, or deselected groups, review orphaned files and use
the explicit pruning workflow below.

## Set up a new machine

Install Git and mise 2026.10.3 or newer, then clone this repository at the
expected path:

```sh
git clone git@github.com:Ret2Hell/dotfiles.git ~/dotfiles
cd ~/dotfiles
mise trust
mise dot apply --dry-run --verbose
mise dot apply
mise dot status --missing
```

Group roots are relative to the `dotfiles.root` setting, which this repository
sets to `~/dotfiles`. If you clone elsewhere, update that setting, for example
in an ignored `mise.local.toml`.

Yazi plugins are gitignored, so install them once per machine after the first apply:

```sh
ya pkg install
```

Mise refuses to replace conflicting regular files or directories. Compare and
move any existing target out of the way before applying. Use `--force` only
after reviewing the dry-run and confirming that the existing target can be
replaced.

## Choose groups for a machine

All groups apply by default. To select a subset, create an ignored
`mise.local.toml` in this repository:

```toml
[bootstrap]
dotfile_groups = ["git", "zsh", "nvim", "yazi"]
```

Available groups: `git`, `herdr`, `hypr`, `kitty`, `nvim`, `omarchy`,
`opencode`, `scripts`, `spicetify`, `yazi`, and `zsh`.

The `scripts` group deploys `~/setup-omarchy-plugins`; the `spicetify` group
also deploys `~/setup.sh`. Deselecting a group leaves its existing files in
place until you prune or unapply that group. A local selection replaces the
selection from other configs; it does not extend it.

## Add a dotfile

For a new file belonging to an existing group, preview and capture it:

```sh
mise dot add --group zsh --dry-run ~/.zprofile
mise dot add --group zsh --no-apply ~/.zprofile
git add zsh/.zprofile
mise dot apply --dry-run --verbose
```

Capturing with `--no-apply` leaves the live file unchanged. Because it is still
a regular file, move it to a backup outside the target path before applying,
then remove the backup once the linked file is verified:

```sh
mv ~/.zprofile ~/.zprofile.before-mise
mise dot apply
mise dot status
```

Use `--group` to make the destination package explicit: these groups all
target `~`, so a new path could otherwise match several groups.

Alternatively, move the file into its package manually:

```sh
mkdir -p foo/.config/foo
mv ~/.config/foo/config.toml foo/.config/foo/config.toml
git add foo/.config/foo/config.toml
```

For a new package, declare its group in `mise.toml`:

```toml
[dotfile_groups.foo]
root = "foo"
manifest = "git"
```

Then preview and apply. No extra mapping is needed for new files or
directories inside an existing group. If this machine selects groups
explicitly, add the new group to that selection too.

Avoid committing credentials, logs, histories, caches, databases,
`node_modules`, or machine-specific application state. Adding a tracked file
to `.gitignore` does not untrack it.

## Stop managing a file or group

Remove the source from Git:

```sh
git rm package/path/to/file
```

To keep the local source instead, add an ignore rule and use
`git rm --cached package/path/to/file`.

Removing a file from a group's manifest, adding an exclusion, deselecting a
group, or deleting its config can leave previously deployed files orphaned.
Inspect and remove them explicitly:

```sh
mise dot status
mise dot apply --dry-run --prune
mise dot apply --prune
```

Pruning covers all orphaned groups and asks for confirmation. It removes only
links that still point to their recorded sources, or copies that still match
what mise wrote, unless forced. Unmanaged neighboring files are preserved.
Back up live runtime state before removing its old managed links.

To remove one group's deployed files without deleting repository sources,
even after removing the group from config:

```sh
mise dot unapply --group zsh --dry-run
mise dot unapply --group zsh
```

To remove all currently configured links:

```sh
mise dot unapply --dry-run
mise dot unapply
```

Recreate links for selected groups with `mise dot apply`.

## Pull updates

After pulling repository changes, inspect and deploy any added, removed, or
moved files:

```sh
git pull --ff-only
mise dot diff
mise dot status
mise dot apply --dry-run --prune
mise dot apply --prune
```

Changes to files already linked are immediately visible and may not produce an
apply diff.

## Recovery

The repository remains the source of truth, so use normal Git history to
inspect or restore configuration:

```sh
git log --oneline -- path/to/file
git diff HEAD~1 -- path/to/file
git restore --source=HEAD~1 -- path/to/file
```

Review the restored content and commit it normally. Mise's separate dotfile
history watcher and synchronization repository are deliberately not enabled;
they would duplicate this repository's Git history and remote workflow.

## Useful commands

```sh
mise dot status                      # Show deployment state, including orphans
mise dot status --missing            # Exit nonzero for unapplied active entries
mise dot diff                        # Show required changes
mise dot apply --dry-run             # Preview deployment
mise dot apply                       # Deploy tracked files
mise dot apply --dry-run --prune      # Preview deployment and orphan cleanup
mise dot apply --prune                # Deploy and remove orphaned files
mise dot unapply --group zsh --dry-run # Preview removal of one group
mise dot edit TARGET                 # Edit a managed source
```
