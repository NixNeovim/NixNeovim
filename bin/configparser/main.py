from readme import parse_readme
from parser import Parser
from nix import ToNix
from create_plugin_file import PluginFile
from data import Table
import requests
import json
from types import SimpleNamespace
from pprint import pprint
from errors import *
import logging
import coloredlogs
from logging import debug, warning, info

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
    coloredlogs.install(level='DEBUG')

    limit = 10 #TMP
    counter = 0 #TMP

    # load plugin information
    plugins = get_plugins_json()

    # go through all plugins and generate config
    for i, plugin in enumerate(plugins):

        #TMP
        if counter < limit:
            counter += 1
            continue
        elif counter > limit:
            exit()

        counter += 1 #TMP

        # convert json to object
        data = json.loads(plugins[plugin], object_hook=lambda d: SimpleNamespace(**d))

        plugin_name = data.name
        homepage = data.homepage
        repo = plugin
        name = plugin.replace("/", "-") # normalize repo name

        # extract relevant lua snippets from README
        lua: list[str]|None = parse_readme(repo)

        if lua is None:
            raise ExtractionException("Could not extract lua code from README")


        # parse extracted code block to lua

        code_list = [] # list of extraced code blocks
        for i, section in enumerate(lua):
            debug(f"Parsing {i+1}/{len(lua)}")
            try:
                parsed = Parser(section).code
                code_list.append(parsed)
            except Exception as e:
                warning(f"Could not extract code from this section: {e}")

        final_config = Table()

        #  pprint(code_list)
        #  print()
        for code in code_list:
            if isinstance(code, Table):
                final_config.merge(code)
            else:
                raise Unimplemented(f"Error: unknown code type ({code})")

        final_config.clean()
        #  pprint(final_config)

        if final_config.content != []:

            # generate config
            nix_options = ToNix(final_config)

            # write new plugin file

            PluginFile(name, homepage, plugin_name, nix_options)

        info(f"Done {i}/{len(plugins)}")

if __name__ == "__main__":
    main()
