--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

local suppressMaximizeRule = hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})
-- suppressMaximizeRule:set_enabled(false)

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

-- Hyprland-run windowrule
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})

-- Float Necessary Windows
hl.window_rule({ match = { class = "(xdg-desktop-portal-gtk|xdg-desktop-portal-kde|xdg-desktop-portal-hyprland)(.*)" }, float = true })
hl.window_rule({ match = { class = "(hyprpolkitagent|qt-sudo)(.*)" }, float = true })
hl.window_rule({ match = { initial_title = "(Rename|File Operation Progress|Extract)(.*)" }, float = true, size = { "(monitor_w*0.25)", "(monitor_h*0.125)" } })
hl.window_rule({ match = { initial_class = "hyprland-share-picker" }, float = true })

-- Window transparency
hl.window_rule({ match = { initial_class = "thunar" }, opacity = 0.92 })

----------------------------------------------------------------------
---- LAYOUT DI DEFAULT PER WORKSPACE --------------------------------
----------------------------------------------------------------------
--
-- Da Hyprland 0.54 il layout di tiling e' per-workspace. Qui ogni
-- workspace parte in modalita' "master". Il bind SUPER + SHIFT + J
-- (vedi keybinds.lua) puo' poi cambiarlo a runtime per il singolo
-- workspace attivo, ciclando master -> scrolling -> dwindle.
--
-- Regole scritte per esteso, una per workspace (1-10 + lo special
-- workspace "magic"), cosi' sono facili da modificare singolarmente.

hl.workspace_rule({ workspace = "1",  layout = "master" })
hl.workspace_rule({ workspace = "2",  layout = "master" })
hl.workspace_rule({ workspace = "3",  layout = "master" })
hl.workspace_rule({ workspace = "4",  layout = "master" })
hl.workspace_rule({ workspace = "5",  layout = "master" })
hl.workspace_rule({ workspace = "6",  layout = "master" })
hl.workspace_rule({ workspace = "7",  layout = "master" })
hl.workspace_rule({ workspace = "8",  layout = "master" })
hl.workspace_rule({ workspace = "9",  layout = "master" })
hl.workspace_rule({ workspace = "10", layout = "master" })
hl.workspace_rule({ workspace = "special:magic", layout = "master" })

----------------------------------------------------------------------
---- FINE LAYOUT DI DEFAULT PER WORKSPACE ---------------------------
----------------------------------------------------------------------
