{
  # It's important to wrap i3 with dbus-launch or else GTK systray icons won't
  # work.
  # TODO: exec xcalib -d :0 "${nixpkgs}/hardware/thinkpad-x1c-hdr.icm"
  home.file.".xinitrc".text = ''
    exec dbus-launch --exit-with-x11 i3
  '';

  home.file.".bash_profile".text = ''
    if [[ -f ~/.bashrc ]] ; then
      . ~/.bashrc
    fi

    if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
      exec ssh-agent startx
    fi
  '';


  xresources.properties = {
    "Xft.dpi" = 140; # = 210 / 1.5
    "Xcursor.size" = 48;
    # "xterm*utf8" = 2;
  };

}
