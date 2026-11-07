-- REVERIE: frosted glass, silver frames, and soft motion.
--
-- This file is the "look and motion" half of the theme; colors.toml is the color
-- half. Omarchy skips it for themes installed with `omarchy theme install` (any
-- theme folder with a .git directory), so see the README to enable it.
-- Your own ~/.config/hypr/looknfeel.lua and Omarchy's look toggles load after
-- this file, so anything they set wins over what's here.
--
-- Change a number, run `omarchy theme set reverie`, and see what happens.
-- Options: https://wiki.hypr.land/configuring/core/config-options/
-- Motion:  https://wiki.hypr.land/configuring/core/animations/

-- 1. SHAPE AND GLASS ---------------------------------------------------------

local active_border = { colors = { "rgba(e6e5e6cc)", "rgba(c1bec1cc)" }, angle = 45 }
local inactive_border = "rgba(ffffff14)"

hl.config({
  general = {
    gaps_in = 4,
    gaps_out = 8,
    border_size = 2,
    col = { active_border = active_border, inactive_border = inactive_border },
  },

  group = {
    col = { border_active = active_border, border_inactive = inactive_border },
  },

  decoration = {
    rounding = 23,
    rounding_power = 4.0, -- 2 is a circle, 4 is a soft Apple-style squircle.
    dim_special = 0.15,   -- Darkens the desktop behind the scratchpad and quake terminal.

    shadow = {
      enabled = true,
      range = 24,
      render_power = 2,
      color = "rgba(05060dcc)",
    },

    -- A soft colored halo. Try range = 30 for a neon look.
    glow = {
      enabled = true,
      range = 22,
      render_power = 4,
      color = "rgba(5eead422)",
      color_inactive = "rgba(00000000)",
    },

    -- Blur only shows through see-through surfaces, so it works with section 2.
    -- Matches Omarchy's Glassy bar blur (default/hypr/glass.lua), so Reverie
    -- looks the same whether that toggle is on or off.
    blur = {
      enabled = true,
      size = 4,              -- How far each pass spreads.
      passes = 2,            -- More is smoother and costs more GPU.
      noise = 0.01,          -- Grain, which makes it feel like frosted glass.
      contrast = 1.0,
      brightness = 0.75,     -- Darker glass keeps text readable on bright wallpapers.
      vibrancy = 0.35,       -- Boosts the wallpaper's color through the glass.
      vibrancy_darkness = 0.35,
      new_optimizations = true,
      xray = false,
      ignore_opacity = true,
      popups = true,          -- Right-click menus too.
      special = true,         -- Blur behind the scratchpad and quake terminal (GPU-hungry).
    },
  },
})

-- 2. WHAT IS SEE-THROUGH -----------------------------------------------------
-- "active inactive" opacity. Browsers, video and games opt out through Omarchy's
-- own rules, so only windows still tagged default-opacity are affected here.

o.window({ tag = "default-opacity" }, { opacity = "0.96 0.84" })
o.window({ tag = "terminal" }, { opacity = "0.84 0.74" })

-- Layers are things that aren't windows: bar, menus, notifications. List them
-- with `hyprctl layers`. Their see-through amount is background-alpha in the
-- shell.*.toml files next to this one.
hl.layer_rule({
  match = { namespace = "^(omarchy-bar|omarchy-menu|omarchy-notifications|omarchy-osd|omarchy-polkit|omarchy-reminders|omarchy-clipboard|omarchy-emojis|omarchy-image-selector|omarchy-keyboard-panel|omarchy-network-qr)$" },
  blur = true,
  ignore_alpha = 0.3,
})

-- Omarchy pins its menu to no animation; this gives it a fade.
hl.layer_rule({ match = { namespace = "omarchy-menu" }, no_anim = false, animation = "fade" })

-- 3. CURVES: the *feel* of motion --------------------------------------------
-- Declare a curve before any animation that names it.
-- Bezier: two control points. Design your own at https://www.cssportal.com/css-cubic-bezier-generator/
-- Spring: physics. Lower dampening is bouncier, higher stiffness is snappier.
-- (The wiki says "damping", but Hyprland 0.56 only accepts "dampening".)

hl.curve("glassOut", { type = "bezier", points = { { 0.16, 1 }, { 0.3, 1 } } })
hl.curve("glassIn", { type = "bezier", points = { { 0.7, 0 }, { 0.84, 0 } } })
hl.curve("settle", { type = "spring", mass = 1, stiffness = 400, dampening = 29 })
hl.curve("menu_decel", { type = "bezier", points = { { 0.05, 1 }, { 0, 1 } } })

-- 4. ANIMATIONS: what moves, and how -----------------------------------------
-- speed is in tenths of a second: 3 means 300ms. Springs mostly ignore it,
-- because the physics decide how long they take.

-- Super + 1..9. Styles: slide, slidevert, fade, slidefade, slidefadevert.
-- The percentage is how far it travels; try plain "slide" or "fade".
hl.animation({ leaf = "workspaces", enabled = true, speed = 7, bezier = "menu_decel", style = "slide" })

-- Super + S (scratchpad) and Super + ` (quake). They share these two animations,
-- because both are special workspaces. The side names where it enters from.
hl.animation({ leaf = "specialWorkspaceIn", enabled = true, speed = 1, spring = "settle", style = "slide top" })
hl.animation({ leaf = "specialWorkspaceOut", enabled = true, speed = 1, bezier = "glassIn", style = "slide bottom" })

-- Windows opening, closing and rearranging. Styles: slide, popin, gnomed.
hl.animation({ leaf = "windowsIn", enabled = true, speed = 1, spring = "settle", style = "popin 88%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.6, bezier = "glassIn", style = "popin 94%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 3, spring = "settle" })

-- The border gradient sweeps around a window once when it gains focus. The "loop"
-- style spins it forever, but redraws constantly and costs GPU even when idle.
hl.animation({ leaf = "border", enabled = true, speed = 3, bezier = "glassOut" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 30, bezier = "glassOut", style = "once" })

-- 5. EXPERIMENTS: uncomment to try -------------------------------------------

-- Darken the screen edges with a shader that runs on every frame. Screenshots
-- and screen recordings will include it.
-- hl.config({ decoration = { screen_shader = os.getenv("HOME") .. "/.local/state/omarchy/current/theme/shaders/vignette.frag" } })

-- Fade windows you aren't using.
-- hl.config({ decoration = { dim_inactive = true, dim_strength = 0.05 } })
