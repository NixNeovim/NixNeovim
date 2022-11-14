#!/usr/bin/env bash

git clone https://github.com/pta2002/nixvim pta
git clone https://github.com/jooooscha/nixvim me

# list plugins of pta
plugins_pta="$(find ./pta/plugins -type f -printf "%f\n" | sort | uniq)"

# list plugins of me
plugins_me="$(find ./me/plugins -type f -printf "%f\n" | sort | uniq)"

# write both outputs to temporary files
echo "$plugins_pta" > pta_plugins
echo "$plugins_me" > me_plugins

# known_false_positives="(basic-servers.nix|cmp-helpers.nix|comment-nvim.nix)"


# compare plugins; output those that are only present in pta_plugins
found_missing=$(comm -23 pta_plugins me_plugins)

known_issues=$(gh issue list --state "all" --label "bot" --json "body" | jq -r ".[].body")


for f in $found_missing
do
    found=false

    for k in $known_issues
    do
        if [[ "$f" == "$k" ]]
        then
            found=true
            break
        fi
    done

    if ! $found
    then
        echo "Did not find an issue for $f. Creating a new one ..."
        gh issue create --title "Detected missing plugin: $f" --label "bot" --body "$f"
    else
        echo "Issue for $f already exists"
    fi


done




# gh issue create --title "Missing plugins detected" --label "bot" --body-file - << EOF

# I found the following plugins in pta2002's repo, but not in this one:

# $output

# EOF
