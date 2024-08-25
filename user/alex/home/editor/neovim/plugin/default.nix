{pkgs, inputs}:
with pkgs.vimPlugins; [
  ## colorscheme
  {
    plugin = pkgs.vimUtils.buildVimPlugin {
	  name = "vity";
	  src = inputs.vity-nvim;
	};
	config = "colorscheme vity";
  }

  ## lsp
  {
    plugin = nvim-lspconfig;
    type = "lua";
    config = builtins.readFile ./lsp.lua;
  }
  neodev-nvim
  # TODO: crates.nvim https://github.com/saecki/crates.nvim

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
      p.tree-sitter-diff
      p.tree-sitter-gitattributes
      p.tree-sitter-gitignore
      p.tree-sitter-regex

      ### c
      p.tree-sitter-c
      p.tree-sitter-make

      ### python
      p.tree-sitter-python

      ### web
      p.tree-sitter-typescript
      p.tree-sitter-javascript
      p.tree-sitter-tsx
      p.tree-sitter-vue
      p.tree-sitter-json
      p.tree-sitter-html
      p.tree-sitter-css
      # p.tree-sitter-scss
      p.tree-sitter-sql
      p.tree-sitter-http
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
  copilot-vim
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

  ## non-lsp info
  {
    plugin = gitsigns-nvim;
    type = "lua";
    config = builtins.readFile ./git.lua;
  }
  {
    plugin = nvim-notify;
    type = "lua";
    config = builtins.readFile ./notify.lua;
  }
  nvim-web-devicons

  ## external
  vim-wakatime
]
