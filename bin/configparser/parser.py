from dataclasses import dataclass
from typing import Any
from pprint import pprint
import re

from parser_helper import *


class Variable: # TODO: rename to LuaCode or similar
    pass

@dataclass
class VimOption(Variable):
    prefix: str # opt, global, etc
    name: str # termguicolors, etc
    value: str # true, false, etc

@dataclass
class VimFunctionCall(Variable):
    text: str

class Parser:
    text: str
    nodes: list
    code = "" # TODO: make code a list

    def __init__(self, data: str):
        self.text = data

        try:
            captures = parse_require(data)
            print("Parsed as require")
        except:
            captures = None

        if captures is None:
            try:
                captures = parse_plugin_set(data)
                print("Parsed as plugin set")
            except:
                captures = None

        if captures is None:
            try:
                captures = parse_plugin_set(data)
                print("Parsed as plugin set")
            except:
                captures = None

        if captures is None:
            exit("Could not parse lua")

        # filter hidden captures
        captures = [ cap for cap in captures if not cap[1].startswith("_") ]

        self.nodes = captures

        for node, tag in self.nodes:
            match tag:
                case "function_body":
                    self.code = self._extract_function_body(node)

    def _extract_variable_declaration(self, node) -> Variable|None:
        """
        [<Node type=variable_declarator, start_point=(3, 4), end_point=(3, 25)>, <Node type="=", start_point=(3, 26), end_point=(3, 27)>, <Node type=boolean, start_point=(3, 28), end_point=(3, 32)>]
        """
        decl = self.extract_code(node.children[0])
        value = self.extract_code(node.children[2])

        if decl.startswith("vim"):

            regex = r"(vim)\.(.{3})\.(.+)"
            matches = re.search(regex, decl)
            if not matches:
                exit("Error: regex could not find any matches")

            matches = matches.groups()

            prefix = matches[1]
            name = matches[2]

            return VimOption(prefix, name, value)
        else:
            print(f"Error: _extract_variable_declaration: unknown child variable children {node.children}")
            exit()

    def _extract_function_call(self, node) -> Variable|None:
        code = self.extract_code(node)
        return VimFunctionCall(code)

    def _extract_function_body(self, node) -> list|None:
        self.print_code(node)

        print()
        output = []
        for child in node.children:
            match child.type:
                case "variable_declaration":
                    code = self._extract_variable_declaration(child)
                    output.append(code)
                case "function_call":
                    code = self._extract_function_call(child)
                    output.append(code)

                case other:
                    print(f"Error: _extract_function_body: unknown child type {other}")
                    exit()
        print()

        return output


    def extract_code(self, node):
        return self.text[node.start_byte:node.end_byte]


    def print_code(self, node):
        print(self.extract_code(node))
