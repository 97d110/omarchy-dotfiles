-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- ROG Deck: the ASUS control app (profile, power, GPU, fans, lighting).
-- rog-deck-toggle opens it, focuses it if it is already open behind
-- something, and closes it when it already has focus - `summon` alone does
-- nothing on a second press, and plain `toggle` closes a merely unfocused
-- window instead of raising it. On the desktop the plugin is absent and this
-- is a no-op.
o.bind("SUPER + SHIFT + R", "ROG Deck", "rog-deck-toggle")

-- Quick-edit ~/.bashrc in Zed (mirrors the `bashme` shell alias / Omarchy menu entry).
o.bind("SUPER + SHIFT + Z", "Edit .bashrc", { launch = "zed $HOME/.bashrc" })

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD"aslkjdasd asjdklajs dlkajskl jask nil, "omarchy-shell shell toggle omarchy.emojis")
