# Forked

This is originally based on [pta2002/nixvim](https://github.com/pta2002/nixvim).
However, this fork contains more modules and cleaner code.

# NixVim - A Neovim configuration system for nix

This flake provides modules for NixOS and Home Manager, which provide the `nixvim` configuration options.
Using `nixvim`, you can configure Neovim, including plugins, through nix.
This makes your Neovim config reproducible, and easier to manage.

## Get Ready

To use the modules, add this flake to the inputs of your nix configuration.

```nix
{
inputs.nixvim.url = "github:jooooscha/nixvim";
}
```

Then, apply the overlay and import the modules.
This is needed, because NixVim uses [nixpkgs-vim-extra-plugins](https://github.com/jooooscha/nixpkgs-vim-extra-plugins) to get access to more Neovim plugins.

```nix
{
nixpkgs.overlays = [
    nixvim.overlays.default
];
}
```

And import the module to your Home Manager (recommended) or NixOS configuration.

```nix
{
imports = [
    nixvim.nixosModules.default # with Home Manager
    # nixvim.nixosModules.nixos # without Home Manager
];
}
```

## Example Config

Importing the modules gives you access to the `programs.nixvim` config.
A wiki for all options will be available in the near future.

```nix
{
  programs.nixvim = {
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

# Documentation

Can already be generated using `nix build .#docs`, but it is not yet avilable online.


## Old Readme

The rest of this readme is still in its original state from the fork.
It has not yet been updated, and may contain wrong information.


## Options

```nix
{
  programs.nixvim = {
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
  programs.nixvim = {
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
