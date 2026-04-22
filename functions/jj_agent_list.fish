function jj_agent_list --description 'List jj workspaces with their working-copy state at a glance'
    type -q jj; or begin
        echo "jj_agent_list: jj is not installed" >&2
        return 127
    end

    # One row per workspace:
    #   <name>\t<change-id short>\t<empty?>\t<description first line>
    # The `empty` column is 'dirty' if the workspace @ has any diff against
    # its parent, otherwise 'clean'. This is the single most useful signal
    # when managing N parallel agent sessions.
    set -l template '
        name ++ "\t" ++
        target.change_id().shortest(8) ++ "\t" ++
        if(target.empty(), "clean", "dirty") ++ "\t" ++
        target.description().first_line() ++ "\n"
    '

    set -l rows (jj workspace list -T "$template" 2>/dev/null)
    test (count $rows) -eq 0; and begin
        echo "jj_agent_list: no workspaces found" >&2
        return 1
    end

    # Pretty-align using string-based padding so we do not depend on
    # `column` (not guaranteed on every OS).
    printf '%-20s  %-10s  %-6s  %s\n' NAME CHANGE STATE DESCRIPTION
    for row in $rows
        set -l parts (string split \t -- $row)
        printf '%-20s  %-10s  %-6s  %s\n' $parts[1] $parts[2] $parts[3] $parts[4]
    end
end
