#!/usr/bin/env bash

git clone https://github.com/pta2002/nixvim pta
git clone https://github.com/jooooscha/nixvim me

# list plugins of pta
plugins_pta="$(find ./pta/plugins -type f -printf "%f\n" | sort)"

# list plugins of me
plugins_me="$(find ./me/plugins -type f -printf "%f\n" | sort)"

# write both outputs to temporary files
echo "$plugins_pta" > pta_plugins
echo "$plugins_me" > me_plugins

known_false_positives="(basic-servers.nix|cmp-helpers.nix|comment-nvim.nix)"


# compare plugins; output those that are only present in pta_plugins
output=$(comm -23 pta_plugins me_plugins | sed -E "/${known_false_positives}/d" | sed -E 's/^/- /')

echo "I found the following missing plugins: \"$output\"" | gh issue create --title "Missing plugin detected" --body-file -
