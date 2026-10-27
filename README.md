# i3

My i3 config - Catppuccin Mocha throughout, a tmux-backed scratch terminal,
and a startup sequence that was debugged into its current shape rather
than copy-pasted.

## Layout on login

- Workspace 1: a terminal running tmux (tagged via a one-off `--class` so
  the `assign` rule only ever grabs that one startup window, not every
  future Alacritty instance).
- Workspace 2: Firefox.
- `xss-lock` + `i3lock` handle both idle-suspend locking and the physical
  lock keys (`XF86ScreenSaver`/`XF86Lock` go through `loginctl
  lock-session`, the same path suspend uses - one lock implementation,
  not two).
- `batsignal` fires low-battery desktop notifications.
- `$mod+grave` drops down a scratch terminal backed by a named tmux
  session (`scripts/toggle_scratch.sh`) - it's not just an i3 scratchpad
  window, you can `tmux attach -t quick` from anywhere and land in the
  exact same session.

## Two real bugs, not just theming

**Alt+Space wouldn't switch keyboard layout.** Two independent things
were fighting over it at once: i3 itself had a `bindsym` claiming the
combo before X's own XKB layer ever saw it, *and* `.xinitrc` was racing
the `setxkbmap` call against i3 actually starting. Fixing one alone did
nothing - both had to go. The layout toggle now lives entirely in
`exec_always --no-startup-id setxkbmap -layout us,ir -option
grp:alt_space_toggle` (line 81), run from inside i3's own startup, not
`.xinitrc`.

**Startup used to hang.** `.xinitrc` was blocking on
`systemctl --user import-environment` *before* `exec i3` - if the user
D-Bus/systemd manager wasn't up yet, the whole session just sat there.
Moved to a non-blocking `exec --no-startup-id` inside the i3 config
itself (line 56), so it runs after i3 is already up and can never delay
login again.

## CI

GitHub Actions runs shellcheck against `scripts/*.sh` on every push.
Security scanning is handled separately by the Snyk GitHub App.
