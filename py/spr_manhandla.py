#!/usr/bin/env python3

from dataclasses import dataclass, field
from asmgen import ToAsm, ToAsmD, ToAsmLabel

MAN_N = 0 # null
MAN_L = 1
MAN_R = 2
MAN_U = 4
MAN_D = 8

@dataclass
class LSpr:
    name: str
    # placement of lower left corner, if applied to 16x16 bitmap
    x: int
    y: int
    h: int
    mirror: int

@dataclass
class RSpr:
    name: str
    # placement of lower left corner, if applied to 16x16 bitmap
    x: int
    y: int
    h: int
    mirror: int

@dataclass
class SprVector:
    name: str

    label: list = field(default_factory=list)
    x: list = field(default_factory=list)
    y: list = field(default_factory=list)
    h: list = field(default_factory=list)
    mirror: list = field(default_factory=list)

    def AddSpr(self, spr:LSpr, backup):
        if spr is None:
            spr = backup #LSpr("SprItem0" , 0, 0, 4, 0)

        self.label.append(spr.name)
        self.x.append(spr.x)
        self.y.append(spr.y)
        self.h.append(spr.h)
        self.mirror.append(spr.mirror)

    def GenPosXTable(self):
        output = f"{self.name}_x:\n"
        output += ToAsmD([x * 2-1 for x in self.x])
        return output

    def GenPosYTable(self):
        output = f"{self.name}_y:\n"
        output += ToAsmD([y * 2 for y in self.y])
        return output

    def GenSprHTable(self):
        output = f"{self.name}_SprH:\n"
        output += ToAsmLabel([f'#<{s}' for s in self.label])
        return output

    def GenSprLTable(self):
        output = f"{self.name}_SprL:\n"
        output += ToAsmLabel([f'#>{s}' for s in self.label])
        return output

    @staticmethod
    def GenHF(lspr : LSpr, rspr: RSpr):
        # sprite height and flags
        data = []

        for i in range(0, 16):
            # %1xxx_xxxx = left mirror
            # %xxxx_111x = left height
            # %xxxx_xxx1 = right mirror
            # %x111_xxxx = right height
            val = 0
            val |= (lspr.mirror[i] & 1) << 7
            val |= (rspr.mirror[i] & 1)

            val |= (((lspr.h[i]>>1) - 1) & 7) << 1
            val |= (((rspr.h[i]>>1) - 1) & 7) << 4
            data.append(val)

        output = "Manhandla_FlagsHeight:\n"
        output += ToAsm(data)
        return output


full_data = {
    MAN_U | MAN_D | MAN_L | MAN_R : (
        LSpr("SprManhandla16_0", 0, 0, 16, 0),
        RSpr("SprManhandla16_1", 8, 0, 16, 0)
    ),
    MAN_U | MAN_D | MAN_L |   0   : [
        LSpr("SprManhandla16_2", 4, 0, 16, 0),
        RSpr("SprManhandla8_1" , 0, 4, 8, 0)
    ],
    MAN_U | MAN_D |   0   | MAN_R : [
        LSpr("SprManhandla16_2", 4, 0, 16, 0),
        RSpr("SprManhandla8_1" , 8, 4, 8, 1)
    ],
    MAN_U | MAN_D |   0   |   0   : [
        LSpr("SprManhandla16_2", 4, 0, 16, 0),
        None
    ],
    MAN_U |   0   | MAN_L | MAN_R : [
        LSpr("SprManhandla12_0", 0, 4, 12, 0),
        RSpr("SprManhandla12_1", 8, 4, 12, 0)
    ],
    MAN_U |   0   | MAN_L |   0   : [
        LSpr("SprManhandla12_4", 4, 4, 12, 0),
        RSpr("SprManhandla8_1" , 0, 4, 8, 0)
    ],
    MAN_U |   0   |   0   | MAN_R : [
        LSpr("SprManhandla12_4", 4, 4, 12, 0),
        RSpr("SprManhandla8_1" , 8, 4, 8, 1)
    ],
    MAN_U |   0   |   0   |   0   : [
        LSpr("SprManhandla12_4", 4, 4, 12, 0),
        None
    ],
      0   | MAN_D | MAN_L | MAN_R : [
        LSpr("SprManhandla12_2", 0, 0, 12, 0),
        RSpr("SprManhandla12_3", 8, 0, 12, 0)
    ],
      0   | MAN_D | MAN_L |   0   : [
        LSpr("SprManhandla12_5", 4, 0, 12, 0),
        RSpr("SprManhandla8_1" , 0, 4, 8, 0)
    ],
      0   | MAN_D |   0   | MAN_R : [
        LSpr("SprManhandla12_5", 4, 0, 12, 0),
        RSpr("SprManhandla8_1" , 8, 4, 8, 1)
    ],
      0   | MAN_D |   0   |   0   : [
        LSpr("SprManhandla12_5", 4, 0, 12, 0),
        None
    ],
      0   |   0   | MAN_L | MAN_R : [
        LSpr("SprManhandla8_0" , 0, 4, 8, 0),
        RSpr("SprManhandla8_0" , 8, 4, 8, 1)
    ],
      0   |   0   | MAN_L |   0   : [
        LSpr("SprManhandla8_0" , 0, 4, 8, 0),
        None
    ],
      0   |   0   |   0   | MAN_R : [
        RSpr("SprManhandla8_0" , 8, 4, 8, 1), # right sprite
        None
    ],
      0   |   0   |   0   |   0   : [
        LSpr("SprItem0" , 0, 0, 4, 0),
        None
    ],
}

lvec = SprVector("ManhandlaL")
rvec = SprVector("ManhandlaR")

for i in range(0, 16):
    lspr, rspr = full_data[i]
    lvec.AddSpr(lspr, rspr)
    rvec.AddSpr(rspr, lspr)

output = ""
output += lvec.GenPosXTable()
output += rvec.GenPosXTable()
output += lvec.GenPosYTable()
output += rvec.GenPosYTable()
output += lvec.GenSprHTable()
output += rvec.GenSprHTable()
output += lvec.GenSprLTable()
output += rvec.GenSprLTable()
output += SprVector.GenHF(lvec, rvec)

with open("gen/EnDraw_BossManhandlaGen.asm", "w") as file:
    file.write(output)