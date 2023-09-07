from tree_sitter import Language, Parser
import re
import fileinput
from dataclasses import dataclass


data = ''
for line in fileinput.input():
    data += line

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
        

Language.build_library(
  # Store the library in the `build` directory
  'build/my-languages.so',

  # Include one or more languages
  [
    './bin/configparser/tree-sitter-lua',
  ]
)

indent = ""
lastComment = ""

def to_comment(node):
    global lastComment
    text = extract(node)

    text = re.sub(r'^-- ?', '', text)
    text = re.sub(r'"', '\"', text)

    lastComment = text
    #  print(indent, "#", text)
    return f"{indent}# {text}"

def extract(node):
    linenumber = node.start_point[0]
    start = node.start_point[1]
    end = node.end_point[1]
    return lines[linenumber][start:end]

def to_camel_case(snake_str):
    camel_string = "".join(x.capitalize() for x in snake_str.lower().split("_"))
    return snake_str[0].lower() + camel_string[1:]

def parse_field(node) -> Output:
    global lastComment
    name = node.child_by_field_name("name") # name node
    value = node.child_by_field_name("value") # value node

    output = Output()

    if name is None:
        #  print("# TODO: Field has no nam cue. Assuming it's a list")
        #  print(indent, extract(value)) # TODO: print as list
        #  output.add("# TODO: Field has no nam cue. Assuming it's a list")
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
                            #  print_comment(node)
                            output.add(to_comment(node))
                            pass
                        case "field":
                            fieldOutput = parse_field(node)
                            output.append(fieldOutput)
                            isList = fieldOutput.isList
                            #  print(output.text)

    if isList:
        output.prepend("listOption [")
        output.add(f"{indent}] \"\";")
    else:
        output.prepend("{")
        output.add(f"{indent}}};")
            

    return output


LUA_LANGUAGE = Language('build/my-languages.so', 'lua')
parser = Parser()
parser.set_language(LUA_LANGUAGE)

lines = data.split('\n')
tree = parser.parse(bytes(data, "utf8"))

cursor = tree.walk()
assert cursor.node.type == "program"
assert cursor.goto_first_child()
assert cursor.node.type == "function_call" # requrie call
args = cursor.node.child_by_field_name("args")

if args is None:
    print("Could not detect args")
    exit()

cursor = args.walk()
assert cursor.goto_first_child() # setup call
assert cursor.node.type == "tableconstructor" # requrie call
children = cursor.node.children
output = parse_table(children) # parse setup
print(output.text)
