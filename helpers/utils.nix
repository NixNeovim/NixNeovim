# TODO: crreate function is Raw

{ lib, self }:

let
  inherit (lib)
    flatten
    mapAttrsToList
    filterAttrs
    assertMsg;

  inherit (builtins)
    hasAttr
    foldl'
    attrNames
    attrValues
    isAttrs;

  checkRawLua = lua:
    assert assertMsg (isAttrs lua) "Function isRawLua failed: input is not of a raw lua string (is not type Attrs)\n - '${lua}'";
    assert assertMsg (hasAttr "__raw" lua) "Function isRawLua failed: input dows not have __raw attribute\n - '${lua}'";
    assert assertMsg (filterAttrs (key: _: key != "__raw") lua == {}) "Function isRawLua failed: input has unrecognised attributes\n - '${lua}'";
    lua;

in {

  inherit checkRawLua;

  # Input: char, int
  #
  # Repeat char n times
  repeatChar = char: n:
    if n == 0 then
      ""
    else
      "  " + self.repeatChar char (n - 1); # 2 spaces

  # Input: int
  indent = depth: self.repeatChar " " depth;

  # Create a rawLua Object
  rawLua = lua: { __raw = lua; };

  # Input: attr
  # Output: bool
  #
  # Checks if the input is a correct raw lua attribute set
  isRawLua = lua:
    let
      correctType = isAttrs lua;
      hasRawAttr = hasAttr "__raw" lua;
      hasOnlyRawAttr = filterAttrs (key: _: key != "__raw") lua == {};
    in correctType && hasRawAttr && hasOnlyRawAttr;

  # Input: raw lua attribute set
  #
  # returns the raw lua code, if the input is of correct type
  getRawLua = lua:
    let
      value = (checkRawLua lua).__raw;
    in
      if isNull value then
        "nil"
      else
        value;

  # remove the enable key from a attribute set
  removeEnable = attrs:
    filterAttrs (n: _: n != "enable") attrs;

  optionalString = condition: string:
    if condition != null && condition then
      string
    else
      "";


  # Input: attrset
  # Output: attrset
  #
  # Merge all values of all attributes of a attibutes set
  #
  # Example:
  # Input:
  # {
  #  gruvbox-baby = {
  #   test1= {}
  #   test2= {}
  #  };
  #  gruvbox-material = {
  #   test3= {}
  #   test4= {}
  #  };
  # }
  # Output:
  # {
  #  test1 = {};
  #  test2 = {};
  #  test3 = {};
  #  test4 = {};
  # }
  mergeValues = input: foldl' (final: set: final // set) {} (attrValues input);

  testHelper = {
    config = {
      start = ''

--------------------------------------------------
--                 Globals                      --
--------------------------------------------------


--------------------------------------------------
--                 Options                      --
--------------------------------------------------


--------------------------------------------------
--                 Keymappings                  --
--------------------------------------------------



--------------------------------------------------
--                 Augroups                     --
--------------------------------------------------



--------------------------------------------------
--               Extra Config (Lua)             --
--------------------------------------------------

    '';
    end = "";
    };
    moduleTest = text:
      ''
      echo Begin test
      nvimFolder="home-files/.config/nvim"
      config="$(_abs $nvimFolder/init.lua)"
      assertFileExists "$config"

      PATH=$PATH:$(_abs home-path/bin)
      mkdir -p "$(realpath .)/cache/nvim" # add cache dir; needed for barbar.json
      HOME=$(realpath .) nvim -u "$config" -c 'qall' --headless
      echo # add missing \0 to output of 'nvim'

      # Replace the path the vimscript file, because it contains the hash
      sed "s/\/nix\/store\/[a-z0-9]\{32\}/\<nix-store-hash\>/" "$config" > normalizedConfig.lua
      normalizedConfig=normalizedConfig.lua

      neovim_error() {
        echo ----------------- NEOVIM CONFIG -----------------
        cat -n "$config"
        echo -------------------------------------------------

        echo
        echo

        echo ----------------- NEOVIM INFO -------------------
        nvim --version
        echo -------------------------------------------------

        echo ----------------- NEOVIM PATH -------------------
        echo $PATH
        echo -------------------------------------------------

        echo ----------------- NEOVIM OUTPUT -----------------
        echo "$1"
        echo -------------------------------------------------
        exit 1
      }

      start_nvim () {
        HOME=$(realpath .) XDG_CACHE_HOME=$(realpath ./cache) nvim -u $config --headless "$@" -c 'qall'
      }

      check_nvim_start () {
        OUTPUT=$(HOME=$(realpath .) XDG_CACHE_HOME=$(realpath ./cache) nvim -u $config --headless "$@" -c 'qall' 2>&1)
        if [ "$OUTPUT" != "" ]
        then
          neovim_error "$OUTPUT"
        fi
      }

      check_colorscheme () {
        OUTPUT=$(HOME=$(realpath .) XDG_CACHE_HOME=$(realpath ./cache) nvim -u $config --headless -c 'colorscheme' -c 'qall' 2>&1)
        if [ "$OUTPUT" != "$1" ]
        then
          neovim_error "Expected '$1'. Found: '$OUTPUT'"
        fi
      }

      echo Start Vim tests
      check_nvim_start

      echo Testing some common file types

      echo "# test" > tmp.md
      check_nvim_start tmp.md

      echo "print(\"works\")" > tmp.py
      check_nvim_start tmp.py

      cat << EOF > tmp.rs
        fn main() {
          println!("Hello, world!");
        }
      EOF
      check_nvim_start tmp.rs

      echo Vim tests done

      ${text}
      '';
  };


  ##############################################################################
  # helper functions for plugins with sub-plugins like cmp, lsp, telescope, etc.

  # filters activated options from a set
  activated = cfg: options: filterAttrs (name: attrs: cfg.${name}.enable) options;

  # returns a list of the names of all activated options
  activatedNames = cfg: options: attrNames (self.activated cfg options);

  # Input: cfg, options of sub-plugins
  # Output: activated sub-plugins
  activatedPackages = cfg: options:
    flatten (mapAttrsToList (name: attrs: attrs.packages) (self.activated cfg options));

  activatedLuaNames = cfg: options:
    flatten (mapAttrsToList (name: attrs: attrs.luaName) (self.activated cfg options));

  activatedPlugins = cfg: options:
    flatten (mapAttrsToList (name: attrs: attrs.plugins) (self.activated cfg options));

  activatedConfig = cfg: options:
    mapAttrsToList (name: attrs: attrs.extraConfig) (self.activated cfg options);
}
