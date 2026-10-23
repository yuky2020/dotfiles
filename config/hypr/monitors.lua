------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})

-- TWO monitor config
hl.monitor({
    output   = "DP-1",
    mode     = "3840x2160@160",
    position = "0x0",
    scale    = "1.33",
})

hl.monitor({
    output   = "HDMI-A-1",
    mode     = "2560x1440@144",
    position = "-2560x160",
    scale    = 1
})


--------------------------------
---- WORKSPACE -> MONITOR ------
--------------------------------

-- Workspace 1-8 sempre su DP-1, 9-10 su HDMI-A-1.
-- Se c'e' solo DP-1, Hyprland apre 9 e 10 sul monitor disponibile
-- (DP-1), quindi in pratica tutti i workspace stanno su DP-1.
-- Quando HDMI-A-1 viene scollegato, Hyprland sposta da solo i suoi
-- workspace su DP-1.
local MAIN_MONITOR   = "DP-1"
local SECOND_MONITOR = "HDMI-A-1"

for i = 1, 8 do
    hl.workspace_rule({
        workspace = tostring(i),
        monitor   = MAIN_MONITOR,
        default   = (i == 1),
    })
end

for i = 9, 10 do
    hl.workspace_rule({
        workspace = tostring(i),
        monitor   = SECOND_MONITOR,
        default   = (i == 9),
    })
end

-- Quando HDMI-A-1 viene ricollegato, riporta 9 e 10 su di esso
-- (la regola vale solo per i workspace creati dopo, quelli gia'
-- esistenti restano su DP-1 senza questo spostamento esplicito).
hl.on("monitor.added", function(monitor)
    if not monitor or monitor.name ~= SECOND_MONITOR then
        return
    end
    for i = 9, 10 do
        if hl.get_workspace(i) then
            hl.dispatch(hl.dsp.workspace.move({ workspace = i, monitor = SECOND_MONITOR }))
        end
    end
end)
