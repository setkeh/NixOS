{config, pkgs, lib, ...}:
{
  programs.tmux = {
    enable = true;
    extraConfig = ''
      set-option -g default-shell "${pkgs.fish}/bin/fish"
      set-option -g status on
      set-option -g status-interval 1
      set-option -g status-justify centre
      set-option -g status-keys vi
      set-option -g status-position bottom
      set-option -g status-style fg=colour136,bg=colour235
      set-option -g status-left-length 440
      set-option -g status-left-style default
      set-option -g status-left "\
      #[fg=green]#H #[fg=black]• #[fg=green,bright]#(uname -r)#[default] \
      #[fg=white]• #[fg=green,bright]WIFI: #(nmcli -f NAME c | tail -n +2 | head -n 1 | xargs)#[default]#[fg=green,bright] \
      #[fg=white]• #[fg=green,bright]LOAD: #(cat /proc/loadavg | cut -f 1-3 -d $' ')#[default]#[fg=green,bright] \
      #[fg=white]• #[fg=green,bright]RAM: #(~/.config/home-manager/dotfiles/slstatus/ram.sh)#[default]#[fg=green,bright] \
      #[fg=white]• #[fg=green,bright]BATT: #(~/.config/home-manager/dotfiles/slstatus/battery_charge.sh)#[default]#[fg=green,bright]"
      set-option -g status-right-length 140
      set-option -g status-right-style default
      set-option -g status-right "\
      #[fg=green,bg=default,bright]#(tmux-mem-cpu-load) \
      #[fg=red,dim,bg=default]UP #(uptime | awk -F'up |,' '{print $2}') \
      #[fg=white,bg=default]%a %l:%M:%S %p#[default] #[fg=blue]%Y-%m-%d"
      set-window-option -g window-status-style fg=colour244
      set-window-option -g window-status-style bg=default
      set-window-option -g window-status-current-style fg=colour166
      set-window-option -g window-status-current-style bg=default
    '';
  };
}