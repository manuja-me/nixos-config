let
  variables = import ./../../../variables.nix;
  colors = variables.colors.active;
in
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;

    plugins = with pkgs.vimPlugins; [
      # Theme
      gruvbox-nvim
      
      # Basic LazyVim-like setup
      plenary-nvim
      nvim-lspconfig
      telescope-nvim
      nvim-treesitter
      which-key-nvim
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      luasnip
      
      # GitHub Copilot
      copilot-vim
    ];

    extraConfig = ''
      " Basic settings
      set number
      set relativenumber
      set mouse=a
      set undofile
      set ignorecase
      set smartcase
      set expandtab
      set shiftwidth=2
      set tabstop=2
      set clipboard=unnamedplus
      set breakindent
      set signcolumn=yes
      
      " Gruvbox Theme
      set background=dark
      let g:gruvbox_contrast_dark = 'medium'
      let g:gruvbox_sign_column = 'bg0'
      let g:gruvbox_invert_selection = 0
      colorscheme gruvbox
      
      " LazyVim-style keybindings
      let mapleader = " "
      let maplocalleader = ","
      
      " Better window navigation
      nnoremap <C-h> <C-w>h
      nnoremap <C-j> <C-w>j
      nnoremap <C-k> <C-w>k
      nnoremap <C-l> <C-w>l
      
      " Better indenting
      vnoremap < <gv
      vnoremap > >gv
      
      " Move selected line / block of text in visual mode
      xnoremap K :move '<-2<CR>gv-gv
      xnoremap J :move '>+1<CR>gv-gv
      
      " Telescope (fuzzy finder)
      nnoremap <leader>ff <cmd>Telescope find_files<cr>
      nnoremap <leader>fg <cmd>Telescope live_grep<cr>
      nnoremap <leader>fb <cmd>Telescope buffers<cr>
      nnoremap <leader>fh <cmd>Telescope help_tags<cr>
      
      " LSP mappings (mimic LazyVim)
      nnoremap gD <cmd>lua vim.lsp.buf.declaration()<CR>
      nnoremap gd <cmd>lua vim.lsp.buf.definition()<CR>
      nnoremap K <cmd>lua vim.lsp.buf.hover()<CR>
      nnoremap gi <cmd>lua vim.lsp.buf.implementation()<CR>
      nnoremap <leader>rn <cmd>lua vim.lsp.buf.rename()<CR>
      nnoremap <leader>ca <cmd>lua vim.lsp.buf.code_action()<CR>
      
      " GitHub Copilot setup
      let g:copilot_enabled = 1
      let g:copilot_no_tab_map = v:true
      imap <silent><script><expr> <C-J> copilot#Accept()
      
      " Lua configuration for more LazyVim-like setup
      lua << EOF
      -- LSP setup
      require('lspconfig').pyright.setup{}
      require('lspconfig').tsserver.setup{}
      require('lspconfig').rust_analyzer.setup{}
      
      -- Add Nix LSP support
      require('lspconfig').nil_ls.setup{
        autostart = true,
        settings = {
          ['nil'] = {
            formatting = {
              command = { "nixpkgs-fmt" },
            },
          },
        },
      }
      
      -- Add C/C++ LSP support
      require('lspconfig').clangd.setup{
        cmd = { "clangd", "--background-index" },
        root_dir = require('lspconfig').util.root_pattern(
          '.clangd',
          '.clang-tidy',
          '.clang-format',
          'compile_commands.json',
          'compile_flags.txt',
          'configure.ac',
          '.git'
        ),
        filetypes = { "c", "cpp", "objc", "objcpp" },
      }
      
      -- Treesitter
      require('nvim-treesitter.configs').setup {
        ensure_installed = { "lua", "rust", "python", "typescript", "javascript", "nix", "c" },
        highlight = {
          enable = true,
        },
      }
      
      -- WhichKey for LazyVim-like keybinding visualization
      require('which-key').setup {
        plugins = {
          marks = true,
          registers = true,
        },
        window = {
          border = "single",
        },
      }
      
      -- Completion setup
      local cmp = require('cmp')
      cmp.setup({
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
        }, {
          { name = 'buffer' },
          { name = 'path' },
        })
      })
      EOF
    '';

    extraPackages = with pkgs; [
      # Language servers and tools
      nodePackages.pyright
      nodePackages.typescript-language-server
      rust-analyzer
      ripgrep
      fd
      
      # Add Nix language server
      nil
      nixpkgs-fmt
      
      # Add C language server
      clang-tools # Provides clangd
    ];
  };
}
