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

    lda rHaltKernelId
    cmp #HALT_KERNEL_PAUSEVIEW
    beq .skip_worldview_draw
    lda #SLOT_F4_PLDRAW
    sta BANK_SLOT
    jsr PlDraw_Item

    lda #SLOT_F0_ENDRAW
    sta BANK_SLOT
    jsr EnDraw_Del
.skip_worldview_draw

    jsr Halt_KernelMain

HALT_OVERSCAN: SUBROUTINE ; 30 scanlines
    sta WSYNC
    lda #2
    sta VBLANK
    lda #36
    sta TIM64T ; 30 scanline timer
    sta wOSFrameState
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
    ldx #HALT_STACK_DEPTH
    txs
    lda Frame
    sta wHaltFrame

    lda HtTaskScriptIndex,y
    sta wHaltTask
    lda #$FF
    sta Halt_TaskTemp

    lda rOSFrameState
    bpl HALT_OVERSCAN_BLANK
    bmi HALT_VERTICAL_BLANK


HtTask_LoadRoom: SUBROUTINE
    jsr Halt_TaskStall_OVERSCAN

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

Halt_TaskNext: SUBROUTINE
    ldx rHaltTask
    inx
    stx wHaltTask
    lda #$FF
    sta Halt_TaskTemp
    rts

; Delays execution of task until the overscan portion of the frame
Halt_TaskStall_OVERSCAN: SUBROUTINE
    lda Halt_TaskTemp
    bpl .rts

    inc Halt_TaskTemp
    lda rOSFrameState
    bpl .rts ; #OS_FRAME_OVERSCAN
    ; If OS_FRAME_VBLANK, return from the task function
    pla
    pla
.rts
    rts

Halt_KernelMain: SUBROUTINE
    ldx rHaltKernelId
    beq Halt_Kernel_HUD_WORLD
    dex
    beq Halt_Kernel_HUD_WORLD
    dex
    beq Halt_Kernel_HUD_SCROLL
    dex
    beq Halt_Kernel_PAUSEVIEW
.infinite
    bne .infinite

Halt_Kernel_PAUSEVIEW:
    lda #SLOT_F4_PAUSE_MENU_DRAW
    sta BANK_SLOT
    jmp DRAW_PAUSE_MENU

Halt_Kernel_HUD_WORLD:
    ; TODO: Handle hud issues when swapping worlds
    jsr Halt_SetKernelWorld
    lda #SLOT_F4_MAIN_DRAW
    sta BANK_SLOT
    jmp DRAW_HUD_WORLD

Halt_Kernel_HUD_SCROLL:
    jsr Halt_SetKernelRoomScroll1
    lda #SLOT_F4_MAIN_DRAW
    sta BANK_SLOT
    jmp DRAW_HUD_WORLD

Halt_SetKernelWorld: SUBROUTINE
    lda <[#KERNEL_WORLD_RESUME]
    sta wWorldKernelDraw
    lda >[#KERNEL_WORLD_RESUME]
    sta wWorldKernelDraw+1
    rts

Halt_SetKernelRoomScroll1: SUBROUTINE
    lda <#KERNEL_SCROLL1
    sta wWorldKernelDraw
    lda >#KERNEL_SCROLL1
    sta wWorldKernelDraw+1
    rts