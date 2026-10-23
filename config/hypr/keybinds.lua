---------------------
---- KEYBINDINGS ----
---------------------

local terminal = "alacritty"
local browser = "google-chrome-stable"
local fileManager = "thunar"
-- NOCTALIA --
local menu = "noctalia msg panel-toggle launcher"
local lockscreen = "noctalia msg session lock"
local sessionMenu = "noctalia msg panel-toggle session"
local settingMenu = "noctalia msg settings-toggle"
local wallpaperSelector = "noctalia msg panel-toggle wallpaper"
local mainMod = "SUPER" -- Sets "Windows" key as main modifier

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
local closeWindowBind = hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.window.close())
-- closeWindowBind:set_enabled(false)
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + SHIFT + W ", hl.dsp.exec_cmd(wallpaperSelector))
hl.bind(mainMod .. " + SHIFT + I ", hl.dsp.exec_cmd(settingMenu))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))    -- dwindle only
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd(lockscreen))
hl.bind(mainMod .. " + ESCAPE", hl.dsp.exec_cmd(sessionMenu))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd(sessionMenu))

--mode management Work in progress
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen("maximized", "toggle"))
hl.bind(mainMod .. " + SHIFT + D", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" })) --maximize

-- Screenshot Taking
hl.bind("Print", hl.dsp.exec_cmd("grimblast copy area"))
hl.bind("ALT + Print", hl.dsp.exec_cmd("grimblast copy active"))
hl.bind("CTRL + Print", hl.dsp.exec_cmd("grimblast copy output"))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i}))
    hl.bind(mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
end

-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioStop", hl.dsp.exec_cmd("playerctl stop"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"), { locked = true })

----------------------------------------------------------------------
---- CAMBIO DINAMICO DEL LAYOUT DEL WORKSPACE ATTIVO --------------------
----------------------------------------------------------------------
--
-- Da Hyprland 0.54 il layout di tiling e' per-workspace: la "modalita'
-- di gestione" di un workspace si imposta con la workspace rule `layout`
-- (valori: "dwindle", "master", "scrolling").
--
-- A runtime la config si cambia solo via Lua (`hyprctl keyword` e'
-- disattivato con il parser Lua). Chiamare `hl.workspace_rule{...}`
-- qui dentro riapplica la regola SUBITO al workspace indicato.
--
-- Limite dell'API: l'oggetto workspace di Lua non espone il layout
-- corrente, quindi ci teniamo noi lo stato in `wsLayoutIdx`, una tabella
-- indicizzata per id di workspace. Lo stato si azzera a ogni reload
-- della config (comportamento accettato: si riparte da "master").
--
-- Bind: SUPER + SHIFT + J  ->  cicla master -> scrolling -> dwindle
--       sul solo workspace attualmente attivo, con notifica a schermo.

local wsLayouts   = { "master", "scrolling", "dwindle" }
local wsLayoutIdx = {} -- id workspace (string) -> indice in wsLayouts

local function cycleWorkspaceLayout()
    local id   = tostring(hl.get_active_workspace().id)
    -- Default 1: i workspace nascono "master" (vedi rules.lua), quindi
    -- la 1a pressione passa a "scrolling", poi "dwindle", poi torna a "master".
    local idx  = (wsLayoutIdx[id] or 1) % #wsLayouts + 1
    wsLayoutIdx[id] = idx
    local name = wsLayouts[idx]

    hl.workspace_rule({ workspace = id, layout = name })
    hl.notification.create({ text = "Workspace " .. id .. ": " .. name, time = 1500 })
end

hl.bind(mainMod .. " + SHIFT + J", cycleWorkspaceLayout)

----------------------------------------------------------------------
---- FINE CAMBIO DINAMICO LAYOUT ------------------------------------
----------------------------------------------------------------------
