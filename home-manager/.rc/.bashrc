# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

sd() {
  local filter=${1:-}
  cd ~ && cd "$(find . -maxdepth 6 -type d -not -path "*/.*" -not -path "*/go/*" -not -path "*/node_modules/*" | fzf -q "$filter")"
}

jwtd () {
  if [[ -x $(command -v jq) ]]
  then
    jq -R 'split(".") | .[0],.[1] | @base64d | fromjson' <<< "${1}"
    echo "Signature: $(echo "${1}" | awk -F'.' '{print $3}')"
  fi
}

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Powerline configuration
#   To install run pip3 install powerline-status
#   Clone https://github.com/powerline/fonts and run ./install.sh
if [ -f $HOME/.local/lib/python3.8/site-packages/powerline/bindings/bash/powerline.sh ]; then
    $HOME/.local/bin/powerline-daemon -q
    POWERLINE_BASH_CONTINUATION=1
    POWERLINE_BASH_SELECT=1
    source $HOME/.local/lib/python3.8/site-packages/powerline/bindings/bash/powerline.sh
fi

export PATH=$PATH:/usr/local/go/bin

. ~/.dotfiles/home-manager/.rc/.history_conf
. ~/.dotfiles/home-manager/.rc/.bash_aliases
. ~/.dotfiles/home-manager/.rc/.lazykube
. ~/Dropbox/synced_documents/computer_setup/.bashrc_dropbox
