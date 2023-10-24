from data import *
import subprocess
import subprocess
from logging import info, debug
from errors import *

def format_nix(code: str) -> str:

    info("Formatting nix output")

    # Pipe the output of the first command into another command
    cmd2 = "nixfmt"

    p2 = subprocess.Popen(cmd2, shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE, text=True)
    p2.communicate(input=code)

    # Read the output of the second command
    output = p2.communicate()[0]

    # Decode and print the output
    return output


class ToNix:
    code: str = ""

    def __init__(self, code: Table):

        code_string = ""

        if isinstance(code, Table):
            code_string += code.to_nix()#self._table(code)
        elif isinstance(code, list):
            if isinstance(code, FunctionCall):
                code_string += f"''{code.text.text}'';"
            else:
                raise Unimplemented(f"Error: unknown code instance {code}")
        else:
            raise Unimplemented(f"Error: unknown code instance {code}")

        try:
            self.code = format_nix(code_string)
        except:
            raise RuntimeError("Could not format nix code")


    def _table(self, code: Table) -> str:
        inner = ""
        is_list = False
        for c in code.content:
            if isinstance(c, Fieldlist):
                text, is_list = self._fieldlist(c)
                inner += text
            elif isinstance(c, Field):
                inner += self._field(c)
            elif isinstance(c, Text):
                is_list = True
                inner += " " + c.text.replace("'", "\"")
            elif isinstance(c, Table):
                is_list = True
                inner += self._table(c)
            else:
                print(f"Error: unknown table entry type {c}")

        if is_list:
            ret = f"[ {inner} ]"
        else:
            ret = f"{{ {inner} }}"
        return ret

    def _fieldlist(self, code: Fieldlist) -> tuple[str,bool]:
        ret = ""
        is_list = False
        for c in code.content:
            if isinstance(c, Field):
                is_list = False
                ret += self._field(c)
            elif isinstance(c, Text):
                is_list = True
                ret += f"''{c.text}''"
            else:
                exit(f"Error: unknown field entry type {c}")

        return ret, is_list

    def _field(self, code: Field) -> str:

        if isinstance(code.value, Table):
            value = self._table(code.value)
        else:
            value = f"'' {code.value} ''"

        string = f"{code.identifier} = {code.type_}Option {value} \"Description text\";"
        return string

    def __str__(self) -> str:
        return self.code

    def __repr__(self) -> str:
        return self.code
