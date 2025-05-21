{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    # Core dependencies for asdf
    asdf-vm
    git
    curl
    bash
    # Likely dependencies for atmos
    coreutils
    gnumake
    gcc

    # Dependency for tmcg
    go

    # C development libraries for Go linking
    glibc
    glibc.dev
    stdenv.cc.cc.lib
  ];

  shellHook = ''
    echo "Setting up asdf environment with atmos..."

    # Ensure asdf is initialized
    source ${pkgs.asdf-vm}/share/asdf-vm/asdf.sh

    # Check if atmos plugin is already installed
    if ! asdf plugin list | grep -q "atmos"; then
      echo "Installing atmos plugin..."
      asdf plugin add atmos https://github.com/cloudposse/asdf-atmos.git
    fi

    asdf install atmos latest
    asdf global atmos latest

    # Clone tmcg to a temporary folder
    echo "Cloning tmcg repository to /tmp/tmcg..."
    git clone https://github.com/kbcz1989/tmcg.git /tmp/tmcg
    
    # Build tmcg
    echo "Building tmcg..."
    cd /tmp/tmcg

    # Set CGO flags to use the correct libraries
    export CGO_ENABLED=1
    export CGO_CFLAGS="-I${pkgs.glibc.dev}/include"
    export CGO_LDFLAGS="-L${pkgs.glibc}/lib -L${pkgs.stdenv.cc.cc.lib}/lib"
    export LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib}/lib"
    
    go build -o tmcg ./cmd/tmcg
    
    # Add tmcg to PATH
    export PATH=$PATH:/tmp/tmcg
    
    # Return to original directory
    cd $OLDPWD

    git_branch() {
      git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
    }

    export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] \[\033[01;33m\]$(git_branch)\[\033[00m\]\$ '
  '';
}
