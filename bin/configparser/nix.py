from parser import LuaCode
from pprint import pprint
from data import *
import subprocess


class ToNix:

    def __init__(self, code_list: list[LuaCode], repo: str):
        #  print("====== OUTPUT ======")

        #  pprint(code_list)

        combined = "["

        for code in code_list:
            combined += "("
            if isinstance(code, Table):
                combined += self._table(code)
            elif isinstance(code, list):
                if isinstance(code, VimFunctionCall):
                    combined += f"''{code.text.text}'';"

                else:
                    combined = combined[:-1]
                    continue
                    #  exit(f"Error: unknown code instance {code}")
            else:
                exit(f"Error: unknown code instance {code}")

            combined += ")"

        combined += "]"
        #  print("combined:", combined)

        file_path = f"./output/{repo}.nix"
        with open(file_path, 'w') as file:
            # Write data to the file
            file.seek(0)
            file.write(f"{combined}")

        subprocess.run(
            ["nixfmt", file_path],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )

    def _table(self, code: Table) -> str:
        inner = ""
        is_list = False
        for c in code.content:
            if isinstance(c, Fieldlist):
                text, is_list = self._fieldlist(c)
                inner += text
            else:
                exit(f"Error: unknown table entry type {c}")

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
            value = f"''{code.value}''"

        string = f"{code.identifier} = {code.type_}Option {value} \"\";"
        return string
