-- Get a list of all saved sessions
set savedSessionFilesTemp to (list folder ((get path to home folder as string) & ".iterm-sessions") without invisibles)
set savedSessionFilenames to {}
repeat with savedSession in savedSessionFilesTemp
    copy (characters 2 thru -1 of (savedSession as POSIX file as string) as string) to end of savedSessionFilenames
end repeat

-- Get a list of all open sessions
set openSessionIds to {}
tell application "iTerm2"
    repeat with aWindow in windows
        repeat with aTab in tabs of aWindow
            repeat with aSession in sessions of aTab
                copy (get id of aSession) to end of openSessionIds
            end repeat
        end repeat
    end repeat
end tell

repeat with savedSession in savedSessionFilenames
    set savedSessionId to characters ((offset of ":" in savedSession) + 1) thru -1 of savedSession as string

    -- Is this saves session already open?
    set found to false
    repeat with openSession in openSessionIds
        if savedSessionId = (openSession as string) then
            set found to true
            exit repeat
        end if
    end repeat

    -- If this saved session is not open, restore it into a new tab
    if found = false then
        tell application "iTerm2"
            tell current window
                set theCommand to "bash -c \"export ITERM_SESSION_RESTORE=" & savedSession & " ; echo \\\"Restoring $ITERM_SESSION_RESTORE\\\" ; exec $SHELL -l\""
                create tab with default profile command theCommand
            end tell
        end tell
    end if
end repeat
return ""