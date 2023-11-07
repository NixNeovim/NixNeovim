from tree_sitter import Parser as TSParser
from tree_sitter import Language
from pprint import pprint

Language.build_library(
  # Store the library in the `build` directory
  'build/my-languages.so',

  # Include one or more languages
  [
    './tree-sitter-lua',
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
    function_call_string = """
        ((function_call
            (function_call
                ((identifier) @_function_id
                 (#eq? @_function_id "require")))
                (function_arguments
                    (tableconstructor) @tableconstructor)))
    """
    query = LUA_LANGUAGE.query(f"""
        [
            (program
                {function_call_string}
            )
            (function_body
                {function_call_string}
            )
        ]
        """)

    #  print(data)
    tree = parser.parse(bytes(data, "utf8"))
    #  print(tree.root_node.sexp())
    #  print()
    captures = query.captures(tree.root_node)
    #  print("captures:", captures)
    #  print()
    return captures


def parse_config_function(data):
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

def parse_config_table(data):
    # TODO: do not capture non-config tables
    query = LUA_LANGUAGE.query(f"""
        (program
            (function_call
                (table_argument) @table_argument)
        )
        """)

    #  print(data)
    tree = parser.parse(bytes(data, "utf8"))
    #  print(tree.root_node.sexp())
    #  print()
    captures = query.captures(tree.root_node)
    #  print("captures:", captures)
    #  print()
    return captures

def parse_opt_variable(data):
    query = LUA_LANGUAGE.query(f"""
        (program
            (variable_declaration
                (variable_declarator)
                (tableconstructor) @tableconstructor)
        )
        """)

    #  print(data)
    tree = parser.parse(bytes(data, "utf8"))
    #  print(tree.root_node.sexp())
    #  print()
    captures = query.captures(tree.root_node)
    #  print("captures:", captures)
    #  print()
    return captures
