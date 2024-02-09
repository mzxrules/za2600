#!/usr/bin/env python3
from asmgen import ToAsm, ToAsmD
from dataclasses import dataclass, field
from typing import List, Tuple
from func_common import ToSnakeCase

SPAWN_PATTERN = [
    [""],
    ["EnNone"],
    ["En_Octorok"] * 1,
    ["En_Octorok"] * 2,
    ["En_OctorokBlue"] * 1,
    ["En_OctorokBlue"] * 2,
    ["En_Octorok", "En_OctorokBlue"] * 1,
    ["En_Octorok", "En_OctorokBlue", "En_Octorok"] * 1,
    ["En_OctorokBlue", "En_Octorok", "En_OctorokBlue"] * 1,

    ["En_Tektite"] * 2,
    ["En_Tektite"] * 3,

    ["En_TektiteBlue"] * 2,
    ["En_TektiteBlue"] * 3,

    ["En_Leever"] * 2,
    ["En_LeeverBlue"] * 2,
    ["En_LeeverBlue"] * 3,
    ["En_LeeverBlue", "En_Leever"] * 2,

    ["En_Peehat"] * 2,
    ["En_Peehat"] * 3,
    ["En_Peahat", "En_Octorok", "En_Peahat"],
    ["En_Peahat", "En_OctorokBlue", "En_Peahat"],
    ["En_Moblin"] * 1,
    ["En_Moblin"] * 2,
    ["En_Moblin"] * 3,
    ["En_MoblinBlue"] * 1,
    ["En_MoblinBlue"] * 2,
    ["En_MoblinBlue"] * 3,

    ["En_Lynel"],
    ["En_Lynel"] * 2,
    ["En_Lynel"] * 3,
    ["En_LynelBlue"] * 1,
    ["En_LynelBlue"] * 4,
    ["En_LynelBlue", "En_Peehat", "En_Lynel"] * 1,
    ["En_Lynel", "En_Peehat", "En_LynelBlue"] * 1,

    ["En_RollingRock"] * 2,

    ["En_Moblin"] * 1,
    ["En_Moblin"] * 2,
    ["En_Moblin"] * 3,

    ["En_Keese"] * 1,
    ["En_Keese"] * 2,
    ["En_Keese"] * 3,

    ["En_Gel"] * 2,
    ["En_Gel"] * 3,

    ["En_Zol"] * 2,
    ["En_Zol"] * 3,
    ["En_Zol"] * 4,
    ["En_Zol", "En_Keese", "En_Zol"],

    ["En_Stalfos"] * 2,
    ["En_Stalfos"] * 3,
    ["En_Stalfos"] * 4,

    ["En_Goriya"] * 3,
    ["En_GoriyaBlue"] * 3,

    ["En_Rope"] * 2,
    ["En_Rope"] * 3,
    ["En_Rope"] * 4,

    ["En_Vire"] * 2,
    ["En_Vire"] * 3,
    ["En_Vire"] * 4,

    ["En_Pols"] * 3,
    ["En_Pols"] * 4,

    ["En_Gibdo"] * 2,
    ["En_Gibdo"] * 3,
    ["En_Gibdo"] * 4,
    ["En_Gibdo", "En_Keese", "En_Gibdo"] * 1,
    ["En_Gibdo", "En_Keese", "En_Pols"] * 1,

    ["En_Darknut"] * 3,
    ["En_Darknut"] * 4,
    ["En_Darknut"] * 5,

    ["En_DarknutBlue"] * 3,
    ["En_DarknutBlue"] * 4,
    ["En_DarknutBlue"] * 5,

    ["En_LikeLike"] * 4,

    ["En_LikeLike", "En_Zol", "En_LikeLike"] * 1,
    ["En_LikeLike", "En_Wizrobe", "En_WizrobeBlue"] * 1,
    ["En_LikeLike", "En_Wizrobe", "En_WizrobeBlue"] * 2,

    ["En_Wizrobe", "En_WizrobeBlue"] * 1,
    ["En_Wizrobe", "En_WizrobeBlue"] * 2,

    ["En_Wizrobe"] * 4,
    ["En_WizrobeBlue"] * 3,

    ["En_Wallmaster"],

    ["En_BossGhini"],

    ["En_BossGohma"],
    ["En_BossGlock"],
    ["En_BossAqua"],
    ["En_BossManhandla"],
    ["En_BossDon"],
    ["En_BossDig"],
    ["En_BossPatra"],
    ["En_BossGanon"],
    ["En_TestMissile"],
    ["En_TestColor"]
]

def GenerateEncounterDisplay(spawnPatterns):
    displayStrings = []
    for pattern in spawnPatterns:
        displayStr = ", ".join([ToSnakeCase(item) for item in pattern])
        displayStrings.append(displayStr)
    return displayStrings

def GenerateEditorBindings(displayStrings):
    out = ""
    length = len(displayStrings)

    out += f'set "EnCount" to {length}\n'
    out += f'set "EnCountExpected" to {length}\n'

    for i in range(length):
        out += f'set "$Encounter{i}" to "{displayStrings[i]}"\n'
        i += 1

    with open(f'gen/editor_en_bindings.txt', "w") as file:
        file.write(out)



def flatten_spawnpattern():
    return [item for row in SPAWN_PATTERN for item in row]

displayStr = GenerateEncounterDisplay(SPAWN_PATTERN)
GenerateEditorBindings(displayStr)