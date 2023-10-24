from dataclasses import dataclass, field
from errors import *

class LuaCode:
    def to_nix(self):
        raise Unimplemented(f"Please implement the 'to_nix' for subclass '{type(self)}'")

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
                print("Content: ", c)
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
    identifier: Text
    type_: str
    value: LuaCode
    comment: Comment

    def to_nix(self):
        return f"{self.identifier} = {self.type_}Option {self.value.to_nix()} \"{self.comment}\";"


@dataclass
class Fieldlist(LuaCode):
    content: list[Field|Text|Table] = field(default_factory=lambda : [])

    def add(self, code: Field|Text|Table|None):
        if code is not None:
            self.content.append(code)
