{ config, pkgs, lib, myNvim, ... }:
{
  home = {
    username = "anthony";
    homeDirectory = "/home/anthony";
    stateVersion = "22.11";
    packages = with pkgs; [
      myNvim
      zathura
    ];
  };
  programs = {
    git = {
      enable = true;
      userName = "anthonymarkreynolds";
      userEmail = "anthonymarkreynolds@outlook.com";
    };
    zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableSyntaxHighlighting = true;
      defaultKeymap = "viins";
      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "vi-mode"
          "colored-man-pages"
          "extract"
        ];
      };
      initExtraBeforeCompInit = ''
        # p10k instant prompt
        P10K_INSTANT_PROMPT="$XDG_CACHE_HOME/p10k-instant-prompt-''${(%):-%n}.zsh"
        [[ ! -r "$P10K_INSTANT_PROMPT" ]] || source "$P10K_INSTANT_PROMPT"
      '';
    };
    alacritty = {
      enable = true;
      settings = {
        font = {
          size = 9.0;
          normal = {
            family = "monospace";
            style = "Regular";
          };
          bold = {
            family = "monospace";
            style = "Bold";
          };
          italic = {
            family = "monospace";
            style = "Italic";
          };
          bold_italic = {
            family = "monospace";
            style = "Bold Italic";
          };
        };

        colors = {
          primary = {
            background = "#17101d";
          };
        };
        window = {
          padding.x = 8;
          padding.y = 8;
          dynamic_padding = true;
        };
      };
    };
  };
}
