from readme import parse_readme
from parser import Parser
from nix import format_nix
from create_plugin_file import PluginFile
from data import Table, FunctionBody
import requests
import json
from types import SimpleNamespace
from pprint import pprint
from errors import *
from log import *

def deep_merge(source, destination):
    """
    >>> a = { 'first' : { 'all_rows' : { 'pass' : 'dog', 'number' : '1' } } }
    >>> b = { 'first' : { 'all_rows' : { 'fail' : 'cat', 'number' : '5' } } }
    >>> merge(b, a) == { 'first' : { 'all_rows' : { 'pass' : 'dog', 'fail' : 'cat', 'number' : '5' } } }
    True
    """
    for key, value in source.items():
        if isinstance(value, dict):
            # get node or create one
            node = destination.setdefault(key, {})
            deep_merge(value, node)
        else:
            destination[key] = value

    return destination

def get_plugins_json() -> dict:
    url = "https://raw.githubusercontent.com/NixNeovim/NixNeovimPlugins/main/.plugins.json"
    response = requests.get(url)
    if response.status_code == 200:
        json = response.json()
        return json
    else:
        raise NetworkException(f"Could not fetch plugin data: {response.status_code}")

def main():

    #  limit = 17 #TMP
    #  counter = 0 #TMP

    # load plugin information
    plugins = get_plugins_json()

    # go through all plugins and generate config
    for i, plugin in enumerate(plugins):

        #TMP
        #  if counter < limit:
            #  counter += 1
            #  continue
        #  elif counter > limit:
            #  exit()

        #  counter += 1 #TMP

        # convert json to object
        data = json.loads(plugins[plugin], object_hook=lambda d: SimpleNamespace(**d))

        plugin_name = data.name
        homepage = data.homepage
        repo = plugin
        name = plugin.replace("/", "-") # normalize repo name

        # extract relevant lua snippets from README
        lua: list[str]|None = parse_readme(repo)

        if lua is None:
            continue

        # parse extracted code block to lua

        code_list = [] # list of extraced code blocks
        for j, section in enumerate(lua):
            debug(f"Parsing {j+1}/{len(lua)}")
            parsed = Parser().parse(section)
            if parsed is not None:
                code_list.append(parsed)

        # clean up final config

        final_config = Table()

        for code in code_list:
            if isinstance(code, Table):
                final_config.merge(code)
            elif isinstance(code, FunctionBody):
                debug("Not adding function body to final_config table")
            else:
                raise Unimplemented(f"Error: unknown code type ({code})")

        final_config.clean()
        pprint(final_config)

        # generate config

        nix_options = format_nix(final_config.to_nix())

        # write new plugin file

        PluginFile(name, homepage, plugin_name, nix_options)

        info(f"Done {i}/{len(plugins)}")

if __name__ == "__main__":
    main()
