import subprocess
from log import *

TEMPLATE_PATH="./plugin_template_minimal.nix"
PLUGIN_BASE_PATH="./src/plugins/"
PLUGIN_TEST_BASE_PATH="./plugins/utils/"

class PluginFile:
    """
    Creates a copy of the plugin template and fills in all information
    """

    def __init__(self,
                 name: str,
                 url: str,
                 options: str):

        info(f"Writing plugin file for {name}")

        if name == "" or url == "":
            raise ValueError("name url and plugin_name have to be set")


        module_name = name.lower()
        if name.endswith("-nvim"):
            module_name = name[:-5]


        plugin_path = PLUGIN_BASE_PATH + module_name.lower() + ".nix"

        with open(TEMPLATE_PATH, "r") as f:
            content = f.read()
            debug(f"module_name: {module_name}")
            content = content.replace("PLUGIN_NAME", module_name)
            content = content.replace("PLUGIN_URL", url)
            content = content.replace("# add module options here", options[1:-2])
            content = content.replace("# add neovim plugin here", name)
            print()
            print(content[270:-920])
            print()

            debug(f"Writing file: {plugin_path}")
            try:
                with open(plugin_path, "x") as new_file:
                    new_file.write(content)
            except FileExistsError:
                warning("File exists. Skipping ...")


        # TODO: copy file test

        #  info("Adding new files to git")
        #  subprocess.run(["git", "add", plugin_path])
        #  print("Files added to git.")
