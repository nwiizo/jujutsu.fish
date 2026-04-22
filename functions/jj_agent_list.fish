function jj_agent_list --description 'List jj workspaces with their working-copy state at a glance'
    type -q jj; or begin
        __jujutsu_fish_err 'jj is not installed'
        return 127
    end

    # One row per workspace:
    #   <name>\t<change-id short>\t<dirty|clean>\t<description first line>
    # The dirty/clean column is the single most useful signal when running
    # N parallel agent sessions.
    set -l template '
        name ++ "\t" ++
        target.change_id().shortest(8) ++ "\t" ++
        if(target.empty(), "clean", "dirty") ++ "\t" ++
        target.description().first_line() ++ "\n"
    '

    set -l rows (jj workspace list -T "$template" 2>/dev/null)
    test (count $rows) -eq 0; and begin
        __jujutsu_fish_err 'no workspaces found'
        return 1
    end

    # Compute max workspace-name width so very long names do not blow the
    # layout. Bounded by 32 so a single outlier does not push the rest.
    set -l name_w 4 # len("NAME")
    for row in $rows
        set -l parts (string split -m3 \t -- $row)
        set -l w (string length -- $parts[1])
        test $w -gt $name_w; and set name_w $w
    end
    test $name_w -gt 32; and set name_w 32

    # Gate coloring on isatty so piped output stays parseable.
    set -l clean_c ''
    set -l dirty_c ''
    set -l header_c ''
    set -l reset ''
    if isatty stdout
        set clean_c (set_color green)
        set dirty_c (set_color yellow --bold)
        set header_c (set_color --bold)
        set reset (set_color normal)
    end

    printf '%s%-*s  %-10s  %-6s  %s%s\n' $header_c $name_w NAME CHANGE STATE DESCRIPTION $reset
    for row in $rows
        # -m3 caps splits at 4 fields so tabs in the description are
        # preserved as-is rather than eating into the description column.
        set -l parts (string split -m3 \t -- $row)
        set -l state_c $clean_c
        test "$parts[3]" = dirty; and set state_c $dirty_c
        printf '%-*s  %-10s  %s%-6s%s  %s\n' $name_w $parts[1] $parts[2] $state_c $parts[3] $reset $parts[4]
    end
end
