
import subprocess

TEMPLATE_PATH="./plugin_template_minimal.nix"
PLUGIN_BASE_PATH="./src/plugins/"
PLUGIN_TEST_BASE_PATH="./plugins/utils/"

class PluginFile:
    """
    Creates a copy of the plugin template and fills in all information
    """

    def __init__(self,
                 name,
                 url,
                 plugin_name,
                 options):

        if name == "" or url == "" or plugin_name == "":
            raise ValueError("name url and plugin_name have to be set")

        plugin_path = PLUGIN_BASE_PATH + name + ".nix"

        with open(TEMPLATE_PATH, "r") as f:
            content = f.read()
            content = content.replace("PLUGIN_NAME", name)
            content = content.replace("PLUGIN_URL", url)
            content = content.replace("# add module options here", options.code[1:-1])
            content = content.replace("# add neovim plugin here", plugin_name)
            print(content)

            # WARN: replace "w" with "x", to not override existing files
            with open(plugin_path, "w") as new_file:
                new_file.write(content)


        # TODO: copy file test

        #  subprocess.run(["git", "add", plugin_path])
        #  print("Files added to git.")
