
# NixNeovim - A Neovim configuration module for nix

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
    
    # NixNeovim contains some colorschemes
    colorschemes.gruvbox.enable = true;

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

## Documentation

Can already be generated using `nix build .#docs`, but it is not yet avilable online.

## Contribution

Contributions are very welcome.
They help improve this project and keep it up to date.

Here is a list of how you can contribute to this project.

TODO:

### Adding a module

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

- In `helpers.nix` we have defined several functions for basic plugin options like bool, strings or integer.
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

## Key mappings

It is fully possible to define key mappings from within NixVim. This is done
using the `maps` attribute:

```nix
{
  programs.nixneovim = {
    maps = {
      normalVisualOp.";" = ":";
      normal."<leader>m" = {
        silent = true;
        action = "<cmd>make<CR>";
      };
    };
  };
}
```

This is equivalent to this vimscript:

```vim
noremap ; :
nnoremap <leader>m <silent> <cmd>make<CR>
```

This table describes all modes for the `maps` option:

| NixVim         | NeoVim                                           |
|----------------|--------------------------------------------------|
| normal         | Normal mode                                      |
| insert         | Insert mode                                      |
| visual         | Visual and Select mode                           |
| select         | Select mode                                      |
| terminal       | Terminal mode                                    |
| normalVisualOp | Normal, visual, select and operator-pending mode |
| visualOnly     | Visual mode only, without select                 |
| operator       | Operator-pending mode                            |
| insertCommand  | Insert and command-line mode                     |
| lang           | Insert, command-line and lang-arg mode           |
| command        | Command-line mode                                |

The map options can be set to either a string, containing just the action,
or to a set describing additional options:

| NixVim  | Default | VimScript                                |
|---------|---------|------------------------------------------|
| silent  | false   | `<silent>`                               |
| nowait  | false   | `<silent>`                               |
| script  | false   | `<script>`                               |
| expr    | false   | `<expr>`                                 |
| unique  | false   | `<unique>`                               |
| noremap | true    | Use the 'noremap' variant of the mapping |
| action  | N/A     | Action to execute                        |

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
