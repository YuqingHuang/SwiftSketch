tell application "iOS Simulator"
    activate
end tell

tell application "System Events"
    tell process "iOS Simulator"
        tell menu bar 1
            tell menu bar item "iOS Simulator"
                tell menu "iOS Simulator"
                    click menu item "Reset Content and Settings…"
                end tell
            end tell
        end tell

        tell window 1
            click button 1
        end tell
    end tell
end tell

-- Run at the command line or from a shell script using something like: 'osascript reset_simulator.applescript'
