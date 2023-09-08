;==============================================================================
; mzxrules 2021
;==============================================================================

EN_WALLMASTER_CAPTURE = $80
EN_WALLMASTER_INIT = $40

En_WallmasterInit: SUBROUTINE
; calculate initial position
    lda #0 ; up wall phase
    ldy #EnBoardYU
    ldx #EnBoardXL
    cpy plY
    beq .contInit
    cpx plX
    beq .contInit
    lda #32 ; down wall phase
    ldy #EnBoardYD
    ldx #EnBoardXR
    cpy plY
    beq .contInit
    cpx plX
    bne .rts

.contInit
    stx enX
    sty enY
    sta enWallPhase

    lda #EN_WALLMASTER_INIT
    sta enState
    rts

En_WallmasterCapture:
    inc enWallPhase
    ldx enWallPhase
    cpx #33
    bne .rts
    jsr SPAWN_AT_DEFAULT
.rts
    rts

En_Wallmaster: SUBROUTINE
    lda enState,x
    rol
    bcs En_WallmasterCapture
    bpl En_WallmasterInit

; Handle phasing state
    lda enWallPhase,x
    cmp #16
    beq .checkPlayerHit
    bmi .incWallPhase
    dec enWallPhase,x
    rts
.incWallPhase
    inc enWallPhase,x
    rts

.checkPlayerHit
    bit CXPPMM
    bpl .handleMovement
    lda #-4
    jsr UPDATE_PL_HEALTH
    lda plState
    ora #PS_LOCK_ALL
    sta plState
    lda plX
    sta enX,x
    lda plY
    sta enY,x
    lda #EN_WALLMASTER_CAPTURE
    ora enState,x
    sta enState,x
    lda #$80
    sta plY
    rts
.handleMovement
    lda #3
    bit enX
    bne .skipSetDir
    bit enY
    bne .skipSetDir

    ; test if position changed since last update
    lda #$F0 ; clear blocked direction
    ldx enPX
    cpx enX
    bne .NextDir
    ldx enPY
    cpx enY
    bne .NextDir
    lda #$FF ; preserve blocked direction
.NextDir
    jsr EnSetBlockedDir
    jsr SeekDir
.skipSetDir
    lda enX
    sta enPX
    lda enY
    sta enPY
    lda CXP1FB
    bmi .forceMove
    lda Frame
    and #1
    bne .rts
.forceMove
    jmp EnMoveDir
.rts
    rts

    LOG_SIZE "En_Wallmaster", En_WallmasterCapture