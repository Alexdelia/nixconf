{
  pkgs,
  inputs,
}:
with pkgs.vimPlugins; [
  ## non-lsp info
  nvim-web-devicons
  {
    plugin = nvim-notify;
    type = "lua";
    config = builtins.readFile ./notify.lua;
  }
  {
    plugin = gitsigns-nvim;
    type = "lua";
    config = builtins.readFile ./git.lua;
  }
  {
    plugin = nvim-colorizer-lua;
    type = "lua";
    config = builtins.readFile ./colorizer.lua;
  }
  {
    plugin = bufferline-nvim;
    type = "lua";
    config = builtins.readFile ./bufferline.lua;
  }

  ## colorscheme
  {
    plugin = pkgs.vimUtils.buildVimPlugin {
      name = "vity";
      src = inputs.vity-nvim.packages.${pkgs.system}.default;
    };
    type = "lua";
    config = builtins.readFile ./colorscheme.lua;
  }

  ## lsp
  {
    plugin = nvim-lspconfig;
    type = "lua";
    config = builtins.readFile ./lsp.lua;
  }
  neodev-nvim
  {
    plugin = crates-nvim;
    type = "lua";
    config = "require('crates').setup()";
  }

  ## tree sitter
  {
    plugin = nvim-treesitter.withPlugins (p: [
      # supported language: https://github.com/nvim-treesitter/nvim-treesitter?tab=readme-ov-file#supported-languages

      ### rust
      p.tree-sitter-rust
      p.tree-sitter-toml

      ### dev env
      p.tree-sitter-bash
      p.tree-sitter-nix
      p.tree-sitter-vim
      p.tree-sitter-lua
      p.tree-sitter-csv
      p.tree-sitter-yaml
      p.tree-sitter-ron
      p.tree-sitter-diff
      p.tree-sitter-gitattributes
      p.tree-sitter-gitignore
      p.tree-sitter-regex

      ### c/c++
      p.tree-sitter-c
      p.tree-sitter-cpp
      p.tree-sitter-make

      ### python
      p.tree-sitter-python

      ### go
      p.tree-sitter-go
      p.tree-sitter-gomod
      p.tree-sitter-gosum

      ### web
      p.tree-sitter-typescript
      p.tree-sitter-javascript
      p.tree-sitter-tsx
      p.tree-sitter-vue
      p.tree-sitter-json
      p.tree-sitter-html
      p.tree-sitter-css
      p.tree-sitter-scss
      p.tree-sitter-sql
      p.tree-sitter-http

      ### esoteric and unusual
      p.tree-sitter-yuck
    ]);
    type = "lua";
    config = builtins.readFile ./treesitter.lua;
  }

  ## completion
  {
    plugin = nvim-cmp;
    type = "lua";
    config = builtins.readFile ./cmp.lua;
  }
  cmp-nvim-lsp
  cmp-path
  cmp-buffer
  {
    plugin = copilot-vim;
    type = "lua";
    config = builtins.readFile ./copilot.lua;
  }
  luasnip

  ## motion
  {
    plugin = telescope-nvim;
    type = "lua";
    config = builtins.readFile ./telescope.lua;
  }
  telescope-fzf-native-nvim

  {
    plugin = nvim-tree-lua;
    type = "lua";
    config = builtins.readFile ./file_tree.lua;
  }

  ## edit
  {
    plugin = comment-nvim;
    type = "lua";
    config = builtins.readFile ./comment.lua;
  }
  nvim-ts-context-commentstring
  {
    plugin = rust-vim;
    type = "lua";
    config = "vim.g.rustfmt_autosave = 1";
  }
  {
    plugin = pkgs.vimUtils.buildVimPlugin {
      name = "42Header";
      src = pkgs.fetchFromGitHub {
        owner = "42Paris";
        repo = "42header";
        rev = "master";
        sha256 = "sha256-T4BdswmjlrR3KG+97mzncuJ/1OAvx7GDwXW6MI5fBNE=";
      };
    };
    type = "lua";
    config = let
      login = "adelille";
    in
      /*
      lua
      */
      ''
        vim.g.user42 = '${login}'
        vim.g.mail42 = '${login}@student.42.fr'
      '';
  }

  ## external
  vim-wakatime
]
