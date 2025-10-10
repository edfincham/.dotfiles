{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    nodejs_20
  ];

  shellHook = ''
    echo "npm development environment ready!"
    echo "Node.js version: $(node --version)"
    echo "npm version: $(npm --version)"

    # Set npm cache and config directories to avoid global pollution
    export NPM_CONFIG_CACHE=$PWD/.npm-cache
    export NPM_CONFIG_USERCONFIG=$PWD/.npmrc

    git_branch() {
      git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
    }

    export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] \[\033[01;33m\]$(git_branch)\[\033[00m\]\$ '
  '';
}
