{ config, lib, pkgs, ... }:
let
  paths = ''
    export PATH="$HOME/.cabal/bin:$PATH"
    export PATH="$HOME/.cargo/bin:$PATH"
    export PATH="$HOME/.emacs.d/bin:$PATH"
    export PATH="$HOME/.local/bin:$PATH"
    export PATH="$HOME/bin:$PATH"
    export PATH="/usr/local/bin:$PATH"
  '';
in
{
  ".zshrc".text = ''
    export NIX_PATH=$HOME/.nix-defexpr/channels\$\{NIX_PATH:+:}$NIX_PATH

    ${paths}

    if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then
      . $HOME/.nix-profile/etc/profile.d/nix.sh;
    fi # added by Nix installer
  '';

  ".bash_profile".text = ''
    export EDITOR=emacsclient
    export GIT_EDITOR=$EDITOR

    alias lock=/System/Library/Frameworks/ScreenSaver.framework/Versions/Current/Resources/ScreenSaverEngine.app/Contents/MacOS/ScreenSaverEngine

    ${paths}

    export LANG=en_US.UTF-8

    shopt -s extglob

    export HISTCONTROL=erasedups
    export HISTSIZE=10000
    shopt -s histappend

    do_command_done_alert() {
        osascript -e 'display dialog "Command Done!"'
    }

    alert_when_done() {
        if test -n "$1";
        then
            while kill -0 $1
            do
                sleep 1
            done
        fi
        do_command_done_alert
    }

    export NIX_PATH=$HOME/.nix-defexpr/channels\$\{NIX_PATH:+:}$NIX_PATH

    if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then
      . $HOME/.nix-profile/etc/profile.d/nix.sh;
    fi # added by Nix installer
  '';
}
