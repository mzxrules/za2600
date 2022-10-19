;==============================================================================
; mzxrules 2021
;==============================================================================

En_WallmasterCapture: SUBROUTINE
    inc enWallPhase
    ldx enWallPhase
    cpx #33
    bne .rts
    jsr SPAWN_AT_DEFAULT
.rts
    rts

En_Wallmaster: SUBROUTINE
    ; draw sprite
    lda #>SprE10
    sta enSpr+1
    lda enWallPhase
    lsr
    clc
    adc #<SprE10-8
    sta enSpr
    lda #0
    sta enColor
    
    bit enState
    bvs En_WallmasterCapture
    bmi .runMain
    
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
    
    lda #$80
    sta enState
    
.runMain
    ldx enWallPhase
    cpx #16
    beq .next
    bmi .incWallPhase
    dec enWallPhase
    bpl .rts ; always branch
.incWallPhase
    inc enWallPhase
    bpl .rts ; always branch
    
.next
    bit CXPPMM
    bpl .handleMovement
    lda #-4
    jsr UPDATE_PL_HEALTH
    lda plState
    ora #PS_LOCK_ALL
    sta plState
    lda plX
    sta enX
    lda plY
    sta enY
    lda #$40
    ora enState
    sta enState
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
    jmp EnMoveDirDel
.rts
    rts

    LOG_SIZE "En_Wallmaster", En_WallmasterCapture