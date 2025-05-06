# Snacks is a generalized plugin that replaces a bunch of plugins
# This module maintains toggles for these features.
# https://github.com/folke/snacks.nvim
{
  config = {
    plugins.snacks = {
      enable = true;
      settings = {
        explorer.enabled = true;
        indent.enabled = true;
        input.enabled = true;
        notifier.enabled = true;
        picker.enabled = true;
      };
    };
    userCommands = {
      "Snacks" = {
        command.__raw = ''function() require('snacks').picker.pickers() end'';
        desc = "Snack pickers picker";
      };
      "GitBrowse" = {
        command.__raw = ''function() require('snacks').gitbrowse() end'';
        desc = "Open git repo in browser";
      };
      "Terminal" = {
        command.__raw = ''function() require('snacks').terminal() end'';
        desc = "Open Terminal";
      };
      "Rename" = {
        command.__raw = ''function() require('snacks').rename.rename_file() end'';
        desc = "Rename file";
      };
    };
    keymaps = [
      { key = "<C-space>";
        action.__raw = ''function() require('snacks').picker.smart() end'';
        options.desc = "Smart file picker";
      }
      { key = "<C-p>";
        action.__raw = ''function() require('snacks').picker.git_files() end'';
        options.desc = "Search in git repo";
      }
      { key = "<C-d>";
        action.__raw = ''function() require('snacks').picker.files() end'';
        options.desc = "Search files";
      }
      { key = "<C-s>";
        action.__raw = ''function() require('snacks').picker.grep() end'';
        options.desc = "Search contents";
      }
      { key = "<C-b>";
        action.__raw = ''function() require('snacks').picker.buffers() end'';
        options.desc = "Search buffers";
      }
      { key = "<C-n>";
        action.__raw = ''function() require('snacks').picker.notifications() end'';
        options.desc = "Search notifications";
      }
      { key = "<C-c>";
        action.__raw = ''function() require('snacks').picker.commands() end'';
        options.desc = "Search commands and pickers";
      }
      { key = "<leader>u";
        action.__raw = ''function() require('snacks').picker.undo() end'';
        options.desc = "Undo";
      }
      { key = "<leader>z";
        action.__raw = ''function() require('snacks').zen() end'';
        options.desc = "Zen mode";
      }
      { key = "<C-`>";
        action.__raw = ''function() require('snacks').terminal() end'';
        options.desc = "Toggle terminal";
        mode = ["n" "v" "t" "i"];
      }
    ];
  };
}
