;==============================================================================
; mzxrules 2023
;==============================================================================

HALT_VERTICAL_SYNC:
    jsr VERTICAL_SYNC

HALT_VERTICAL_BLANK: SUBROUTINE
    jsr HtTask_Run

    lda #SLOT_F4_AU1
    sta BANK_SLOT
    jsr UpdateAudio

    lda #SLOT_F4_PLDRAW
    sta BANK_SLOT
    jsr PlDraw_Item

    lda #SLOT_F0_ENDRAW
    sta BANK_SLOT
    jsr EnDraw_Del

    jsr Halt_KernelMain

HALT_OVERSCAN: SUBROUTINE ; 30 scanlines
    sta WSYNC
    lda #2
    sta VBLANK
    lda #36
    sta TIM64T ; 30 scanline timer
    sta wHaltVState
; reset world kernel vars
    lda #7
    sta wENH
    lda #0
    sta wNUSIZ1_T
    sta wREFP1_T

; Clean-up for room scroll kernel
    sta PF0
    sta PF1
    sta PF2
    sta COLUBK
    sta COLUPF

HALT_OVERSCAN_BLANK:
    jsr HtTask_Run

HALT_OVERSCAN_WAIT:
    sta WSYNC
    lda INTIM
    bne HALT_OVERSCAN_WAIT
    sta WSYNC
    jmp HALT_VERTICAL_SYNC

;==============================================================================
; HALT_GAME
;----------
; Y = HaltType
;==============================================================================
HALT_GAME: SUBROUTINE
    sty wHaltType

; Reset the stack
    ldx #$FF
    txs
    lda Frame
    sta wHaltFrame

    lda HtTaskScriptIndex,y
    sta wHaltTask

    lda rHaltVState
    bpl HALT_OVERSCAN_BLANK
    bmi HALT_VERTICAL_BLANK


HtTask_LoadRoom: SUBROUTINE
    lda rHaltVState
    bpl .continue ; not #HALT_VSTATE_TOP
    rts
.continue

    lda #HALT_KERNEL_HUD_SCROLL
    sta wHaltKernelId
    lda #SLOT_F0_ROOM
    sta BANK_SLOT
    jsr LoadRoom
    lda #SLOT_F0_RS_INIT
    sta BANK_SLOT
    lda #SLOT_F4_RS_DEST
    sta BANK_SLOT
    jsr RsInit_Del

    lda worldId
    bmi .skipRoomChecks
    lda #SLOT_F0_ROOM
    sta BANK_SLOT
    jsr UpdateDoors
.skipRoomChecks

    lda #SLOT_F4_MAIN_DRAW
    sta BANK_SLOT

    ldx #0
    bit rRoomColorFlags
    bvs .dark
    lda rRoomColorFlags
    and #$3F
    tax
.dark
    lda WorldColorsFg,x
    sta wFgColor
    lda WorldColorsBg,x
    sta wBgColor

Halt_IncTask: SUBROUTINE
    ldx rHaltTask
    inx
    stx wHaltTask
.rts
    rts

HtTask_WaitVStateBottom:  ; SUBROUTINE
    lda rHaltVState
    bmi .rts ; #HALT_VSTATE_TOP
    jsr Halt_IncTask
    jmp HtTask_Run

Halt_KernelMain: SUBROUTINE
    ldx rHaltKernelId
    beq Halt_Kernel_HUD_WORLD
    dex
    beq Halt_Kernel_HUD_WORLD
    dex
    beq Halt_Kernel_HUD_SCROLL
    dex
    beq Halt_Kernel_PAUSE_WORLD
.infinite
    bne .infinite

Halt_Kernel_HUD_WORLD:
    jsr Halt_SetKernelWorld
    lda #SLOT_F4_MAIN_DRAW
    sta BANK_SLOT
    jmp DRAW_HUD_WORLD

Halt_Kernel_HUD_SCROLL:
    jsr Halt_SetKernelRoomScroll1
    lda #SLOT_F4_MAIN_DRAW
    sta BANK_SLOT
    jmp DRAW_HUD_WORLD

Halt_Kernel_PAUSE_WORLD:
    ; TODO: Handle hud issues
    jsr Halt_SetKernelWorld
    lda #SLOT_F4_MAIN_DRAW
    sta BANK_SLOT
    jmp DRAW_HUD_WORLD

Halt_SetKernelWorld: SUBROUTINE
    lda <[#KERNEL_WORLD_RESUME_PREFETCH]
    sta wHaltKernelDraw
    lda >[#KERNEL_WORLD_RESUME_PREFETCH]
    sta wHaltKernelDraw+1
    rts

Halt_SetKernelRoomScroll1: SUBROUTINE
    lda <#KERNEL_SCROLL1
    sta wHaltKernelDraw
    lda >#KERNEL_SCROLL1
    sta wHaltKernelDraw+1
    rts