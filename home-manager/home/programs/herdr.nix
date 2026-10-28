{ pkgs, ... }:

# Herdr has no upstream Home Manager module, so we render its config file
# (~/.config/herdr/config.toml) declaratively. This is a module (wired via
# `imports` in ../default.nix), not a `programs.<name>` entry.
#
# The file becomes a read-only symlink into the Nix store, so edit it here and
# re-run `home-manager switch`, then `herdr server reload-config` to apply to a
# running server.
{
  xdg.configFile."herdr/config.toml".source =
    (pkgs.formats.toml { }).generate "herdr-config.toml" {
      keys = {
        # Herdr's default prefix is "ctrl+b". Declared explicitly here so it is
        # managed declaratively; change and re-switch to take effect.
        prefix = "ctrl+a";

        # Tabs within a workspace (these match Herdr's defaults; declared
        # explicitly so the whole tab story lives here).
        next_tab = "prefix+n";
        previous_tab = "prefix+p";
        switch_tab = "prefix+1..9"; # prefix+1 .. prefix+9 jump to tab N

        # Switch between agents. These are UNSET by default in Herdr, so these
        # lines actually add new behaviour. Plain arrows after the prefix are
        # unbound by default and delivered reliably (down = next, up = prev,
        # matching the sidebar's top-to-bottom order).
        next_agent = "prefix+down";
        previous_agent = "prefix+up";
        focus_agent = "prefix+alt+1..9"; # prefix+alt+N focuses the Nth agent

        # Switch between spaces (workspaces). Also UNSET by default in Herdr.
        # Horizontal arrows mirror the vertical agent arrows above, and
        # switch_workspace mirrors switch_tab (shift makes it "the workspace
        # layer" of the number row).
        next_workspace = "prefix+right";
        previous_workspace = "prefix+left";
        switch_workspace = "prefix+shift+1..9"; # prefix+shift+N jump to workspace N

        # Split the focused pane. These match Herdr's defaults; declared
        # explicitly so the whole pane story lives here. split_vertical stacks
        # the new pane to the right (vertical divider); split_horizontal stacks
        # it below (horizontal divider, hence "minus").
        split_vertical = "prefix+v";
        split_horizontal = "prefix+minus";

        # Move focus between panes. Also Herdr defaults, declared here. hjkl is
        # used for panes so it stays clear of the arrow keys, which above are
        # reserved for agent (up/down) and workspace (left/right) navigation.
        focus_pane_left = "prefix+h";
        focus_pane_down = "prefix+j";
        focus_pane_up = "prefix+k";
        focus_pane_right = "prefix+l";

        # Close the focused pane (Herdr default).
        close_pane = "prefix+x";
      };
    };
}
