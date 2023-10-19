import re
from dataclasses import dataclass
from pprint import pprint
from parser import Parser

# global variables

lastComment = ""
indent = ""
lines = []
data = ""

@dataclass
class Option:
    options = {}

    def add(self, name, type, default, comment = ""):
        data = {
            "type": type,
            "default": default,
            "comment": comment
        }
        self.options.update({name: data})

@dataclass
class Output:
    text = ""
    isList = False

    def add(self, text, end="\n"):
        self.text += text
        self.text += end

    def prepend(self, text, end="\n"):
        self.text = text + end + self.text

    def append(self, output):
        self.text += output.text

def to_comment(node):
    global lastComment
    text = extract(node)

    text = re.sub(r'^-- ?', '', text)
    text = re.sub(r'"', '\"', text)

    lastComment = text
    #  print(indent, "#", text)
    return f"{indent}# {text}"

def extract(node) -> str:
    return data[node.start_byte:node.end_byte]

def to_camel_case(snake_str):
    camel_string = "".join(x.capitalize() for x in snake_str.lower().split("_"))
    return snake_str[0].lower() + camel_string[1:]

def parse_field(node) -> Output:
    global lastComment
    name = node.child_by_field_name("name") # name node
    value = node.child_by_field_name("value") # value node

    output = Output()

    if name is None:
        output.add(f"{indent}{extract(value)}")
        output.isList = True
        return output

    if value is None:
        print(f"Field {name} has no value")
        exit()

    camelName = to_camel_case(extract(name))
    # conver to nix code based on type
    match value.type:
        case "tableconstructor":
            #  print(indent, extract(name), "=", end="")
            output.add(f"{indent}{camelName} = ", end="")
            tableOutput = parse_table(value.children)
            output.append(tableOutput)
            return output
        case "function":
            #  print(indent, "'lua function'")
            return output
        case "nil":
            #  print(indent, "'nil'")
            output.add(f"{indent}{camelName} = 'nil';")
            return output
        case "number":
            typeString = "intOption"
        case "boolean":
            typeString = "boolOption"
        case "string":
            typeString = "strOption"
        case type:
            #  print(f"UNKNOWN ({type})")
            output.add(f"UNKNOWN ({type})")
            return output

    #  print(indent, extract(name), "=", typeString, extract(value), f"\"{lastComment}\";")
    output.add(f"{indent}{camelName} = {typeString} {extract(value)} \"{lastComment}\";")
    return output

# input node: field list
def parse_table(children):
    global indent

    output = Output()

    isList = False

    for child in children:
        match child.type:
            case "{":
                #  print("", "{")
                #  output.add("{")
                indent += "  "
            case "}":
                indent = indent[:-2]
                #  print(indent, "};")
                #  output.add(f"{indent}}};")
            case "comment":
                #  print_comment(child)
                output.add(to_comment(child))
                pass
            case "fieldlist": # content of the table
                for node in child.children:
                    match node.type:
                        case ",":
                            continue
                        case "comment":
                            output.add(to_comment(node))
                            pass
                        case "field":
                            fieldOutput = parse_field(node)
                            output.append(fieldOutput)
                            isList = fieldOutput.isList

    if isList:
        output.prepend("listOption [")
        output.add(f"{indent}] \"\";")
    else:
        output.prepend("{")
        output.add(f"{indent}}};")


    return output

def is_setup_function(node) -> bool:
    try:
        return extract(node.children[2]) == "setup"
    except:
        return False

def extract_field(field_node) -> dict|None: # idenfitier, type, value
    """
    Input: show_jumps = true
    """
    n = field_node.children

    if n[0].type != "identifier":
        return None

    identifier = extract(n[0])
    type_ = n[2].type

    if type_ == "tableconstructor":
        value = extract_table(n[2])
    else:
        value = extract(n[2])

    data = {
        "type": type_,
        "value": value
    }

    return { identifier: data }

def extract_field_list(fieldlist):
    ret = {}

    for field in fieldlist.children:
        if field.type == "field":
            data = extract_field(field)
            if data is not None:
                ret.update(data)

    return ret

def extract_table(table_node) -> dict:
    """
    Input: { ... }
    """
    table_entries = table_node.children

    ret = {}

    for n in table_entries:
        match n.type:
            case "{" | "}":
                continue
            case "comment":
                continue # TODO: handle comments
            case "fieldlist":
                ret = ret | extract_field_list(n)

    return ret

def extract_setup_table(node) -> dict|None:
    match node.type:
        case "fieldlist":
            return extract_field_list(node.next_sibling)
        case "comment":
            return None
        case "variable_declaration":
            if is_setup_function(node):
                return extract_table(node.children[3])

def extract_function_body(node) -> dict|None:
    return None

def parse(lua: Parser, name):

    captures = lua.nodes
    #  print("captures:", captures)

    if len(captures) == 0 or len(captures[0]) == 0:
        print("Captures empty")
        return

    # go through nodes and parse

    # ...


    setup = extract_field_list(captures[0][0])

    if setup == {}:
        print("No setup function found")
        return

    #  pprint(setup)
    file_path = f"./output/{name}.txt"
    with open(file_path, 'w') as file:
        # Write data to the file
        file.seek(0)
        file.write(f"{setup}")
