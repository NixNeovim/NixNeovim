from dataclasses import dataclass, field

class LuaCode:
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
        if isinstance(code, Fieldlist):
            self.content.extend(code.content)
        elif code is not None:
            self.content.append(code)

    def merge(self, table):
        self.content += table.content
        #  if self.content == []:
            #  self.content = table.content
        #  elif table.content == []:
            #  pass
        #  else:
            #  for code_new in table.content:
                #  for code in self.content:
                    #  if isinstance(code_new, Field) and isinstance(code, Field):
                        #  if code_new.identifier != code.identifier:
                            #  self.content.append(code_new)
                        #  elif code_new == code:
                            #  pass
                        #  else:
                            #  print(f"Field duplicate\n - {code_new}\n - {code}")
                    #  else:
                        #  #  print("passing merge")
                        #  print(type(code))
                        #  print(type(code_new))
                        #  print(code_new)
                        #  print()
                        #  # TODO: work needed here?

    def clean(self):
        self.content = list(filter(lambda x: isinstance(x, Field), self.content))

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
