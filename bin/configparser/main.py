from extract_lua import extract_lua
from parser import Parser
from pprint import pprint

def main():

    repos = [
        "0styx0/abbreinder.nvim",
        "Pocco81/AbbrevMan.nvim",
        "roobert/action-hints.nvim",
        "aznhe21/actions-preview.nvim",
        "roobert/activate.nvim",
        "aaronhallaert/advanced-git-search.nvim",
        "Mofiqul/adwaita.nvim",
        "stevearc/aerial.nvim",
        "desdic/agrolens.nvim",
        "yagiziskirik/AirSupport.nvim",
        "goolord/alpha-nvim",
        "anuvyklack/animation.nvim",
        "Olical/aniseed",
        "aPeoplesCalendar/apc.nvim",
        "adisen99/apprentice.nvim",
        "FrenzyExists/aquarium-vim",
        "rockyzhang24/arctic.nvim",
        "jim-at-jibba/ariake-vim-colors",
        "tjdevries/astronauta.nvim:edc19d30a3c51a8c3fc3f606008e5b4238821f1e",
        "skywind3000/asyncrun.vim",
        "sourcehut:henriquehbr/ataraxis.lua",
        "m-demare/attempt.nvim",
        "ray-x/aurora",
        "f-person/auto-dark-mode.nvim",
        "sourcehut:nedia/auto-format.nvim",
        "jghauser/auto-pandoc.nvim",
        "okuuva/auto-save.nvim",
        "sourcehut:nedia/auto-save.nvim::auto-save-nvim-nedia",
        "pocco81/auto-save.nvim::auto-save-nvim-pocco81",
        "rmagatti/auto-session",
        "m4xshen/autoclose.nvim",
        "antonk52/bad-practices.nvim",
        "m00qek/baleia.nvim",
        "ribru17/bamboo.nvim",
        "romgrk/barbar.nvim",
        "utilyre/barbecue.nvim",
        "aliou/bats.vim",
        "max397574/better-escape.nvim",
        "Wansmer/binary-swap.nvim",
        "alanfortlink/blackjack.nvim",
        "kyazdani42/blue-moon",
        "rockerBOO/boo-colorscheme-nvim",
        "crusj/bookmarks.nvim::bookmarks-crusj",
        "tomasky/bookmarks.nvim::bookmarks-tomasky",
        "lstwn/broot.vim",
        "datwaft/bubbly.nvim",
        "famiu/bufdelete.nvim",
        "j-morano/buffer_manager.nvim",
        "roobert/bufferline-cycle-windowless.nvim",
        "akinsho/bufferline.nvim",
        "tomiis4/BufferTabs.nvim",
        "sQVe/bufignore.nvim",
        "numToStr/BufOnly.nvim",
        "dkarter/bullets.vim",
        "yashguptaz/calvera-dark.nvim",
        "ellisonleao/carbon-now.nvim",
        "SidOfc/carbon.nvim",
        "jbyuki/carrot.nvim",
        "Nexmean/caskey.nvim",
        "catppuccin/nvim::catppuccin",
        "uga-rosa/ccc.nvim",
        "ranjithshegde/ccls.nvim",
        "Eandrju/cellular-automaton.nvim",
        "ms-jpq/chadtree",
        "saifulapm/chartoggle.nvim",
        "jackMort/ChatGPT.nvim",
        "sudormrfbin/cheatsheet.nvim",
        "NTBBloodbath/cheovim",
        "skanehira/christmas.vim",
        "declancm/cinnamon.nvim",
        "zootedb0t/citruszest.nvim",
        "p00f/clangd_extensions.nvim",
        "ekickx/clipboard-image.nvim",
        "kazhala/close-buffers.nvim",
        "Civitasv/cmake-tools.nvim",
        "notomo/cmdbuf.nvim",
        "felipelema/cmp-async-path",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-calc",
        "vappolinario/cmp-clippy",
        "hrsh7th/cmp-cmdline",
        "dmitmel/cmp-cmdline-history",
        "davidsierradz/cmp-conventionalcommits",
        "hrsh7th/cmp-copilot",
        "rcarriga/cmp-dap",
        "uga-rosa/cmp-dictionary",
        "dmitmel/cmp-digraphs",
        "hrsh7th/cmp-emoji",
        "mtoohey31/cmp-fish",
        "tzachar/cmp-fuzzy-buffer",
        "tzachar/cmp-fuzzy-path",
        "petertriho/cmp-git",
        "max397574/cmp-greek",
        "kdheepak/cmp-latex-symbols",
        "octaltree/cmp-look",
        "saadparwaiz1/cmp_luasnip",
        "david-kunz/cmp-npm",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-nvim-lsp-document-symbol",
        "hrsh7th/cmp-nvim-lsp-signature-help",
        "hrsh7th/cmp-nvim-lua",
        "quangnguyen30192/cmp-nvim-ultisnips",
        "hrsh7th/cmp-omni",
        "aspeddro/cmp-pandoc.nvim",
        "jc-doyle/cmp-pandoc-references",
        "hrsh7th/cmp-path",
        "lukas-reineke/cmp-rg",
        "dcampos/cmp-snippy",
        "f3fora/cmp-spell",
        "tzachar/cmp-tabnine",
        "andersevenrud/cmp-tmux",
        "ray-x/cmp-treesitter",
        "lukas-reineke/cmp-under-comparator",
        "dmitmel/cmp-vim-lsp",
        "pontusk/cmp-vimwiki-tags",
        "hrsh7th/cmp-vsnip",
        "tamago324/cmp-zsh",
        "lalitmee/cobalt2.nvim",
        "coc-extensions/coc-svelte",
        "rodrigore/coc-tailwind-intellisense",
        "iamcco/coc-tailwindcss",
        "CRAG666/code_runner.nvim",
        "niuiic/code-shot.nvim",
        "dpayne/CodeGPT.nvim",
        "pwntester/codeql.nvim",
        "adisen99/codeschool.nvim",
        "gorbit99/codewindow.nvim",
        "noib3/cokeline.nvim",
        "ziontee113/color-picker.nvim",
        "tjdevries/colorbuddy.nvim",
        "nvim-zh/colorful-winsep.nvim",
        "nvim-colortils/colortils.nvim",
        "FeiyouG/command_center.nvim",
        "LudoPinelli/comment-box.nvim",
        "numToStr/Comment.nvim",
        "winston0410/commented.nvim",
        "xeluxee/competitest.nvim",
        "krady21/compiler-explorer.nvim",
        "Zeioth/compiler.nvim",
        "vigoux/complementree.nvim",
        "RutaTang/compter.nvim",
        "stevearc/conform.nvim",
        "Olical/conjure",
        "pianocomposer321/consolation.nvim",
        "zbirenbaum/copilot-cmp",
        "zbirenbaum/copilot.lua",
        "github/copilot.vim",
        "ms-jpq/coq.artifacts:artifacts",
        "ms-jpq/coq_nvim",
        "ms-jpq/coq.thirdparty",
        "CosmicNvim/cosmic-ui",
        "niuiic/cp-image.nvim",
        "p00f/cphelper.nvim",
        "Saecki/crates.nvim",
        "gaborvecsei/cryptoprice.nvim",
        "gbprod/cutlass.nvim",
        "ghillb/cybu.nvim",
        "niuiic/dap-utils.nvim",
        "Pocco81/DAPInstall.nvim",
        "sekke276/dark_flat.nvim",
        "4e554c4c/darkman.nvim",
        "nvimdev/dashboard-nvim",
        "Bekaboo/deadcolumn.nvim",
        "andrewferrier/debugprint.nvim",
        "Verf/deepwhite.nvim",
        "chiyadev/dep",
        "akinsho/dependency-assist.nvim",
        "onsails/diaglist.nvim",
        "creativenull/diagnosticls-configs-nvim",
        "monaqa/dial.nvim",
        "sindrets/diffview.nvim",
        "elihunter173/dirbuf.nvim",
        "chipsenkbeil/distant.nvim",
        "niuiic/divider.nvim",
        "Zeioth/dooku.nvim",
        "NTBBloodbath/doom-one.nvim",
        "Mofiqul/dracula.nvim",
        "dracula/vim::dracula-vim",
        "stevearc/dressing.nvim",
        "TheBlob42/drex.nvim",
        "Bekaboo/dropbar.nvim",
        "NFrid/due.nvim",
        "Weissle/easy-action",
        "axkirillov/easypick.nvim",
        "sainnhe/edge",
        "kiran94/edit-markdown-table.nvim",
        "gpanders/editorconfig.nvim",
        "creativenull/efmls-configs-nvim",
        "everblush/nvim::everblush",
        "sainnhe/everforest",
        "neanias/everforest-nvim",
        "google/executor.nvim",
        "tjdevries/express_line.nvim",
        "MunifTanjim/exrc.nvim",
        "roobert/f-string-toggle.nvim",
        "fenetikm/falcon",
        "h-hg/fcitx.nvim",
        "freddiehaddad/feline.nvim",
        "j-hui/fidget.nvim",
        "vonheikemen/fine-cmdline.nvim",
        "glacambre/firenvim",
        "folke/flash.nvim",
        "willothy/flatten.nvim",
        "ggandor/flit.nvim",
        "maxmx03/FluoroMachine.nvim",
        "akinsho/flutter-tools.nvim",
        "CamdenClark/flyboy",
        "is0n/fm-nvim",
        "beauwilliams/focus.nvim",
        "jghauser/fold-cycle.nvim",
        "anuvyklack/fold-preview.nvim",
        "jghauser/follow-md-links.nvim",
        "niuiic/format.nvim",
        "elentok/format-on-save.nvim",
        "mhartington/formatter.nvim",
        "numToStr/FTerm.nvim",
        "amirrezaask/fuzzy.nvim",
        "gfanto/fzf-lsp.nvim",
        "ibhagwan/fzf-lua",
        "linrongbin16/fzfx.nvim",
        "NTBBloodbath/galaxyline.nvim",
        "gbprod/nord.nvim::gbprod-nord-nvim",
        "notomo/gesture.nvim",
        "topaxi/gh-actions.nvim",
        "ldelossa/gh.nvim",
        "f-person/git-blame.nvim",
        "akinsho/git-conflict.nvim",
        "rhysd/git-messenger.vim",
        "lourenci/github-colors",
        "projekt0n/github-nvim-theme",
        "linrongbin16/gitlinker.nvim::gitlinker-linrongbin16",
        "ruifm/gitlinker.nvim::gitlinker-ruifm",
        "lewis6991/gitsigns.nvim",
        "stevearc/gkeep.nvim",
        "DNLHC/glance.nvim",
        "bkegley/gloombuddy",
        "ellisonleao/glow.nvim",
        "ray-x/go.nvim",
        "edolphin-ydf/goimpl.nvim",
        "olexsmir/gopher.nvim",
        "ofirgall/goto-breakpoints.nvim",
        "rmagatti/goto-preview",
        "Robitx/gp.nvim",
        "cbochs/grapple.nvim",
        "desdic/greyjoy.nvim",
        "morhetz/gruvbox",
        "luisiacc/gruvbox-baby",
        "sainnhe/gruvbox-material",
        "ellisonleao/gruvbox.nvim",
        "tjdevries/gruvbuddy.nvim",
        "RishabhRD/gruvy",
        "NMAC427/guess-indent.nvim",
        "ray-x/guihua.lua",
        "m4xshen/hardtime.nvim",
        "ThePrimeagen/harpoon",
        "MrcJkb/haskell-tools.nvim",
        "axkirillov/hbac.nvim",
        "lukas-reineke/headlines.nvim",
        "rebelot/heirline.nvim",
        "udayvir-singh/hibiscus.nvim",
        "crusj/hierarchy-tree-go.nvim",
        "rktjmp/highlight-current-n.nvim",
        "Pocco81/HighStr.nvim",
        "m-demare/hlargs.nvim",
        "shellRaining/hlchunk.nvim",
        "phaazon/hop.nvim",
        "rktjmp/hotpot.nvim",
        "roobert/hoversplit.nvim",
        "anuvyklack/hydra.nvim",
        "smzm/hydrovim",
        "tomiis4/hypersonic.nvim",
        "ziontee113/icon-picker.nvim",
        "keaising/im-select.nvim",
        "samodostal/image.nvim",
        "adelarsq/image_preview.nvim",
        "miversen33/import.nvim",
        "chrsm/impulse.nvim",
        "smjonas/inc-rename.nvim",
        "b0o/incline.nvim",
        "lukas-reineke/indent-blankline.nvim",
        "Darazaki/indent-o-matic",
        "nvimdev/indentmini.nvim",
        "malbertzard/inline-fold.nvim",
        "mvpopuk/inspired-github.vim",
        "jbyuki/instant.nvim",
        "Mr-LLLLL/interestingwords.nvim",
        "hkupty/iron.nvim",
        "mnacamura/iron.nvim::iron-nvim-mnacamura",
        "mizlan/iswap.nvim",
        "matbme/JABS.nvim",
        "is0n/jaq-nvim",
        "clojure-vim/jazz.nvim",
        "metalelf0/jellybeans-nvim",
        "David-Kunz/jester",
        "fuenor/JpFormat.vim",
        "kiyoon/jupynium.nvim",
        "untitled-ai/jupyter_ascending",
        "rebelot/kanagawa.nvim",
        "tenxsoydev/karen-yank.nvim",
        "linty-org/key-menu.nvim",
        "anuvyklack/keymap-amend.nvim",
        "seandewar/killersheep.nvim",
        "lmburns/kimbox",
        "jghauser/kitty-runner.nvim",
        "mikesmithgh/kitty-scrollback.nvim",
        "serenevoid/kiwi.nvim",
        "kmonad/kmonad-vim",
        "frabjous/knap",
        "b3nj5m1n/kommentary",
        "novakne/kosmikoa.nvim",
        "Wansmer/langmapper.nvim",
        "folke/lazy.nvim",
        "kdheepak/lazygit.nvim",
        "Julian/lean.nvim",
        "ggandor/leap-ast.nvim",
        "ggandor/leap.nvim",
        "ggandor/leap-spooky.nvim",
        "Dhanus3133/Leetbuddy.nvim",
        "mrjones2014/legendary.nvim",
        "lmburns/lf.nvim",
        "sourcehut:reggie/licenses.nvim",
        "ggandor/lightspeed.nvim",
        "xiyaowong/link-visitor.nvim",
        "tamago324/lir.nvim",
        "ldelossa/litee.nvim",
        "smjonas/live-command.nvim",
        "gsuuon/llm.nvim",
        "folke/lsp-colors.nvim",
        "nvim-lua/lsp_extensions.nvim",
        "lukas-reineke/lsp-format.nvim",
        "VidocqH/lsp-lens.nvim",
        "sourcehut:whynothugo/lsp_lines.nvim",
        "linrongbin16/lsp-progress.nvim",
        "ray-x/lsp_signature.nvim",
        "nvim-lua/lsp-status.nvim",
        "vonheikemen/lsp-zero.nvim",
        "RishabhRD/lspactions",
        "onsails/lspkind.nvim",
        "nvimdev/lspsaga.nvim",
        "jinzhongjia/LspUI.nvim",
        "barreiroleo/ltex_extra.nvim",
        "folke/lua-dev.nvim",
        "nvim-lualine/lualine.nvim",
        "nvim-neorocks/luarocks-tag-release",
        "L3MON4D3/LuaSnip",
        "alvarosevilla95/luatab.nvim",
        "rktjmp/lush.nvim",
        "nanotee/luv-vimdocs",
        "desdic/macrothis.nvim",
        "dccsillag/magma-nvim",
        "b0o/mapx.nvim",
        "iamcco/markdown-preview.nvim",
        "NFrid/markdown-togglecheck",
        "Zeioth/markmap.nvim",
        "chentoast/marks.nvim",
        "williamboman/mason-lspconfig.nvim",
        "williamboman/mason.nvim",
        "monkoose/matchparen.nvim",
        "marko-cerovac/material.nvim",
        "jubnzv/mdeval.nvim",
        "savq/melange-nvim",
        "ramojus/mellifluous.nvim",
        "kvrohit/mellow.nvim",
        "gaborvecsei/memento.nvim",
        "AckslD/messages.nvim",
        "xero/miasma.nvim",
        "anuvyklack/middleclass",
        "dasupradyumna/midnight.nvim",
        "phaazon/mind.nvim",
        "echasnovski/mini.nvim",
        "yazeed1s/minimal.nvim",
        "brendalf/mix.nvim",
        "jghauser/mkdir.nvim",
        "jakewvincent/mkdnflow.nvim",
        "mawkler/modicator.nvim",
        "ishan9299/modus-theme-vim",
        "kdheepak/monochrome.nvim",
        "tanvirtin/monokai.nvim",
        "shaunsingh/moonlight.nvim",
        "willothy/moveline.nvim",
        "niuiic/multiple-session.nvim",
        "acksld/muren.nvim",
        "nyngwang/murmur.lua",
        "jbyuki/nabla.nvim",
        "liangxianzhe/nap.nvim",
        "ray-x/navigator.lua",
        "numToStr/Navigator.nvim",
        "nvim-neo-tree/neo-tree.nvim",
        "ecthelionvi/NeoColumn.nvim",
        "ecthelionvi/NeoComposer.nvim",
        "folke/neodev.nvim",
        "zbirenbaum/neodim",
        "sbdchd/neoformat",
        "TimUntersberger/neofs",
        "danymat/neogen",
        "adelarsq/neoline.vim",
        "nikvdp/neomux",
        "rafamadriz/neon",
        "nyngwang/NeoNoName.lua",
        "pluffie/neoproj",
        "nvim-neorg/neorg",
        "nvim-neorg/neorg-telescope",
        "nyngwang/NeoRoot.lua",
        "karb94/neoscroll.nvim",
        "svrana/neosolarized.nvim",
        "nyngwang/NeoTerm.lua",
        "nvim-neotest/neotest",
        "coffebar/neovim-project",
        "Shatur/neovim-session-manager",
        "Shatur/neovim-tasks",
        "amiel/neovim-tmux-navigator",
        "nyngwang/NeoWell.lua",
        "preservim/nerdcommenter",
        "LionC/nest.nvim",
        "miversen33/netman.nvim",
        "oberblastmeister/neuron.nvim",
        "Olical/nfnl",
        "cryptomilk/nightcity.nvim",
        "EdenEast/nightfox.nvim",
        "alaviss/nim.nvim",
        "figsoda/nix-develop.nvim",
        "tamago324/nlsp-settings.nvim",
        "tjdevries/nlua.nvim",
        "luukvbaal/nnn.nvim",
        "shortcuts/no-neck-pain.nvim",
        "folke/noice.nvim",
        "AlexvZyl/nordic.nvim::nordic-alexczyl",
        "andersevenrud/nordic.nvim::nordic-andersevenrud",
        "GCBallesteros/NotebookNavigator.nvim",
        "XXiaoA/ns-textobject.nvim",
        "jlesquembre/nterm.nvim",
        "MunifTanjim/nui.nvim",
        "jose-elias-alvarez/null-ls.nvim",
        "nacro90/numb.nvim",
        "nkakouros-original/numbers.nvim",
        "ChristianChiarulli/nvcode-color-schemes.vim",
        "chrisgrieser/nvim-alt-substitute",
        "windwp/nvim-autopairs",
        "RRethy/nvim-base16",
        "norcalli/nvim-base16.lua",
        "code-biscuits/nvim-biscuits",
        "tveskag/nvim-blame-line",
        "kevinhwang91/nvim-bqf",
        "idanarye/nvim-buffls",
        "Iron-E/nvim-cartographer",
        "idanarye/nvim-channelot",
        "hrsh7th/nvim-cmp",
        "weilbith/nvim-code-action-menu",
        "willothy/nvim-cokeline",
        "NvChad/nvim-colorizer.lua",
        "gennaro-tedesco/nvim-commaround",
        "terrortylor/nvim-comment",
        "s1n7ax/nvim-comment-frame",
        "noib3/nvim-compleet",
        "klen/nvim-config-local",
        "haringsrob/nvim_context_vt",
        "andythigpen/nvim-coverage",
        "yamatsum/nvim-cursorline",
        "xiyaowong/nvim-cursorword",
        "Kasama/nvim-custom-diagnostic-highlight",
        "mfussenegger/nvim-dap",
        "rcarriga/nvim-dap-ui",
        "theniceboy/nvim-deus",
        "esensar/nvim-dev-container",
        "luckasRanarison/nvim-devdocs",
        "amrbashir/nvim-docs-view",
        "chrisgrieser/nvim-dr-lsp",
        "chrisgrieser/nvim-early-retirement",
        "AllenDang/nvim-expand-expr",
        "AckslD/nvim-FeMaco.lua",
        "yaocccc/nvim-foldsign",
        "vijaymarupudi/nvim-fzf",
        "sakhnik/nvim-gdb",
        "chrisgrieser/nvim-genghis",
        "AckslD/nvim-gfold.lua",
        "subnut/nvim-ghost.nvim",
        "crispgm/nvim-go",
        "rafaelsq/nvim-goc.lua",
        "booperlv/nvim-gomove",
        "smiteshp/nvim-gps",
        "ojroques/nvim-hardline",
        "brenoprata10/nvim-highlight-colors",
        "Iron-E/nvim-highlite",
        "yaocccc/nvim-hl-mdcodeblock.lua",
        "yaocccc/nvim-hlchunk",
        "kevinhwang91/nvim-hlslens",
        "PHSix/nvim-hybrid",
        "mfussenegger/nvim-jdtls",
        "ckipp01/nvim-jenkinsfile-linter",
        "gennaro-tedesco/nvim-jqx",
        "kaiuri/nvim-juliana",
        "ethanholz/nvim-lastplace",
        "kosayoda/nvim-lightbulb",
        "martineausimon/nvim-lilypond-suite",
        "yaocccc/nvim-lines.lua",
        "mfussenegger/nvim-lint",
        "nanotee/nvim-lsp-basics",
        "williamboman/nvim-lsp-installer",
        "Junnplus/nvim-lsp-setup",
        "jose-elias-alvarez/nvim-lsp-ts-utils",
        "neovim/nvim-lspconfig",
        "ojroques/nvim-lspfuzzy",
        "anott03/nvim-lspinstall",
        "alexaandru/nvim-lspupdate",
        "RishabhRD/nvim-lsputils",
        "nanotee/nvim-lua-guide",
        "bfredl/nvim-luadev",
        "rafcamlet/nvim-luapad",
        "milisims/nvim-luaref",
        "jameshiew/nvim-magic",
        "davidgranstrom/nvim-markdown-preview",
        "scalameta/nvim-metals",
        "bfredl/nvim-miniyank",
        "idanarye/nvim-moonicipal",
        "SmiteshP/nvim-navbuddy",
        "SmiteshP/nvim-navic",
        "AckslD/nvim-neoclip.lua",
        "yamatsum/nvim-nonicons",
        "rcarriga/nvim-notify",
        "LhKipp/nvim-nu",
        "sitiom/nvim-numbertoggle",
        "chrisgrieser/nvim-origami",
        "ojroques/nvim-osc52",
        "mordechaihadad/nvim-papadark",
        "gennaro-tedesco/nvim-peekup",
        "askfiy/nvim-picgo",
        "ellisonleao/nvim-plugin-template",
        "gennaro-tedesco/nvim-possession",
        "yorickpeterse/nvim-pqf",
        "windwp/nvim-projectconfig",
        "chrisgrieser/nvim-puppeteer",
        "RishabhRD/nvim-rdark",
        "chrisgrieser/nvim-recorder",
        "bennypowers/nvim-regexplainer",
        "jamestthompson3/nvim-remote-containers",
        "AckslD/nvim-revJ.lua",
        "chrisgrieser/nvim-rulebook",
        "petertriho/nvim-scrollbar",
        "dstein64/nvim-scrollview",
        "s1n7ax/nvim-search-and-replace",
        "johann2357/nvim-smartbufs",
        "dcampos/nvim-snippy",
        "ishan9299/nvim-solarized-lua",
        "windwp/nvim-spectre",
        "chrisgrieser/nvim-spider",
        "mnacamura/nvim-srcerite",
        "sourcehut:henriquehbr/nvim-startup.lua",
        "emileferreira/nvim-strict",
        "kylechui/nvim-surround",
        "crispgm/nvim-tabline",
        "s1n7ax/nvim-terminal",
        "norcalli/nvim-terminal.lua",
        "klen/nvim-test",
        "alec-gibson/nvim-tetris",
        "chrisgrieser/nvim-tinygit",
        "richardbizik/nvim-toc",
        "nguyenvukhang/nvim-toggler",
        "akinsho/nvim-toggleterm.lua",
        "xiyaowong/nvim-transparent",
        "kyazdani42/nvim-tree.lua",
        "nvim-treesitter/nvim-treesitter",
        "nvim-treesitter/nvim-treesitter-context",
        "nvim-treesitter/nvim-treesitter-refactor",
        "nvim-treesitter/nvim-treesitter-textobjects",
        "RRethy/nvim-treesitter-textsubjects",
        "windwp/nvim-ts-autotag",
        "JoosepAlviste/nvim-ts-context-commentstring",
        "mfussenegger/nvim-ts-hint-textobject",
        "hiphish/nvim-ts-rainbow2",
        "kevinhwang91/nvim-ufo",
        "samjwill/nvim-unception",
        "chrisgrieser/nvim-various-textobjs",
        "kyazdani42/nvim-web-devicons",
        "yorickpeterse/nvim-window",
        "s1n7ax/nvim-window-picker",
        "seandewar/nvimesweeper",
        "nyngwang/nvimgelion",
        "hkupty/nvimux",
        "tenxsoydev/nx.nvim",
        "IlyasYOY/obs.nvim",
        "ada0l/obsidian",
        "epwalsh/obsidian.nvim",
        "mhartington/oceanic-next",
        "pwntester/octo.nvim",
        "ofirgall/ofirkai.nvim",
        "yazeed1s/oh-lucy.nvim",
        "stevearc/oil.nvim",
        "yonlu/omni.vim",
        "cpea2506/one_monokai.nvim",
        "Th3Whit3Wolf/one-nvim",
        "jbyuki/one-small-step-for-vimkind",
        "Th3Whit3Wolf/onebuddy",
        "navarasu/onedark.nvim",
        "olimorris/onedarkpro.nvim",
        "rmehri01/onenord.nvim",
        "LoricAndre/OneTerm.nvim",
        "ofirgall/open.nvim",
        "salkin-mada/openscad.nvim",
        "nvim-orgmode/orgmode",
        "davidgranstrom/osc.nvim",
        "rgroli/other.nvim",
        "lcheylus/overlength.nvim",
        "stevearc/overseer.nvim",
        "nyoom-engineering/oxocarbon.nvim",
        "vuki656/package-info.nvim",
        "wbthomason/packer.nvim",
        "rktjmp/pact.nvim",
        "potamides/pantran.nvim",
        "kdheepak/panvimdoc",
        "rktjmp/paperplanes.nvim",
        "jghauser/papis.nvim",
        "savq/paq-nvim",
        "chrsm/paramount-ng.nvim",
        "niuiic/part-edit.nvim",
        "lewis6991/pckr.nvim",
        "toppair/peek.nvim",
        "koenverburg/peepsight.nvim",
        "Abstract-IDE/penvim",
        "t-troebst/perfanno.nvim",
        "olimorris/persisted.nvim",
        "folke/persistence.nvim",
        "Weissle/persistent-breakpoints.nvim",
        "gbprod/phpactor.nvim",
        "aklt/plantuml-syntax",
        "nvim-treesitter/playground",
        "nvim-lua/plenary.nvim",
        "m00qek/plugin-template.nvim",
        "olivercederborg/poimandres.nvim",
        "nvim-lua/popup.nvim",
        "cbochs/portal.nvim",
        "jedrzejboczar/possession.nvim",
        "rlane/pounce.nvim",
        "andweeb/presence.nvim",
        "Chaitanyabsprip/present.nvim",
        "MunifTanjim/prettier.nvim",
        "anuvyklack/pretty-fold.nvim",
        "ahmedkhalf/project.nvim",
        "gnikdroy/projections.nvim",
        "kevinhwang91/promise-async",
        "jinzhongjia/PS_manager.nvim",
        "stevearc/qf_helper.nvim",
        "ashfinal/qfview.nvim",
        "RutaTang/quicknote.nvim",
        "HiPhish/rainbow-delimiters.nvim",
        "winston0410/range-highlight.nvim",
        "kelly-lin/ranger.nvim",
        "rafaqz/ranger.vim",
        "Fymyte/rasi.vim",
        "kvrohit/rasmus.nvim",
        "TobinPalmer/rayso.nvim",
        "toppair/reach.nvim",
        "linty-org/readline.nvim",
        "gwatcha/reaper-keys",
        "madskjeldgaard/reaper-nvim",
        "tversteeg/registers.nvim",
        "cpea2506/relative-toggle.nvim",
        "filipdutescu/renamer.nvim",
        "9seconds/repolink.nvim",
        "raimon49/requirements.txt.vim",
        "rest-nvim/rest.nvim",
        "kevinhwang91/rnvimr",
        "judaew/ronny.nvim",
        "rose-pine/neovim::rose-pine",
        "shaeinst/roshnivim-cs",
        "OscarCreator/rsync.nvim",
        "MarcHamamji/runner.nvim",
        "simrat39/rust-tools.nvim",
        "kiran94/s3edit.nvim",
        "ray-x/sad.nvim",
        "lewis6991/satellite.nvim",
        "b0o/SchemaStore.nvim",
        "davidgranstrom/scnvim",
        "LintaoAmons/scratch.nvim",
        "ostralyan/scribe.nvim",
        "Xuyuanp/scrollbar.nvim",
        "roobert/search-replace.nvim",
        "utilyre/sentiment.nvim",
        "dinhhuy258/sfm.nvim",
        "sunjon/Shade.nvim",
        "shaunsingh/nord.nvim::shaunsingh-nord-nvim",
        "rktjmp/shenzhen-solitaire.nvim",
        "lewpoly/sherbet.nvim",
        "Wansmer/sibling-swap.nvim",
        "LucasTavaresA/simpleIndentGuides.nvim",
        "LucasTavaresA/SingleComment.nvim",
        "woosaaahh/sj.nvim",
        "ZhiyuanLck/smart-pairs",
        "sychen52/smart-term-esc.nvim",
        "m4xshen/smartcolumn.nvim",
        "gen740/SmoothCursor.nvim",
        "camspiers/snap",
        "smjonas/snippet-converter.nvim",
        "norcalli/snippets.nvim",
        "michaelb/sniprun",
        "sainnhe/sonokai",
        "sQVe/sort.nvim",
        "tmillr/sos.nvim",
        "Th3Whit3Wolf/space-nvim",
        "edluffy/specs.nvim",
        "RutaTang/spectacle.nvim",
        "lewis6991/spellsitter.nvim",
        "bennypowers/splitjoin.nvim",
        "kkharji/sqlite.lua",
        "nanotee/sqls.nvim",
        "luukvbaal/stabilize.nvim",
        "tamton-aquib/staline.nvim",
        "ray-x/starry.nvim",
        "startup-nvim/startup.nvim",
        "jaytyrrell13/static.nvim",
        "luukvbaal/statuscol.nvim",
        "beauwilliams/statusline.lua",
        "gbprod/stay-in-place.nvim",
        "sontungexpt/stcursorword",
        "crusj/structrue-go.nvim",
        "nyngwang/suave.lua",
        "gbprod/substitute.nvim",
        "kvrohit/substrata.nvim",
        "jim-fx/sudoku.nvim",
        "roobert/surround-ui.nvim",
        "bennypowers/svgo.nvim",
        "AckslD/swenv.nvim",
        "Wansmer/symbol-usage.nvim",
        "simrat39/symbols-outline.nvim",
        "ziontee113/syntax-tree-surfer",
        "nanozuki/tabby.nvim",
        "rafcamlet/tabline-framework.nvim",
        "kdheepak/tabline.nvim::tabline-kdheepak",
        "mg979/tabline.nvim::tabline-mg979",
        "abecodes/tabout.nvim",
        "tenxsoydev/tabs-vs-spaces.nvim",
        "roobert/tabtree.nvim",
        "majutsushi/tagbar",
        "roobert/tailwindcss-colorizer-cmp.nvim",
        "themaxmarchuk/tailwindcss-colors.nvim",
        "udayvir-singh/tangerine.nvim",
        "renerocksai/telekasten.nvim",
        "otavioschwanck/telescope-alternate.nvim",
        "nvim-telescope/telescope-bibtex.nvim",
        "LinArcX/telescope-command-palette.nvim",
        "crispgm/telescope-heading.nvim",
        "piersolenski/telescope-import.nvim",
        "mrcjkb/telescope-manix",
        "nvim-telescope/telescope-media-files.nvim",
        "nvim-telescope/telescope.nvim",
        "cljoly/telescope-repo.nvim",
        "desdic/telescope-rooter.nvim",
        "nvim-telescope/telescope-symbols.nvim",
        "LukasPietzschmann/telescope-tabs",
        "danielpieper/telescope-tmuxinator.nvim",
        "debugloop/telescope-undo.nvim",
        "jvgrootveld/telescope-zoxide",
        "chomosuke/term-edit.nvim",
        "jakewvincent/texmagic.nvim",
        "andrewferrier/textobj-diagnostic.nvim",
        "themercorp/themer.lua",
        "zaldih/themery.nvim",
        "mcauley-penney/tidy.nvim",
        "otavioschwanck/tmux-awesome-manager.nvim",
        "aserowy/tmux.nvim",
        "folke/todo-comments.nvim",
        "jedrzejboczar/toggletasks.nvim",
        "tiagovla/tokyodark.nvim",
        "folke/tokyonight.nvim",
        "LeonHeidelbach/trailblazer.nvim",
        "tjdevries/train.nvim",
        "niuiic/translate.nvim",
        "drybalka/tree-climber.nvim",
        "NFrid/treesitter-utils",
        "Wansmer/treesj",
        "cappyzawa/trim.nvim",
        "folke/trouble.nvim",
        "pocco81/true-zen.nvim",
        "ckolkey/ts-node-action",
        "dmmulroy/tsc.nvim",
        "folke/twilight.nvim",
        "jose-elias-alvarez/typescript.nvim",
        "kaarmu/typst.vim",
        "chuwy/ucm.nvim",
        "altermo/ultimate-autopair.nvim",
        "mbbill/undotree",
        "slugbyte/unruly-worker",
        "sontungexpt/url-open",
        "axieax/urlview.nvim",
        "gaborvecsei/usage-tracker.nvim",
        "Mangeshrex/uwu.vim",
        "konapun/vacuumline.nvim",
        "willothy/veil.nvim",
        "jbyuki/venn.nvim",
        "tanvirtin/vgit.nvim",
        "embark-theme/vim",
        "theprimeagen/vim-apm",
        "moll/vim-bbye",
        "ThePrimeagen/vim-be-good",
        "tomasiser/vim-code-dark",
        "junegunn/vim-easy-align",
        "houtsnip/vim-emacscommandline",
        "mnacamura/vim-fennel-syntax",
        "inkch/vim-fish::vim-fish-inkch",
        "rhysd/vim-gfm-syntax",
        "hylang/vim-hy",
        "RRethy/vim-illuminate",
        "andymass/vim-matchup",
        "bluz71/vim-moonfly-colors",
        "bluz71/vim-nightfly-colors",
        "meain/vim-printer",
        "mnacamura/vim-r7rs-syntax",
        "tpope/vim-repeat",
        "dstein64/vim-startuptime",
        "evanleck/vim-svelte",
        "leafOfTree/vim-svelte-plugin",
        "kana/vim-textobj-indent",
        "sgur/vim-textobj-parameter",
        "rcarriga/vim-ultest",
        "wakatime/vim-wakatime",
        "thaerkh/vim-workspace",
        "svermeulen/vim-yoink",
        "ldelossa/vimdark",
        "svermeulen/vimpeccable",
        "lervag/vimtex",
        "vimwiki/vimwiki",
        "xiyaowong/virtcolumn.nvim",
        "jubnzv/virtual-types.nvim",
        "00sapo/visual.nvim",
        "askfiy/visual_studio_code",
        "2nthony/vitesse.nvim",
        "tjdevries/vlog.nvim",
        "nxvu699134/vn-night.nvim",
        "EthanJWright/vs-tasks.nvim",
        "Mofiqul/vscode.nvim",
        "ray-x/web-tools.nvim",
        "willothy/wezterm.nvim",
        "folke/which-key.nvim",
        "gelguy/wilder.nvim",
        "declancm/windex.nvim",
        "windwp/windline.nvim",
        "anuvyklack/windows.nvim",
        "sindrets/winshift.nvim",
        "natecraddock/workspaces.nvim",
        "piersolenski/wtf.nvim",
        "nekonako/xresources-nvim",
        "pianocomposer321/yabs.nvim",
        "someone-stole-my-name/yaml-companion.nvim",
        "cuducos/yaml.nvim",
        "Xuyuanp/yanil",
        "gbprod/yanky.nvim",
        "milanglacier/yarepl.nvim",
        "sonjiku/yawnc.nvim",
        "zdcthomas/yop.nvim",
        "folke/zen-mode.nvim",
        "mcchrish/zenbones.nvim",
        "phha/zenburn.nvim",
        "nvimdev/zephyr-nvim",
        "titanzero/zephyrium",
        "mickael-menu/zk-nvim",
    ]

    #  for repo in repos[40:41]:
    i = 14
    for repo in repos[i:i+1]:

        # extract code from readme

        lua: list[str]|None = extract_lua(repo)

        name = repo.replace("/", "-")

        # parse extracted code block to lua

        code = []
        if lua is not None:
            for section in lua:
                parsed = Parser(section).code
                code.append(parsed)

        # output config

        print()
        print("Current output:")
        print()

        pprint(code)
        print()

        # TODO: ...

if __name__ == "__main__":
    main()
