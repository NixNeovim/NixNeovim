#!/usr/bin/env bash

git clone https://github.com/pta2002/nixvim pta
git clone https://github.com/nixneovim/nixneovim me

# list plugins of pta
plugins_pta="$(find ./pta/plugins -type f -printf "%f\n" | sort | uniq)"

# list plugins of me
plugins_me="$(find ./me/plugins -type f -printf "%f\n" | sort | uniq)"

# write both outputs to temporary files
echo "$plugins_pta" > pta_plugins
echo "$plugins_me" > me_plugins

# compare plugins; output those that are only present in pta_plugins
found_missing=$(comm -23 pta_plugins me_plugins)

# plugins for which an issue already exists (including closed ones)
known_issues=$(gh issue list --state "all" --label "bot" --json "body" | jq ".[].body" | grep -o '#[.0-9a-zA-Z_-]*')

# iterate over plugins we found missing and
# compare them to all open issues.
# We no matching issue was found, we create a new one
for f in $found_missing
do
    found=false

    for k in $known_issues
    do
        if [[ "#$f" == "$k" ]]
        then
            found=true
            break
        fi
    done

    # test if matching issue was found
    if ! $found
    then
        echo "Did not find an issue for $f. Creating a new one ..."
        # gh issue create --title "Detected missing plugin: $f" --label "bot" --body "#$f"
    else
        echo "Issue for $f already exists"
    fi

done
