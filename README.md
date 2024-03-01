
# NixNeovim - A Neovim configuration module for NixOS

This flake provides modules for NixOS and Home Manager, which provide the `nixneovim` configuration options.
Using `nixneovim`, you can configure Neovim, including plugins, through nix.
This makes your Neovim config reproducible, and easier to manage.

#### Forked

This was originally based on [pta2002/nixvim](https://github.com/pta2002/nixvim).
However, today, it shares very little code, approaches problems very differently, and is completely independent.

## Get Ready

To use the modules, add this flake to the inputs of your nix configuration.

```nix
{
inputs.nixneovim.url = "github:nixneovim/nixneovim";
}
```

Then, apply the overlay and import the modules.
This is needed, because NixNeovim uses [NixNeovimPlugins](https://github.com/NixNeovim/NixNeovimPlugins) to get access to more Neovim plugins.

```nix
{
nixpkgs.overlays = [
    nixneovim.overlays.default
];
}
```

And import the module to your Home Manager (recommended) or NixOS configuration.
Depending on your nixos version, you have to import different modules.
In particular, the `default` and `homeManager` modules only work with the Nixpkgs/HomeManager `unstable` releases.
When you use Nixos/HomeManager 22.11, please import `homeManager-22-11` or `nixos-22-11`.

```nix
{
imports = [
    nixneovim.nixosModules.default # with Home Manager unstable
    # nixneovim.nixosModules.homeManager-22-11 # with Home Manager 22.11
    # nixneovim.nixosModules.nixos # without Home Manager
];
}
```

## Documentation

All options are documented at: [NixNeovim Documentation](https://nixneovim.github.io/NixNeovim/options.html).
Alternatively, you can use this search: [NixNeovim Options Search](https://nixneovim.github.io/nixneovim-option-search/).

Finally, you can generate the docs using `nix build .#docs`.

## Example Config

Importing the modules gives you access to the `programs.nixneovim` config.
A wiki for all options will be available in the near future.

```nix
{
  programs.nixneovim = {
    enable = true;
    extraConfigVim = ''
      # you can add your old config to make the switch easier
      ${lib.strings.fileContents ./init.vim}
      # or with lua
      lua << EOF
        ${lib.strings.fileContents ./init.lua}
      EOF
    '';
    
    # to install plugins just activate their modules
    plugins = {
      lspconfig = {
        enable = true;
        servers = {
          hls.enable = true;
          rust-analyzer.enable = true;
        };
      };
      treesitter = {
        enable = true;
        indent = true;
      };
      mini = {
        enable = true;
        ai.enable = true;
        jump.enable = true;
      };
    };

    # Not all plugins have own modules
    # You can add missing plugins here
    # `pkgs.vimExtraPlugins` is added by the overlay you added at the beginning
    # For a list of available plugins, look here: [available plugins](https://github.com/NixNeovim/NixNeovimPlugins/blob/main/plugins.md)
    extraPlugins = [ pkgs.vimExtraPlugins.<plugin> ];
  };
}
```

### Reduce size of `init.lua`

Warning: Using this is currently discouraged as it can cause build failures. I am working on it.

By default, NixNeovim prints all config to `init.lua` in order to have a more stable config.
You can turn this off by setting `nixneovim.usePluginDefaults`.
This way, NixNeovim will only print the configs you have changed.

Setting `nixneovim.usePluginDefaults` to `true` reduces the size of your `init.lua` but can lead to unexpected changes of your setup,
when a plugin author decides to change their defaults.

## Key mappings

You can define your key mappings using the `mappings` option.

```nix
{
  programs.nixneovim = {
    mappings = {
      normalVisualOp = {
        ";" = "':'"; # vimscript between ' '
      };
      normal = {
        "<leader>m" = {
          action = "'<cmd>make<cr>'"; # vimscript between ' '
          silent = true;
        };
        "<leader>h" = "function() print(\"hi\") end"; # Lua code without ' '
      };
    };
  };
}
```

This uses `vim.keymap.set` under the hood.
Therefore, you can specify lua functions directly.
However, this also means, when writing vimscript, you have to put that between extra quotation marks.

This is equivalent to:

```lua
vim.keymap.set("", ";", ':')
vim.keymap.set("n", "<leader>m", '<cmd>make<cr>', { silent = true })
vim.keymap.set("n", "<leader>h", function() print("hi") end)
```

First, you specify the mode; you can choose between the keywords below.

| NixNeovim      | NeoVim | Description                                  |
|----------------|--------|----------------------------------------------|
| normalVisualOp | ""     | Normal, visual, select, and operator-pending |
| normal         | "n"    | Normal                                       |
| insertCommand  | "!"    | Insert and command-line                      |
| insert         | "i"    | Insert                                       |
| command        | "c"    | Command-line                                 |
| visual         | "v"    | Visual and Select                            |
| visualOnly     | "x"    | Visual                                       |
| select         | "s"    | Select                                       |
| operator       | "o"    | Operator-pending                             |
| terminal       | "t"    | Terminal                                     |
| lang           | "l"    | Insert, command-line, and lang-arg           |

When specifying the mapping with an attribute set you can set the following options.

| NixNeovim | Default | VimScript                                |
|-----------|---------|------------------------------------------|
| silent    | false   | `<silent>`                               |
| nowait    | false   | `<silent>`                               |
| script    | false   | `<script>`                               |
| expr      | false   | `<expr>`                                 |
| unique    | false   | `<unique>`                               |
| noremap   | true    | Use the 'noremap' variant of the mapping |
| action    |         | Action to execute                        |

## Augroups

You can define augroups with the `augroups` option.

```nix
{
  programs.nixneovim = {
    augroups = {
      highlightOnYank = {
        autocmds = [{
          event = "TextYankPost";
          pattern = "*";
          # Or use `vimCallback` with a vimscript function name
          # Or use `command` if you want to run a normal vimscript command
          luaCallback = ''
            vim.highlight.on_yank {
              higroup = (
                vim.fn['hlexists'] 'HighlightedyankRegion' > 0 and 'HighlightedyankRegion' or 'IncSearch'
              ),
              timeout = 200,
            }
          '';
        }];
      };
    };
  };
}
```

## Roadmap

- [ ] Further cleanup code
- [ ] Port more modules to `mkLuaPlugin` function
- [x] Add some form of tests
- [ ] Integrate tests with `mkLuaPlugin`

### Supported language servers

Until we find a better way of documenting this, you can find a list of supported language servers here: [servers.nix](./src/plugins/_lspconfig-modules/servers.nix)

## Contribution

Contributions are very welcome.
They help improve this project and keep it up to date.

### Adding a module

- Look at the automatically generated issues. Those are plugins available in the original repo, but not yet in this. Start with those, if you like
- Copy `plugin_template.nix` or `plugin_template_minimal.nix`
- Add the following information:
    - `name`
    - `pluginUrl`
    - `moduleOptions`
    - `extraPlugins`
- If not otherwise specified, `mkLuaPlugin` will add the following string to `init.vim`:
    - `extraConfigLua = "require('${name}').setup ${toLuaObject pluginOptions}";`
    - This can be disabled with `defaultRequire = false`

### Adding options to a module

- When using the `plugin_template.nix` you add options to the `moduleOptions` attribute set.

```nix
{
  moduleOptions = with helpers; {
    mappings = mkOption {
      type = types.attrs;
      default = { };
    };
    enableAuto = boolOption false "Enable auto expanding snippets";
  };
}
```

- In `helper/custom_options.nix` we have defined several functions for basic plugin options like bool, strings or integer.
- In particular, ther are:
    - `boolOption, intOption, strOption, attrsOption, enumOption`

#### Auto generate module options

⚠️ This is script is under active development and is heavily changed and exented in [this PR](https://github.com/NixNeovim/NixNeovim/pull/80). Please be careful ⚠️

- With `nix run .#configparser` you can convert a Lua setup configs to nix module options (you might need to update the submodule with `git submodule update tree-sitter-lua`).
- For example, you can input the following Lua configs (taken from [NvimTree](https://github.com/nvim-tree/nvim-tree.lua); Example-comment added)

```zsh
nix run .#configparser <<EOF
require("nvim-tree").setup({
  sort_by = "case_sensitive",
  view = {
    -- Example comment
    width = 30,
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = true,
  },
})
EOF
```

- The output will be

```nix
 {
   sort_by = strOption "case_sensitive" "";
   view = {
     # Example comment
     width = intOption 30 "Example comment";
   };
   renderer = {
     group_empty = boolOption true "";
   };
   filters = {
     dotfiles = boolOption true "";
   };
 }
```

The output is best-effort and will likely contain errors.
For example, the script cannot detect if a variable is a string or an `enum`.
Therefore, you likely have to edit and correct the output before you add it to the module.

### Rewrite module to new `mkLuaPlugin` api

The `mkLuaPlugin` functions helps reduce boiler code and has some checks to improve the quality of the modules.
In the long term, all modules should be rewritten to use the `mkLuaPlugin` function.

### Create a better logo

- The current logo took me 20 seconds to make.
- I think this project deserves better


## Options

```nix
{
  programs.nixneovim = {
    options = {
      number = true;         # Show line numbers
      relativenumber = true; # Show relative line numbers

      shiftwidth = 2;        # Tab width should be 2
    };
  };
}
```

Please note that to, for example, disable numbers you would not set
`options.nonumber` to true, you'd set `options.number` to false.

## Globals

Sometimes you might want to define a global variable, for example to set the
leader key. This is easy with the `globals` attribute:

```nix
{
  programs.nixvim = {
    globals.mapleader = ","; # Sets the leader key to comma
  };
}
```

## Support me personally

<a href="https://www.buymeacoffee.com/jooooscha" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>
