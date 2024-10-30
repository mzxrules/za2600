;==============================================================================
; mzxrules 2023
;==============================================================================

HALT_VERTICAL_SYNC:
    jsr VERTICAL_SYNC

HALT_VERTICAL_BLANK: SUBROUTINE
    jsr HtTask_Run

HALT_FROM_FLUTE:
    lda #SLOT_F4_AU1
    sta BANK_SLOT
    jsr UpdateAudio

    lda #SLOT_F0_ENDRAW
    sta BANK_SLOT
    jsr EnDraw_Del

    lda #SLOT_F4_PAUSE_DRAW_WORLD
    sta BANK_SLOT
    jsr DRAW_PAUSE_WORLD

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

HALT_FROM_ENTER_LOC:
    jsr HtTask_Run

HALT_OVERSCAN_WAIT:
    sta WSYNC
    lda INTIM
    bne HALT_OVERSCAN_WAIT
    sta WSYNC
    jmp HALT_VERTICAL_SYNC


HALT_PLAY_FLUTE_ENTRY: SUBROUTINE
    ldx #$FF
    txs
    lda Frame
    sta wHaltFrame

    ldy #HALT_TYPE_PLAY_FLUTE
    sty wHaltType
    lda HtTaskScriptIndex,y
    sta wHaltTask

    lda #ROOM_PX_HEIGHT-1
    sta wHaltWorldDY
    jmp HALT_FROM_FLUTE

HALT_ENTER_CAVE_ENTRY: SUBROUTINE
    ldy #HALT_TYPE_ENTER_CAVE
    sty wHaltType
    bpl .entry_common ; jmp

HALT_ENTER_DUNG_ENTRY:
    ldy #HALT_TYPE_ENTER_DUNG
    sty wHaltType

.entry_common
; Reset the stack
    ldx #$FF
    txs
    lda Frame
    sta wHaltFrame

    lda HtTaskScriptIndex,y
    sta wHaltTask

    lda #MS_PLAY_NONE
    sta SeqFlags
    lda #SFX_ENTER
    sta SfxFlags

    lda #ROOM_PX_HEIGHT-1
    sta wHaltWorldDY
    jmp HALT_FROM_ENTER_LOC
