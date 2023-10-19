from pprint import pprint
import re
from data import *

from parser_helper import *


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

                case "table_argument":
                    self.code = self._extract_table_argument(node)

                case "tableconstructor":
                    self.code = self._extract_tableconstructor(node)

                # TODO: add other node types

                case _:
                    exit(f"'{node}, ({tag})' not matched in __init__ of Parser")


    def _query(self, data) -> list|None:
        print(data)

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
        return None

    def _extract_table_argument(self, node) -> Table:
        """
        <Node type=table_argument, start_point=(0, 0), end_point=(25, 1)>
        """
        ret = Table()
        for child in node.children:
            match child.type:
                case "comment":
                    # TODO:
                    pass
                case "fieldlist":
                    ret.add(self._extract_fieldlist(child))

        return ret

    def _extract_fieldlist(self, node) -> Fieldlist:
        ret = Fieldlist()
        for child in node.children:
            match child.type:
                case "field":
                    ret.add(self._extract_field(child))
                case "comment":
                    # TODO
                    pass


        return ret


    def _extract_field(self, node) -> Field|Text: # idenfitier, type, value
        """
        Input: show_jumps = true
        """
        n = node.children

        match n[0].type:
            case "identifier":
                identifier = self.extract_code(n[0])
                type_ = n[2].type

                if type_ == "tableconstructor":
                    value = self._extract_tableconstructor(n[2])
                else:
                    value = self.extract_code(n[2])

                return Field(identifier, type_, value)
            case "function_call":
                return Text("".join([ self.extract_code(c).text for c in n ]))
            case "string" | "number":
                return self.extract_code(node)
            case _:
                #  print(node)
                #  self.print_code(node)
                exit(f"Error: Unknown field type ({n[0].type})")


    def _extract_tableconstructor(self, node) -> Table:
        """
        Input: { ... }
        """
        ret = Table()

        for n in node.children:
            match n.type:
                case "comment":
                    continue # TODO:
                case "fieldlist":
                    ret.add(self._extract_fieldlist(n))

        return ret


    def _extract_variable_declaration(self, node) -> VimOption|None:
        """
        [<Node type=variable_declarator, start_point=(3, 4), end_point=(3, 25)>, <Node type="=", start_point=(3, 26), end_point=(3, 27)>, <Node type=boolean, start_point=(3, 28), end_point=(3, 32)>]
        """
        decl = self.extract_code(node.children[0]).text
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

    def _extract_function_call(self, node) -> LuaCode|None:
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


    def extract_code(self, node) -> Text:
        # tree sitter gives us the byte positions, but python will assume unicode characters as 1
        # Therfore, we encode the text to match the positions/lengths
        encoded = self.text.encode('utf8').decode('unicode_escape')
        extracted = encoded[node.start_byte:node.end_byte]
        # do some unicode blackmagic (https://stackoverflow.com/a/52461149)
        t = extracted.encode('latin-1').decode('utf-8')
        return Text(t)


    def print_code(self, node):
        print(self.extract_code(node))
