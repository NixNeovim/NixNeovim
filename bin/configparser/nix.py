from parser import LuaCode
from pprint import pprint
from data import *


class ToNix:

    def __init__(self, code_list: list[LuaCode], repo: str):
        #  print("====== OUTPUT ======")

        pprint(code_list)

        combined = ""

        for code in code_list:
            if isinstance(code, Table):
                combined += self._table(code)
            elif isinstance(code, list):
                if isinstance(code, VimFunctionCall):
                    combined += code.text.text
                #  else: TODO
                    #  exit(f"Error: unknown code instance {code}")
            else:
                exit(f"Error: unknown code instance {code}")

        file_path = f"./output/{repo}.txt"
        with open(file_path, 'w') as file:
            # Write data to the file
            file.seek(0)
            file.write(f"{combined}")

    def _table(self, code: Table) -> str:
        ret = "{"
        for c in code.content:
            if isinstance(c, Fieldlist):
                ret += self._fieldlist(c)
            else:
                exit(f"Error: unknown table entry type {c}")

        ret += "}"
        return ret

    def _fieldlist(self, code: Fieldlist) -> str:
        ret = ""
        for c in code.content:
            if isinstance(c, Field):
                ret += self._field(c)
            elif isinstance(c, Text):
                ret += c.text
            else:
                exit(f"Error: unknown field entry type {c}")

        return ret

    def _field(self, code: Field) -> str:

        if isinstance(code.value, Table):
            value = self._table(code.value)
        else:
            value = code.value

        string = f"{code.identifier} = {code.type_}Option {value} \"\";"
        return string
