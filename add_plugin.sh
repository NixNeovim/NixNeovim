set -o errexit
set -o nounset
set -o pipefail

name="$1"
url=$(echo "$2" | sed 's/[\&/]/\\&/g')
plugin="$3"


[ -z "$name" ] && exit 1
[ -z "$url" ] && exit 1
[ -z "$plugin" ] && exit 1

plugin_path="plugins/utils/$name.nix"
plugin_test_path="tests/plugins/$name.nix"

echo Copy template
cp ./plugin_template_minimal.nix "$plugin_path"

echo Replace names
sed -i "s/PLUGIN_NAME/$name/" "$plugin_path"
sed -i "s/PLUGIN_URL/$url/" "$plugin_path"

echo Insert plugin
ed "$plugin_path" <<EOF
g/add neovim plugin here/p
a
    $plugin
.
w
q
EOF

echo Copy test template
cp ./test_template.nix "$plugin_test_path"

echo Add to git
git add "$plugin_path" "$plugin_test_path"
