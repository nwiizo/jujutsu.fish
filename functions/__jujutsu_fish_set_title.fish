function __jujutsu_fish_set_title --description 'Set the terminal tab/window title via OSC 0 (no-op when stdout is not a tty)'
    # OSC 0 (ESC ]0;<title>BEL) sets both icon name and window title and
    # is honored by xterm-compatible terminals: Ghostty, iTerm2, WezTerm,
    # Alacritty, Kitty, tmux (when set-titles on), Terminal.app. We gate
    # on isatty so fishtape, CI, and piped invocations stay clean.
    isatty stdout; or return 0
    printf '\e]0;%s\a' $argv[1]
end
