;==============================================================================
; mzxrules 2021
;==============================================================================

; Defines variable defs for itemFlags
    MACRO ITEM
ITEMV_{1} = itemFlags + {2}
ITEMF_{1} = {3}
    ENDM

; Defines consts to calculate En class sizes
    MACRO EN_SIZE
SIZE_EN_{1} = . - EN_FREE + $8000
    ENDM

; Outputs rom size of a code section
    MACRO LOG_BANK_SIZE
        IFNCONST PAL60
        echo .- {2}+$8000,{2},(.),{1}
        ENDIF
    ENDM

    MACRO LOG_BANK_SIZE_M1
        IFNCONST PAL60
        echo .- {2}+$8000,{2},(.-1),{1}
        ENDIF
    ENDM

    MACRO LOG_SIZE
        IFCONST LOG
            IFNCONST PAL60
            echo .- {2}+$8000,{2},(.),{1}
            ENDIF
        ENDIF
    ENDM

; Bitpack miType data, storing in register A
    MACRO SET_A_miType
    lda #<[{2}/4*$10] + {1}
    ENDM

; Bitpack miType data, storing in data
    MACRO BYTE_miType
    .byte #<[{2}/4*$10] + {1}
    ENDM

; Room PF2 Type
    MACRO ROOM_PF2
ROOM_PF2_{1} = [[[{2} & 0xF] << 4] | [[{2} & $F0] >> 4 ]]
    ENDM

; RoomScroll Matrix
    MACRO ROOMSCROLL_TASK
    .byte #ROOMSCROLL_TASK__{1}
    .byte #ROOMSCROLL_TASK__{2}
    .byte #ROOMSCROLL_TASK__{3}
    .byte #ROOMSCROLL_TASK__{4}
    ENDM

; Rewriteable Kernel Variable
    MACRO VKERNEL1
r{1} = . - KERNEL_WORLD + rKERNEL_WORLD + 1
w{1} = . - KERNEL_WORLD + wKERNEL_WORLD + 1
    ENDM

; Sets texture pointers for 48 pixel kernel
    MACRO TEX48P
    lda #<{2}{3}
    ldx #>{2}{3}
    sta [$F201 +[rTex_{3}0 - KERNEL48]+[{1}*$10]]
    sta [$F201 +[rTex_{3}1 - KERNEL48]+[{1}*$10]]
    stx [$F202 +[rTex_{3}0 - KERNEL48]+[{1}*$10]]
    stx [$F202 +[rTex_{3}1 - KERNEL48]+[{1}*$10]]
    ENDM

; Text Kernel sleep macro
    MACRO VSLEEP
    bvs .j0
.j0
    bvs .j1
.j1
    ENDM

; Color definition macro
    MACRO COLOR
    IFCONST PAL60
COLOR_{1} = {3}
    ELSE
COLOR_{1} = {2}
    ENDIF
    ENDM

; PF Destroy Macros
; A1 = X coordinate $
; A2 = Y coordinate $
; A3 = Y depth
    MACRO SET_WALL_DESTROY_XY
    lda #>[RsInit_Wall_P{1}{2}-1]
    pha
    lda #<[RsInit_Wall_P{1}{2}-1]
    pha
    IF #<[RsInit_Wall_P{1}{2}-1] = 0
        beq Rs_EntCaveWallBlocked
    ELSE
        bne Rs_EntCaveWallBlocked
    ENDIF
    ENDM

    MACRO SET_BUSH_DESTROY_XY
    lda #>[RsInit_Bush_P{1}{2}-1]
    pha
    lda #<[RsInit_Bush_P{1}{2}-1]
    pha
    IF #<[RsInit_Bush_P{1}{2}-1] = 0
        beq Rs_EntCaveBushBlocked
    ELSE
        bne Rs_EntCaveBushBlocked
    ENDIF
    ENDM

; Bank Hook macros
; For hot swapping the bank the cpu is currently executing

; BANK_JMP jumps to a given destination
    MACRO BHA_BANK_JMP
    lda {1}
    sta BANK_SLOT
    jmp {2}
    ENDM

; BANK_FALL allows fallthrough
    MACRO BHA_BANK_FALL
    lda {1}
    sta BANK_SLOT
    ENDM

    MACRO BHY_BANK_FALL
    ldy {1}
    sty BANK_SLOT
    ENDM