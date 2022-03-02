{ config, pkgs, ... }:

{
  programs.fish.functions = {
    set-shell-colors = {
      body = ''
        # Use correct theme for `btm`
#        if test "$term_background" = light
#          alias btm "btm --color default-light"
#        else
#          alias btm "btm --color default"
#        end
#        # Set LS_COLORS
#        set -xg LS_COLORS (${pkgs.vivid}/bin/vivid generate solarized-$term_background)
        # Set color variables
        if test "$term_background" = light
          set emphasized_text  brgreen  # base01
          set normal_text      bryellow # base00
          set secondary_text   brcyan   # base1
          set background_light white    # base2
          set background       brwhite  # base3
        else
          set emphasized_text  brcyan   # base1
          set normal_text      brblue   # base0
          set secondary_text   brgreen  # base01
          set background_light black    # base02
          set background       brblack  # base03
        end
        # Set Fish colors that change when background changes
        set -g fish_color_command                    $emphasized_text --bold  # color of commands
        set -g fish_color_param                      $normal_text             # color of regular command parameters
        set -g fish_color_comment                    $secondary_text          # color of comments
        set -g fish_color_autosuggestion             $secondary_text          # color of autosuggestions
        set -g fish_pager_color_prefix               $emphasized_text --bold  # color of the pager prefix string
        set -g fish_pager_color_description          $selection_text          # color of the completion description
        set -g fish_pager_color_selected_prefix      $background
        set -g fish_pager_color_selected_completion  $background
        set -g fish_pager_color_selected_description $background
      '';
      onVariable = "term_background";
    };

    play = {
      body = ''
        switch $argv
          case 'eve'
            WINEPREFIX=$HOME/Games/eve-online/ wine64 Games/eve-online/drive_c/EVE/eve.exe
          case 'wow'
            WINEPREFIX=$HOME/Games/WoW/ wine64 $HOME/Games/WoW/drive_c/Program\ Files\ \(x86\)/Battle.net/Battle.net\ Launcher.exe
          end
      '';
    };
    # }}}
 };
}
