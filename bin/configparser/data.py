from dataclasses import dataclass, field
from errors import *

class LuaCode:
    def to_nix(self):
        raise Unimplemented(f"Please implement the 'to_nix' function for subclass '{type(self)}'")


@dataclass
class Text(LuaCode):
    text: str

    def __post_init__(self):
        self.text = self.text.replace("'", "\"")

    def __str__(self) -> str:
        return self.text

    def __repr__(self) -> str:
        return self.__str__()

    def to_nix(self) -> str:
        return self.text

@dataclass
class Comment(Text):
    pass

@dataclass
class VimOption(LuaCode):
    prefix: str # opt, global, etc
    name: str # termguicolors, etc
    value: Text # true, false, etc

@dataclass
class FunctionCall(LuaCode):
    text: Text

@dataclass
class FunctionBody(LuaCode):
    body: Text


@dataclass
class Table(LuaCode):
    content: list[LuaCode] = field(default_factory=lambda : [])

    def add(self, code: LuaCode|None):
        if isinstance(code, Fieldlist):
            self.content.extend(code.content)
        elif code is not None:
            self.content.append(code)

    def merge(self, table):
        self.content += table.content

    def clean(self):
        self.content = list(filter(lambda x: isinstance(x, Field), self.content))

    def is_list(self) -> bool:
        """Returns True if the source lua code is a list; False when lua was table"""

        for c in self.content:
            if not isinstance(c, Field):
                return True
        else:
            return False

    def to_nix(self) -> str:
        nix_code = ""

        for c in self.content:
            if isinstance(c, Fieldlist):
                raise Unimplemented("Please handle field_list in to_nix of Table")
                #  text, is_list = self._fieldlist(c)
                #  nix_code += text
            elif isinstance(c, Field|Table):
                nix_code += c.to_nix()
            elif isinstance(c, Text):
                nix_code += " " + c.to_nix()
            else:
                print(f"Error: unknown table entry type {c}")

        if self.is_list():
            nix_code = f"[ {nix_code} ]"
        else:
            nix_code = f"{{ {nix_code} }}"

        return nix_code


@dataclass
class Field(LuaCode):
    # content_type can be:
    # - nil
    # - boolean
    # - number
    # - string
    # - ellipsis
    # - function/function_call/identifier
    # - prefix_exp
    # - tableconstructor
    # - binary_operation
    # - unary_operation
    identifier: Text
    content_type: str
    value: LuaCode
    comment: Comment

    def to_nix(self):

        match self.content_type:
            case "ERROR":
                t = "ERROR"
            case "boolean":
                t = "bool"
            case "number":
                t = "int"
            case "string":
                t = "str"
            case "nil" | "function" | "function_call" | "binary_operation" | "identifier":
                t = "rawLua"
            case "tableconstructor":
                t = "attrs"
            case other:
                raise Unimplemented(f"{other} ({self.value})")

        if t == "attrs":
            return f"{self.identifier} = {self.value.to_nix()};" # TODO: add comments to output
        elif t == "rawLua":
            return f"{self.identifier} = {t}Option ''{self.value.to_nix()}'' \"{self.comment}\";"
        else:
            return f"{self.identifier} = {t}Option {self.value.to_nix()} \"{self.comment}\";"


@dataclass
class Fieldlist(LuaCode):
    content: list[Field|Text|Table] = field(default_factory=lambda : [])

    def add(self, code: Field|Text|Table|None):
        if code is not None:
            self.content.append(code)
