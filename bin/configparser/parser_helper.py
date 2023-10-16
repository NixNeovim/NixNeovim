from tree_sitter import Parser as TSParser
from tree_sitter import Language
from pprint import pprint

Language.build_library(
  # Store the library in the `build` directory
  'build/my-languages.so',

  # Include one or more languages
  [
    './bin/configparser/tree-sitter-lua',
  ]
)

LUA_LANGUAGE = Language('build/my-languages.so', 'lua')
parser = TSParser()
parser.set_language(LUA_LANGUAGE)

fieldlist_string = """
    (fieldlist
        (field
            name: (identifier)
            [
                value: (tableconstructor)
                value: (string)
                value: (number)
                value: (boolean)
            ]
        )
    ) @table
"""

# NOTE:
# use '_' as prefix to hide captures

#  query = LUA_LANGUAGE.query(f"""
    #  [
        #  (table_argument
            #  {fieldlist_string}
        #  )
        #  (tableconstructor
            #  {fieldlist_string}
        #  )
        #  (
            #  (field
                #  ((identifier) @_config_var
                    #  (#eq? @_config_var "config"))
                #  (function
                    #  (function_body) @function_body))
        #  )
    #  ]
    #  """)

def parse_require(data):
    exit("TODO: parse_require")
    query = LUA_LANGUAGE.query(f"""
        (table_argument
            {fieldlist_string}
        )
        """)

    print(data)
    tree = parser.parse(bytes(data, "utf8"))
    pprint(tree.root_node.sexp())
    print()
    captures = query.captures(tree.root_node)
    return captures


def parse_plugin_set(data):
    query = LUA_LANGUAGE.query(f"""
        (
            (field
                ((identifier) @_config_var
                    (#eq? @_config_var "config"))
                (function
                    (function_body) @function_body))
        )
        """)

    #  print(data)
    tree = parser.parse(bytes(data, "utf8"))
    #  pprint(tree.root_node.sexp())
    #  print()
    captures = query.captures(tree.root_node)
    #  print("captures:", captures)
    return captures
