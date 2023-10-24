import requests
import base64
import re
from pprint import pprint
from bs4 import BeautifulSoup
import mistune
import os
from logging import info, debug, warning, error


def get_language(repo):
    url = f'https://api.github.com/repos/{repo}'
    response = requests.get(url)
    if response.status_code == 200:
        return response.json()["language"]
    else:
        debug("Fetching language from:", url)
        return f"unknown ({response.status_code})"

def download_readme(repo) -> str|None:
    url = f'https://api.github.com/repos/{repo}/readme'
    debug(f"https://github.com/{repo}")

    repo_file = repo.replace("/", "-")
    file_path = f"./readmes/{repo_file}.txt"

    if os.path.exists(file_path):
        # Open a file for reading
        with open(file_path, 'r') as file:
            # Read the entire file contents into a string
            content = file.read()
    else:

        debug(f"Downloading readme {repo}")

        l = get_language(repo)
        if l != "Lua":
            debug(f"Language is not lua: ({l})")
            return None

        # Get the README content from the GitHub API
        response = requests.get(url)
        if response.status_code == 200:
            readme_content = response.json()["content"]

            # Decode the content
            content = base64.b64decode(readme_content).decode('utf-8')

            # Open a file for writing (creates the file if it doesn't exist)
            with open(file_path, 'w') as file:
                # Write data to the file
                file.seek(0)
                file.write(content)
        else:
            error(f"Status code {response.status_code}")
            return None

    return content

def extract_sections(readme):
    lua_code_blocks = {}
    in_code_block = False
    current_section = None
    code_block = ""

    #  with open(markdown_file, 'r') as file:
    for line in readme.split('\n'):
        # Check for section titles
        section_match = re.match(r'^## (.+)', line)
        if section_match:
            # Save the previous section's code block if any
            if current_section and code_block:
                lua_code_blocks[current_section] = code_block
            # Update the current section title
            current_section = section_match.group(1)
            code_block = ""

        # Check for code blocks
        if line.strip() == "```lua":
            code_block = ""
            in_code_block = True
        elif in_code_block and line.strip() != "```":
            code_block += line
        elif in_code_block and line.strip() == "```":
            in_code_block = False

    # Save the last section's code block if any
    if current_section and code_block:
        lua_code_blocks[current_section] = code_block

    return lua_code_blocks

def tag_is_title_or_lua(tag) -> bool:
    """
    Returns True if the input html tag is either a title or a lua code block
    """
    title = tag.name in ['h1', 'h2', 'h3', 'h4', 'h5', 'h6']
    lua = tag.name == "code" and tag.has_attr("class") and tag["class"][0] == "language-lua"

    return title or lua

def parse_readme(repo) -> list[str]|None:

    info(f"Parsing {repo}")

    readme_content = download_readme(repo)

    if readme_content is None:
        return None

    html = mistune.html(readme_content)
    soup = BeautifulSoup(html, 'html.parser')

    blocks = soup.find_all(tag_is_title_or_lua)

    parsed = {}
    current_header = ""
    current_content = []

    for block in blocks:
        if block.name == "code": # html tag type
            current_content.append(block.contents[0])

        else: # header
            if current_header != "":
                parsed.update({current_header: current_content})
                current_content = []

            current_header = block.contents[0]

    parsed.update({current_header: current_content})

    config_section = ["Configuration", "Config", "Usage", "Default configuration", "Installation", "Setup", "Example config", "Full Configuration"]

    # combined sections and lua blocks to one list of lua code blocks
    lua_blocks = []
    for section, content in parsed.items():
        if section in config_section and content != []:
            lua_blocks.extend(content)

    if len(parsed) == 0:
        warning("Could not determin config section")
        #  pprint(parsed)
        #  print()
        return None

    return lua_blocks
