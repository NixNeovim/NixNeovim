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

        captures = self._query(data)

        # filter hidden captures
        self.nodes = [ cap for cap in captures if not cap[1].startswith("_") ]

        for node, tag in self.nodes:
            match tag:
                case "function_body":
                    self.code = self._extract_function_body(node)

                case "function_call":
                    self.code = self._extract_function_call(node)

                case other:
                    exit(f"{other} not matched in __init__ of Parser")


    def _query(self, data) -> list:
        #  print(data)

        captures = parse_require(data)

        if captures != []:
            print("Parsed as require")
            return captures

        captures = parse_config_function(data)

        if captures != []:
            print("Parsed as config function")
            return captures

        captures = parse_config_table(data)

        if captures != []:
            print("Parsed as config table")
            return captures


        # error state
        exit("Could not parse lua")


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
