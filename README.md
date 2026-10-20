# SpinningArchLogo

The Arch logo in fastfetch, but it spins.

You open a terminal, the logo does two turns and slows down until it stops, with a little whoosh sound, and then your system info shows up next to it like normal. That's all it does. I made it for my own Hyprland setup and liked it too much to keep it in there, so here it is on its own.

![The Arch logo spinning in fastfetch](demo.gif)

## What you need

- Arch Linux (or anything with fastfetch, it'll still spin, the installer just uses pacman to grab what's missing)
- fastfetch
- python3
- pipewire for the sound (`pw-play`). If you don't have it, `paplay` or `aplay` work too, and if none of them are there it just spins quietly

You don't need Hyprland or Wayland for this. Any terminal works.

## Install

```bash
git clone https://github.com/infectedwarelol/SpinningArchLogo.git
cd SpinningArchLogo
./install.sh
```

Then open a new terminal. That's it.

The script:

- installs fastfetch, python and pipewire with pacman if you don't have them yet (it'll ask for your password for that)
- copies `spinning_logo.py` and `spin.wav` into `~/.config/fastfetch/`
- adds a small `fastfetch` function to your shell so typing `fastfetch` gives you the spinning version. It works with fish, bash and zsh
- makes fastfetch run every time you open a terminal

Running it again is fine, it won't add things twice.

If you only want it when you type `fastfetch` yourself and not on every new terminal:

```bash
./install.sh --no-autostart
```

## Making it yours

**Color.** It's Arch blue by default. To change it, put an RGB color in `~/.config/fastfetch/logo-color`, like this:

```bash
echo "255;255;255" > ~/.config/fastfetch/logo-color
```

That one makes it white. The format is `red;green;blue`, each from 0 to 255.

**Speed and turns.** Open `~/.config/fastfetch/spinning_logo.py` and look at the top. `TURNS` is how many times it spins and `DURATION` is how long it takes in seconds. `FPS` is how smooth it is.

**Sound.** Swap `~/.config/fastfetch/spin.wav` for any other wav you like. If you want no sound at all, just delete it.

**Other logos.** It spins whatever logo your fastfetch config uses, so if you set a different one in fastfetch it'll spin that instead.

## Something's off?

- **It doesn't spin, it just shows normal fastfetch.** Your terminal is probably too small for the logo. Make the window a bit bigger. It falls back to plain fastfetch on purpose so it never looks broken.
- **I see fastfetch twice when I open a terminal.** Your shell config already had a `fastfetch` line in it. The installer warns you about this. Just delete your old line from `~/.bashrc` or `~/.zshrc`.
- **No sound.** Check that `pw-play` works (`pw-play ~/.config/fastfetch/spin.wav`). If it plays there, it'll play in the spin too.
- **Passing options like `fastfetch --logo small`.** Anything with options goes straight to the normal fastfetch, the spin only happens when you run it without any.

## Uninstall

```bash
./install.sh --uninstall
```

This removes the script, the sound and the shell hooks. Your fastfetch config is never touched.
