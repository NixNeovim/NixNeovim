
# NixNeovim - A Neovim configuration module for NixOs

This flake provides modules for NixOS and Home Manager, which provide the `nixneovim` configuration options.
Using `nixneovim`, you can configure Neovim, including plugins, through nix.
This makes your Neovim config reproducible, and easier to manage.

#### Forked

This is originally based on [pta2002/nixvim](https://github.com/pta2002/nixvim).
However, NixNeovim contains more modules and cleaner code.

## Get Ready

To use the modules, add this flake to the inputs of your nix configuration.

```nix
{
inputs.nixneovim.url = "github:nixneovim/nixneovim";
}
```

Then, apply the overlay and import the modules.
This is needed, because NixNeovim uses [nixpkgs-vim-extra-plugins](https://github.com/jooooscha/nixpkgs-vim-extra-plugins) to get access to more Neovim plugins.

```nix
{
nixpkgs.overlays = [
    nixneovim.overlays.default
];
}
```

And import the module to your Home Manager (recommended) or NixOS configuration.

```nix
{
imports = [
    nixneovim.nixosModules.default # with Home Manager
    # nixneovim.nixosModules.nixos # without Home Manager
];
}
```

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
      lsp = {
        enable = true;
        hls.enable = true;
        rust-analyzer.enable = true;
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
    # For a list of available plugins, look here: [available plugins](https://github.com/jooooscha/nixpkgs-vim-extra-plugins/blob/main/plugins.md)
    extraPlugins = [ pkgs.vimExtraPlugins.<plugin> ];
  };
}
```

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

| NixVim  | Default | VimScript                                |
|---------|---------|------------------------------------------|
| silent  | false   | `<silent>`                               |
| nowait  | false   | `<silent>`                               |
| script  | false   | `<script>`                               |
| expr    | false   | `<expr>`                                 |
| unique  | false   | `<unique>`                               |
| noremap | true    | Use the 'noremap' variant of the mapping |
| action  |         | Action to execute                        |

## Roadmap

- [ ] Further cleanup code
- [ ] Port more modules to `mkLuaPlugin` function
- [ ] Add some form of tests

## Documentation

All options are documented at: [NixNeovim Documentation](https://nixneovim.github.io/NixNeovim/options.html)

You can generate the docs using `nix build .#docs`

### Supported language servers

Until we find a better way of documenting this, you can find a list of supported language servers here: [servers.nix](https://github.com/NixNeovim/NixNeovim/blob/main/plugins/nvim-lsp/options/servers.nix)

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

- Go to the module you want to add options to.
- Add your options to the `moduleOptions` attribute set.

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
- ... improve this

### Rewrite module to new `mkLuaPlugin` api

The `mkLuaPlugin` functions helps reduce boiler code and has some checks to improve the quality of the modules.
In the long term, all modules should be rewritten to use the `mkLuaPlugin` function.

### Create a better logo

- The current logo took me 20 seconds to make.
- I think this project deserves better

## ⚠ Old Readme ⚠

The rest of this readme is still in its original state from the fork.
It has not yet been updated, and may contain wrong information.


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
