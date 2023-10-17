from dataclasses import dataclass, field

class LuaCode: # TODO: rename to LuaCode or similar
    pass

@dataclass
class Text(LuaCode):
    text: str

    def __str__(self) -> str:
        return self.text

@dataclass
class VimOption(LuaCode):
    prefix: str # opt, global, etc
    name: str # termguicolors, etc
    value: Text # true, false, etc

@dataclass
class VimFunctionCall(LuaCode):
    text: Text

@dataclass
class Table(LuaCode):
    content: list[LuaCode] = field(default_factory=lambda : [])

    def add(self, code: LuaCode|None):
        if code is not None:
            self.content.append(code)

@dataclass
class Fieldlist(LuaCode):
    content: list[LuaCode] = field(default_factory=lambda : [])

    def add(self, code: LuaCode|None):
        if code is not None:
            self.content.append(code)

@dataclass
class Field(LuaCode):
    identifier: Text
    type_: str
    value: LuaCode
