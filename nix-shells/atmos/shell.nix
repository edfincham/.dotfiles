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

    # Set up prompt with git branch information
    git_branch() {
      git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
    }
    
    # Set PS1 to show current directory and git branch
    export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] \[\033[01;33m\]$(git_branch)\[\033[00m\]\$ '
  '';
}
