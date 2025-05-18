{ pkgs ? import <nixpkgs> {} }:

let
  # Create a wrapper script with comprehensive library paths
  flutterWrapper = pkgs.writeShellScriptBin "fenv" ''
    # Set comprehensive library paths
    export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath [
      pkgs.zlib 
      pkgs.libepoxy
      pkgs.fontconfig
      pkgs.freetype
      pkgs.libGL
      pkgs.mesa
      pkgs.vulkan-loader
      pkgs.dbus
      pkgs.glib
      pkgs.gtk3
      pkgs.gtk3.dev
      pkgs.pango
      pkgs.cairo
      pkgs.harfbuzz
      pkgs.libxkbcommon
    ]}:$LD_LIBRARY_PATH"
    
    # Set proper GTK environment
    export XDG_DATA_DIRS="${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}:$XDG_DATA_DIRS"

    # Execute the command
    exec "$@"
  '';
in
(pkgs.buildFHSUserEnv {
  name = "flutter-env";
  targetPkgs = pkgs: with pkgs; [
    # Development tools
    go
    wget
    git
    clang
    ninja
    cmake
    python3 
    python3Packages.pip
    pkg-config
    patchelf

    # System libraries and dev packages
    zlib zlib.dev
    fontconfig fontconfig.dev
    freetype freetype.dev
    libepoxy
    libGL
    libsysprof-capture
    libidn2 libidn2.dev

    # GTK and dependencies
    gtk3 gtk3.dev
    glib glib.dev
    pango pango.dev
    cairo cairo.dev
    gdk-pixbuf gdk-pixbuf.dev
    atk atk.dev

    # X11 related
    xorg.libX11 xorg.libX11.dev
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXi
    xorg.libXinerama
    xorg.libXrender
    xorg.libXext
    xorg.libXfixes
    xorg.libXdamage
    xorg.libXcomposite
    xorg.libXtst
    xorg.libXdmcp xorg.libXdmcp.dev
    xorg.xorgproto

    # Sound and multimedia
    alsa-lib
    libpulseaudio

    # System and utility libraries
    bzip2.dev
    readline.dev
    openssl.dev
    sqlite.dev
    xz.dev
    curl
    curl.dev
    libffi.dev
    jq
    which
    ncurses5
    dbus
    expat
    libuuid
    at-spi2-core
    cups
    pcre
    harfbuzz
    harfbuzz.dev
    util-linux

    # Runtime environment
    gsettings-desktop-schemas
    shared-mime-info
    hicolor-icon-theme
    gnome.adwaita-icon-theme
    mesa
    mesa.drivers
    vulkan-loader

    # Tools
    unzip
    bash

    # Wrapper script
    flutterWrapper
  ];
 
  profile = ''
    # Set up go environment
    export GOPATH=$HOME/go
    export PATH=$PATH:$GOPATH/bin:${flutterWrapper}/bin

    # Set PKG_CONFIG_PATH for GTK detection
    export PKG_CONFIG_PATH="${pkgs.harfbuzz.dev}/lib/pkgconfig:${pkgs.pango.dev}/lib/pkgconfig:${pkgs.cairo.dev}/lib/pkgconfig:${pkgs.glib.dev}/lib/pkgconfig:${pkgs.gtk3.dev}/lib/pkgconfig:$PKG_CONFIG_PATH"

    # Add all required libraries to PKG_CONFIG_PATH
export PKG_CONFIG_PATH="${pkgs.libidn2.dev}/lib/pkgconfig:${pkgs.harfbuzz.dev}/lib/pkgconfig:${pkgs.pango.dev}/lib/pkgconfig:${pkgs.cairo.dev}/lib/pkgconfig:${pkgs.glib.dev}/lib/pkgconfig:${pkgs.gtk3.dev}/lib/pkgconfig:${pkgs.xorg.libXdmcp.dev}/lib/pkgconfig:$PKG_CONFIG_PATH"

    # Add X11 libraries to PKG_CONFIG_PATH  
export PKG_CONFIG_PATH="${pkgs.xorg.libX11.dev}/lib/pkgconfig:${pkgs.xorg.xorgproto}/lib/pkgconfig:$PKG_CONFIG_PATH"

    # First install asdf via Go if needed
    if ! [ -d $HOME/.asdf ]; then
      echo "Setting up asdf..."
      go install github.com/asdf-vm/asdf/cmd/asdf@v0.16.0
      mkdir -p $HOME/.asdf
      $GOPATH/bin/asdf setup
    fi
    
    # Source asdf scripts
    if [ -f $HOME/.asdf/asdf.sh ]; then
      . $HOME/.asdf/asdf.sh
      [ -f $HOME/.asdf/completions/asdf.bash ] && . $HOME/.asdf/completions/asdf.bash
      echo "asdf configuration sourced successfully"
    else
      echo "Warning: asdf configuration files not found at $HOME/.asdf/"
      echo "You may need to run 'asdf setup' manually"
    fi
    
    # Add asdf shims to PATH explicitly
    export PATH="$HOME/.asdf/shims:$PATH"
    
    echo "FHS environment initialized with Flutter support."
    echo "When running your app, use flutter-run to set proper environment:"
    echo "  fenv flutter run"
    echo -e "\033[1;34m===== FLUTTER FHS ENVIRONMENT ACTIVE =====\033[0m"

    git_branch() {
      git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
    }

    export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] \[\033[01;33m\]$(git_branch)\[\033[00m\]\$ '
  '';
  runScript = "bash";
}).env
