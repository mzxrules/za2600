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
SIZE_EN_{1} = . - EN_VARS + $8000
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

; Rewriteable Kernel Variable
    MACRO VKERNEL1
r{1} = . - KERNEL_WORLD + rKERNEL + 1
w{1} = . - KERNEL_WORLD + wKERNEL + 1
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