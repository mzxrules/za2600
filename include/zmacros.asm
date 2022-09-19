;==============================================================================
; mzxrules 2021
;==============================================================================

; Defines variable defs for itemFlags
    MACRO ITEM
ITEMV_{1} = itemFlags + {2}
ITEMF_{1} = {3}
    ENDM

; Outputs rom size of a code section
    MACRO LOG_SIZE
        IFNCONST PAL60
        echo .- {2}+$8000,{2},(.),{1}
        ENDIF
    ENDM
    
    MACRO LOG_SIZE_M1
        IFNCONST PAL60
        echo .- {2}+$8000,{2},(.-1),{1}
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
    
    MACRO COLOR
    IFCONST PAL60
COLOR_{1} = {3}
    ELSE
COLOR_{1} = {2}
    ENDIF
    ENDM