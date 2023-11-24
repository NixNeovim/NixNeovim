import re
from data import *

from parser_helper import *
from log import *
from errors import *


class Parser:
    text: str
    nodes: list

    def parse(self, data: str) -> LuaCode|None:
        self.text = data

        #  print(data)

        captures = self._run_ts_query(data)

        if captures is None:
            warning("Could not query any captures")
            return None

        # filter hidden captures
        self.nodes = [ cap for cap in captures if not cap[1].startswith("_") ]

        assert len(self.nodes) == 1
        node, tag = self.nodes[0]

        match tag:
            case "function_body":
                code = self._extract_function_body(node)

            case "function_call":
                code = self._extract_function_call(node)

            case "table_argument":
                code = self._extract_table_argument(node)

            case "tableconstructor":
                code = self._extract_tableconstructor(node)

            case _:
                exit(f"'{node}, ({tag})' not matched in __init__ of Parser")

        return code

    def _run_ts_query(self, data) -> list|None:
        #  print(data)

        captures = parse_require(data)

        if captures != []:
            debug("Parsed as require")
            return captures

        captures = parse_config_function(data)

        if captures != []:
            debug("Parsed as config function")
            return captures

        captures = parse_config_table(data)

        if captures != []:
            debug("Parsed as config table")
            return captures

        captures = parse_opt_variable(data)

        if captures != []:
            debug("Parsed as options variable")
            return captures

        return None

    def _extract_table_argument(self, node) -> Table:
        """
        <Node type=table_argument, start_point=(0, 0), end_point=(25, 1)>
        """
        ret = Table()
        for child in node.children:
            match child.type:
                case "comment":
                    # TODO: handle comments
                    #  print("comment table argument")
                    #  print(self.extract_code(child))
                    pass
                case "fieldlist":
                    ret.add(self._extract_fieldlist(child))

        return ret

    def _extract_fieldlist(self, node) -> Fieldlist:
        #  print()
        #  self.print_code(node)
        #  print(node.children)
        #  print()
        ret = Fieldlist()
        for child in node.children:
            match child.type:
                case "field":
                    field = self._extract_field(child)
                    if field is not None:
                        ret.add(field)
                case "comment":
                    ret.add_comment(self.extract_code(child))
                case "," | "ERROR":
                    pass
                case _:
                    exit(f"Error: Unhandled fieldlist type {child}")


        return ret


    def _extract_field(self, node) -> Field|Text|Table|None: # idenfitier, type, value
        """
        Input: show_jumps = true
        """
        n = node.children
        first_type = n[0].type

        match first_type:
            case "identifier":
                """
                Format: abc = true,
                """
                if n[1].type == "=":
                    identifier = self.extract_code(n[0])

                    value_node = n[2]

                    type_ = value_node.type
                    if type_ == "tableconstructor":
                        value = self._extract_tableconstructor(value_node)
                    else:
                        value = self.extract_code(value_node)
                else:
                    return Text('"' + self.extract_code(node).text + '"')

                return Field(identifier, type_, value, comment=Comment(""))
            case "function_call":
                return Text("".join([ self.extract_code(c).text for c in n ]))
            case "string" | "number":
                return self.extract_code(node)
            case "tableconstructor":
                return self._extract_tableconstructor(node)
            case "field_left_bracket":
                """
                Format: [ "abc" ] = true,
                """
                if n[3].type == "=":
                    identifier = self.extract_code(n[1])

                    value_node = n[4]

                    type_ = value_node.type
                    if type_ == "tableconstructor":
                        value = self._extract_tableconstructor(value_node)
                    else:
                        value = self.extract_code(value_node)
                else:
                    return Text('"' + self.extract_code(node).text + '"')

                return Field(identifier, type_, value, comment=Comment(""))
            case "ellipsis":
                return None
            case _:
                print()
                print(n[0])
                self.print_code(n[0])
                exit(f"Error: Unknown field type ({n[0].type})")


    def _extract_tableconstructor(self, node) -> Table:
        """
        Input: { ... }
        """
        ret = Table()

        last_comment = None

        print("node.children:", node.children)
        for n in node.children:
            match n.type:
                case "comment":
                    # TODO: handle comments
                    #  print("comment tableconstructor")
                    #  print(self.extract_code(n))
                    last_comment = self.extract_code(n)
                    print("last_comment:", last_comment)

                    continue
                case "fieldlist":
                    #  print(self._extract_fieldlist(n))
                    field_list = self._extract_fieldlist(n)
                    print("field_list:", field_list)
                    print(last_comment is None)
                    if last_comment is not None:
                        print(f"Adding {last_comment} to {field_list}")
                        field_list.add_comment(last_comment)
                        last_comment = None
                    ret.add(field_list)

        exit()
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
            raise Unimplemented(f"Error: _extract_variable_declaration: unknown child variable children {node.children}")

    def _extract_function_call(self, node) -> FunctionCall|None:
        code = self.extract_code(node)
        return FunctionCall(code)

    def _extract_function_body(self, node) -> FunctionBody|None:
        #  output = []
        return FunctionBody(self.extract_code(node))

        #  for child in node.children:
            #  match child.type:
                #  case "variable_declaration":
                    #  code = self._extract_variable_declaration(child)
                    #  output.append(code)
                #  case "function_call":
                    #  code = self._extract_function_call(child)
                    #  output.append(code)

                #  case other:
                    #  print(f"Error: _extract_function_body: unknown child type {other}")
                    #  exit()

        #  # WARN: type error
        #  return output


    def extract_code(self, node) -> Text:
        # tree sitter gives us the byte positions, but python will assume unicode characters as 1
        # Therfore, we encode the text to match the positions/lengths
        encoded = self.text.encode('utf8').decode('unicode_escape')
        extracted = encoded[node.start_byte:node.end_byte]
        # do some unicode blackmagic (https://stackoverflow.com/a/52461149)
        t = extracted.encode('latin-1').decode('utf-8')
        return Text(t)


    def print_code(self, node):
        debug(self.extract_code(node))
