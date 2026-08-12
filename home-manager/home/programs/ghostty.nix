{ pkgs }:
{
  enable = true;
  # installVimSyntax = true;
  # installBatSyntax = true;

  settings = {
    theme = "tokyonight";
    font-size = 13;

    # Window
    window-padding-x = 12;
    window-padding-y = 12;
    window-padding-balance = true;
    window-save-state = "always";
    window-decoration = "none";
    gtk-titlebar = false;
    gtk-tabs-location = "hidden";
    background-opacity = 1.0;

    # Cursor
    cursor-style = "block";
    cursor-style-blink = false;
    shell-integration-features = "cursor,sudo,title";

    # UX
    mouse-hide-while-typing = true;
    copy-on-select = "clipboard";
    confirm-close-surface = false;
    scrollback-limit = 100000;
    app-notifications = "no-clipboard-copy";

    keybind = [
      # Tabs
      "ctrl+shift+t=new_tab"
      "ctrl+shift+w=close_surface"
      "ctrl+tab=next_tab"
      "ctrl+shift+tab=previous_tab"
      "ctrl+shift+a=toggle_tab_overview"

      # Splits (vim-style nav)
      "ctrl+shift+enter=new_split:right"
      "ctrl+shift+o=new_split:down"
      "ctrl+shift+h=goto_split:left"
      "ctrl+shift+j=goto_split:bottom"
      "ctrl+shift+k=goto_split:top"
      "ctrl+shift+l=goto_split:right"

      # Font size
      "ctrl+plus=increase_font_size:1"
      "ctrl+minus=decrease_font_size:1"
      "ctrl+zero=reset_font_size"
    ];
  };
}
