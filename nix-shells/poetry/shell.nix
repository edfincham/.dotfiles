{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/master.tar.gz") {} }:
let
  # Get the latest Poetry from pip
  pythonEnv = pkgs.python312.withPackages (ps: with ps; [
    pip
    virtualenv
  ]);

  poetryInstaller = pkgs.writeShellScriptBin "install-poetry" ''
    # Create a permanent directory for installing Poetry
    POETRY_DIR="$HOME/.nix-poetry"
    mkdir -p "$POETRY_DIR"

    # Setup a virtual environment for Poetry
    ${pythonEnv}/bin/python -m virtualenv "$POETRY_DIR/venv"

    # Install the latest Poetry in the virtual environment
    "$POETRY_DIR/venv/bin/pip" install poetry

    # Create a symlink to the poetry executable
    mkdir -p "$HOME/.local/bin"
    ln -sf "$POETRY_DIR/venv/bin/poetry" "$HOME/.local/bin/nix-poetry"

    # Return the path to the symlink
    echo "$HOME/.local/bin/nix-poetry"
  '';

# Create a custom Poetry wrapper
  customPoetry = pkgs.writeShellScriptBin "poetry" ''
    # Path to the Poetry executable
    POETRY_EXEC="$HOME/.local/bin/nix-poetry"

    # Check if we need to install Poetry
    if [ ! -x "$POETRY_EXEC" ]; then
      echo "Installing the latest version of Poetry..."
      ${poetryInstaller}/bin/install-poetry > /dev/null
    fi

    # Python packages come pre-built and sometimes assume there are c libraries available
    export LD_LIBRARY_PATH=${pkgs.stdenv.cc.cc.lib}/lib/
    export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath [ pkgs.zlib ]}:$LD_LIBRARY_PATH"

    # Execute Poetry from the symlink
    exec "$POETRY_EXEC" "$@"
  '';

in
pkgs.mkShell {
  buildInputs = with pkgs; [
    # Use custom poetry wrapper instead of the regular one
    customPoetry
    poetryInstaller

    # Basic build tools
    gcc
    glibc
    glibc.dev
    gnumake
    ninja
    pkg-config
    
    # Python 
    python312
    
    # Scientific libraries needed for numpy and other scientific packages
    openblas
    gfortran
    
    # Additional libraries that might be needed
    zlib
    stdenv.cc.cc.lib

    # Basic build tools
    gcc
    gnumake
    ninja
    pkg-config
    
    # Python and dependencies
    pythonEnv

    # Scientific libraries
    gfortran      # Fortran compiler for scientific packages
    openblas      # Optimized BLAS implementation
  ];
 
  shellHook = ''
    # Make sure the C compiler can find the necessary headers
    export NIX_CFLAGS_COMPILE="-isystem ${pkgs.glibc.dev}/include $NIX_CFLAGS_COMPILE"
    export C_INCLUDE_PATH="${pkgs.glibc.dev}/include:$C_INCLUDE_PATH"
    export CPLUS_INCLUDE_PATH="${pkgs.glibc.dev}/include:${pkgs.gcc.cc}/include/c++/${pkgs.lib.getVersion pkgs.gcc.cc}:$CPLUS_INCLUDE_PATH"
    
    # You might not need these since customPoetry already sets LD_LIBRARY_PATH
    export LIBRARY_PATH="${pkgs.glibc}/lib:$LIBRARY_PATH"
    
    echo "Python development environment activated."
    echo "Poetry version: $(poetry --version 2>/dev/null || echo "Not yet installed - will be installed on first use")"
    echo "Use 'poetry install' to install dependencies."

    git_branch() {
      git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
    }
    export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] \[\033[01;33m\]$(git_branch)\[\033[00m\]\$ '
  '';
}
