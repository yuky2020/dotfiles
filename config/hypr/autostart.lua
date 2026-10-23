-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:

hl.on("hyprland.start", function ()
  hl.exec_cmd("exec noctalia")
  hl.exec_cmd("systemctl --user start hyprpolkitagent")
  hl.exec_cmd("~/.local/bin/sunshine-start.sh")
  hl.exec_cmd("/usr/lib/pam_kwallet_init")
  hl.exec_cmd("qdbus6 org.kde.kwalletd6 /modules/kwalletd6 org.kde.KWallet.open kdewallet 0 login")
end)
