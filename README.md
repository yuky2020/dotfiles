# dotfiles: Hyprland + Noctalia

La mia configurazione desktop Wayland su Arch Linux ([CachyOS](https://cachyos.org)):

- **[Hyprland](https://hypr.land)** 0.56: compositor, configurato in **Lua** (non `hyprland.conf`)
- **[Noctalia Shell](https://github.com/noctalia-dev/noctalia-shell)** 5.3: barra, launcher, lock screen, notifiche, wallpaper, menu di sessione, con colori presi dal wallpaper
- **Alacritty** come terminale (tema generato da Noctalia), **Ghostty** per il plugin degli aggiornamenti
- Script **Sunshine** per lo streaming remoto (Moonlight) su un monitor virtuale headless

## Struttura

```
config/
  hypr/          -> ~/.config/hypr
  noctalia/      -> ~/.config/noctalia   (settings, colori, plugin)
  alacritty/     -> ~/.config/alacritty
  ghostty/       -> ~/.config/ghostty
bin/             -> ~/.local/bin          (script Sunshine)
examples/sunshine/                        (config Sunshine e hypridle di esempio)
packages.txt                              (pacchetti base)
packages-sunshine.txt                     (pacchetti per lo streaming)
install.sh
```

La config di Hyprland è divisa in moduli caricati da `hyprland.lua`:

| File | Contenuto |
|---|---|
| `monitors.lua` | Monitor e assegnazione workspace: 1-8 su `DP-1`, 9-10 su `HDMI-A-1` |
| `autostart.lua` | Avvio di Noctalia, polkit agent, Sunshine, sblocco KWallet |
| `environment.lua` | Cursore (`Oxygen_Zion`) e variabili Qt |
| `lookandfeel.lua` | Gap, bordi, blur, animazioni, smart gaps |
| `input.lua` | Tastiera `it`, gesture a 3 dita per i workspace |
| `keybinds.lua` | Scorciatoie (vedi sotto) |
| `rules.lua` | Window rule e layout `master` di default per ogni workspace |

## Installazione

Richiede Arch Linux (o una derivata) con [`paru`](https://github.com/Morganamilo/paru).
Su Arch base, `noctalia-qs`, `grimblast-git` e `google-chrome` vengono da AUR. Su CachyOS sono nei repo.

```bash
git clone https://github.com/yuky2020/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

Lo script:

1. installa i pacchetti di `packages.txt` e `packages-sunshine.txt` con `paru -S --needed`;
2. sposta le config esistenti in `~/.config/dotfiles-backup-<data>/`;
3. crea i symlink da `~/.config/*` e `~/.local/bin/*` verso il repo;
4. adatta il percorso dei wallpaper in `config/noctalia/settings.json` alla tua home.

Opzioni:

- `--no-packages`: salta l'installazione dei pacchetti
- `--no-sunshine`: salta gli script Sunshine e toglie la riga dall'autostart

Dopo l'installazione:

1. Adatta `config/hypr/monitors.lua` ai tuoi monitor. Usa `hyprctl monitors` per vedere i nomi.
2. Metti i wallpaper in `~/Pictures/Wallpapers`. I colori di Noctalia e dei terminali si generano dal wallpaper.
3. Esci dalla sessione e scegli Hyprland dal display manager.

Visto che i file sono symlink, ogni modifica fatta da Noctalia o a mano finisce nel repo. Basta un `git commit` per salvarla.

## Scorciatoie principali

`SUPER` è il tasto modificatore.

| Tasti | Azione |
|---|---|
| `SUPER + Invio` | Terminale (alacritty) |
| `SUPER + D` | Launcher Noctalia |
| `SUPER + W` | Browser |
| `SUPER + F` | File manager (thunar) |
| `SUPER + SHIFT + Q` | Chiudi finestra |
| `SUPER + V` | Finestra flottante on/off |
| `SUPER + SHIFT + F` / `SHIFT + D` | Massimizza |
| `SUPER + SHIFT + J` | Cambia layout del workspace attivo: master, scrolling, dwindle |
| `SUPER + J` | Cambia direzione dello split (dwindle) |
| `SUPER + L` | Blocca lo schermo |
| `SUPER + ESC` / `SHIFT + L` | Menu di sessione |
| `SUPER + SHIFT + W` | Selettore wallpaper |
| `SUPER + SHIFT + I` | Impostazioni Noctalia |
| `SUPER + S` / `SHIFT + S` | Scratchpad: mostra / sposta finestra |
| `SUPER + 1..0` / `SHIFT + 1..0` | Vai al workspace / sposta la finestra |
| `SUPER + M` | Esci da Hyprland |
| `Print` / `ALT + Print` / `CTRL + Print` | Screenshot area / finestra / monitor |

## Plugin Noctalia

Sono inclusi nel repo e si attivano da `config/noctalia/plugins.json`. Provengono da [noctalia-plugins](https://github.com/noctalia-dev/noctalia-plugins):

- `arch-updater`: aggiornamenti pacman, AUR e flatpak
- `file-search`: ricerca file dal launcher
- `kde-connect`
- `monitor-layout`
- `screen-recorder`, `screen-shot-and-record`
- `hassio`: Home Assistant (disattivato)

Il file `plugins/hassio/settings.json` è escluso con `.gitignore` perché contiene URL e token di Home Assistant. Per usare il plugin, attivalo e inserisci URL e token dalle impostazioni di Noctalia.

## Sunshine (streaming remoto)

Gli script in `bin/` creano un monitor virtuale `HEADLESS` 1920x1080 e ci spostano i workspace quando un client Moonlight si connette. Lo schermo fisico si spegne durante la sessione e torna come prima alla disconnessione.

| Script | Quando gira |
|---|---|
| `sunshine-start.sh` | Al login (da `autostart.lua`): crea il monitor headless e avvia Sunshine |
| `sunshine-connect.sh` | Alla connessione del client (`global_prep_cmd` "do") |
| `sunshine-disconnect.sh` | Alla disconnessione (`global_prep_cmd` "undo") |
| `sunshine-after-sleep.sh` | Dopo la sospensione (`after_sleep_cmd` di hypridle) |

Configurazione:

1. Copia `examples/sunshine/sunshine.conf.example` in `~/.config/sunshine/sunshine.conf`.
2. Se usi hypridle, aggiungi la riga di `examples/sunshine/hypridle-snippet.conf`.
3. Gli script assumono che il monitor principale sia `DP-1`. Se il tuo ha un altro nome, sostituiscilo negli script.

Gli script funzionano sia con la config Lua sia con quella classica di Hyprland.

## Note

- Cursore: `Oxygen_Zion`, dal pacchetto `oxygen-cursors`.
- Font del terminale: JetBrains Mono.
- `autostart.lua` sblocca KWallet al login con `pam_kwallet_init`. Se non usi KWallet, togli le ultime due righe.
