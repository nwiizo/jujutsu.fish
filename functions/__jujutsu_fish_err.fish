function __jujutsu_fish_err --description 'Print a repo-standard error message with the caller name'
    set -l frames (status stack-trace)
    set -l function_frames (string match -r "^in function '[^']+'" -- $frames)
    set -l caller_line $function_frames[2]
    test -n "$caller_line"; or set caller_line $function_frames[1]
    set -l caller (string split "'" -- $caller_line)[2]
    test -n "$caller"; or set caller jujutsu.fish

    # Gate color on stderr being a TTY so captured output (fishtape, CI,
    # `2>file` redirects) stays plain text and matches the test contract.
    if isatty stderr
        printf '%s%s:%s %s\n' (set_color red --bold) $caller (set_color normal) $argv[1] >&2
    else
        printf '%s: %s\n' $caller $argv[1] >&2
    end
end
