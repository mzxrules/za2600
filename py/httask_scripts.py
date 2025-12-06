#!/usr/bin/env python3
from asmgen import ToAsm, ToAsmD
from func_common import ToSnakeCase

HALT_TASK_SCRIPTS = [
    # HALT_TYPE_RSCR_NONE
    [
        "HtTask_RoomScrollStart",
        "HtTask_TransferA",
        "HtTask_LoadRoom",
        "HtTask_TransferB",
        "HtTask_RoomScrollEnd",
    ],
    # HALT_TYPE_RSCR_WEST
    [
        "HtTask_RoomScrollStart",
        "HtTask_TransferA",
        "HtTask_LoadRoom",
        "HtTask_TransferB",
        "HtTask_AnimWest",
        "HtTask_RoomScrollEnd",
    ],
    # HALT_TYPE_RSCR_EAST
    [
        "HtTask_RoomScrollStart",
        "HtTask_TransferA",
        "HtTask_LoadRoom",
        "HtTask_TransferB",
        "HtTask_AnimEast",
        "HtTask_RoomScrollEnd",
    ],
    # HALT_TYPE_RSCR_NORTH
    [
        "HtTask_RoomScrollStart",
        "HtTask_TransferA",
        "HtTask_LoadRoom",
        "HtTask_TransferB",
        "HtTask_AnimNorth",
        "HtTask_RoomScrollEnd",
    ],
    # HALT_TYPE_RSCR_SOUTH
    [
        "HtTask_RoomScrollStart",
        "HtTask_TransferB",
        "HtTask_LoadRoom",
        "HtTask_TransferA",
        "HtTask_AnimSouth",
        "HtTask_RoomScrollEnd",
    ],
    # HALT_TYPE_PLAY_FLUTE
    [
        "HtTask_PlayFlute"
    ],
    # HALT_TYPE_ENTER_DUNG
    [
        "HtTask_EnterLoc"
    ],
    # HALT_TYPE_ENTER_CAVE
    [
        "HtTask_EnterLoc"
    ],
    # HALT_TYPE_GAME_OVER
    [
        "HtTask_AnimDeath",
        "HtTask_IdleGameOver",
    ],
]

def build_taskscript():
    output = "Halt_TaskMatrix:\n"
    scriptIndexLut = []
    index = 0
    for script in HALT_TASK_SCRIPTS:
        scriptIndexLut.append(index)
        index += len(script)
        for item in script:
            output += f"    .byte {ToSnakeCase(item)}\n"
        output += "\n"

    output += "HtTaskScriptIndex:\n"
    output += ToAsm(scriptIndexLut)
    with open(f'gen/HtTask_Scripts.asm', "w") as file:
        file.write(output)

build_taskscript()