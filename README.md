# Dotfiles

These dotfiles are managed with [mise](https://mise.jdx.dev/dotfiles.html).

## Everyday workflow

Run dotfile commands from this repository:

```sh
cd ~/dotfiles
mise bootstrap dotfiles status
mise bootstrap dotfiles diff
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
adding, deleting, or moving tracked files, or after changing `mise.toml`:

```sh
mise bootstrap dotfiles apply --dry-run --verbose
mise bootstrap dotfiles apply
```

## Set up a new machine

Install Git and mise, then clone this repository at the expected path:

```sh
git clone git@github.com:Ret2Hell/dotfiles.git ~/dotfiles
cd ~/dotfiles
mise trust
mise bootstrap dotfiles apply --dry-run --verbose
mise bootstrap dotfiles apply
mise bootstrap dotfiles status --missing
```

Mise refuses to replace conflicting regular files or directories. Compare and
move any existing target out of the way before applying. Use `--force` only
after reviewing the dry-run and confirming that the existing target can be
replaced.

## Add a dotfile

Add the file beneath the package that owns it, using its path relative to
`$HOME`. For example, to manage `~/.config/foo/config.toml`:

```sh
mkdir -p foo/.config/foo
mv ~/.config/foo/config.toml foo/.config/foo/config.toml
git add foo/.config/foo/config.toml
```

Add a mapping to `mise.toml` when this is a new target directory:

```toml
"~/.config/foo" = { source = "foo/.config/foo", mode = "symlink-each", manifest = "git" }
```

Then preview and apply it:

```sh
mise bootstrap dotfiles apply --dry-run --verbose
mise bootstrap dotfiles apply
mise bootstrap dotfiles status
```

For another file inside an already mapped directory, only move it into the
matching package, add it to Git, and apply. The Git manifest is intentional:
an untracked source file is not deployed.

Use a whole-file `symlink` entry for standalone files such as `~/.gitconfig`.
Use `symlink-each` for directories that may also contain application-managed
files. Avoid committing credentials, logs, histories, caches, databases,
`node_modules`, or machine-specific application state.

## Stop managing a file

Remove the source from Git and apply the new manifest:

```sh
git rm package/path/to/file
mise bootstrap dotfiles apply --dry-run --verbose
mise bootstrap dotfiles apply
```

For `symlink-each`, mise removes the link it previously managed but preserves
unmanaged neighboring files. Remove the corresponding `mise.toml` entry when
the entire target is no longer managed.

To remove all currently configured links without deleting repository sources:

```sh
mise bootstrap dotfiles unapply --dry-run
mise bootstrap dotfiles unapply
```

Recreate them with `mise bootstrap dotfiles apply`.

## Pull updates

After pulling repository changes, inspect and deploy any added, removed, or
moved files:

```sh
git pull --ff-only
mise bootstrap dotfiles diff
mise bootstrap dotfiles apply
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
mise bootstrap dotfiles status            # Show deployment state
mise bootstrap dotfiles status --missing  # Exit nonzero when out of sync
mise bootstrap dotfiles diff              # Show required changes
mise bootstrap dotfiles apply --dry-run   # Preview deployment
mise bootstrap dotfiles apply             # Deploy tracked files
mise bootstrap dotfiles unapply --dry-run # Preview link removal
mise bootstrap dotfiles edit TARGET       # Edit a managed source
```
