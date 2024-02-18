;==============================================================================
; mzxrules 2021
;==============================================================================

EN_WALLMASTER_CAPTURE = $80
EN_WALLMASTER_INIT = $40

En_WallmasterInit: SUBROUTINE
    lda #3
    sta enHp,x

; calculate initial position
.calcX
    lda #EnBoardXL
    ldy plX
    cpy #BoardXC
    bcc .setX
    lda #EnBoardXR
.setX
    sta en0X,x

.calcY
    ldy plY
    cpy #BoardYC
    bcc .down
.up
    lda #0
    ldy #EnBoardYU
    bcs .setY ; jmp
.down
    lda #32
    ldy #EnBoardYD
.setY
    sta enWallPhase
    sty en0Y,x

; test if the wallmaster should appear
    lda plX
    ldy plY
    cmp #EnBoardXL
    beq .setPos
    cmp #EnBoardXR
    beq .setPos

    cpy #EnBoardYU
    beq .setPos
    cpy #EnBoardYD
    bne .rts

.setPos
    lda #EN_WALLMASTER_INIT
    sta enState,x
.rts
    rts

En_WallmasterCapture:
    inc enWallPhase
    ldx enWallPhase
    cpx #33
    bne .rts
    jmp SPAWN_AT_DEFAULT

En_Wallmaster: SUBROUTINE
    lda enState,x
    rol
    bcs En_WallmasterCapture
    bpl En_WallmasterInit

; Handle phasing state
    lda enWallPhase,x
    cmp #16
    beq .main_thing
    bmi .incWallPhase
    dec enWallPhase,x
    rts
.incWallPhase
    inc enWallPhase,x
    rts

.main_thing
; check damaged
    lda #SLOT_F0_BATTLE
    sta BANK_SLOT
    jsr HbCheckDamaged_CommonRecoil

    lda #SLOT_F0_EN
    sta BANK_SLOT
    lda enHp,x
    bpl .endCheckDamaged
    jmp EnSysEnDie
.endCheckDamaged


.checkPlayerHit
    bit plState2
    bvc .endCheckHit ; EN_LAST_DRAWN
    bit CXPPMM
    bpl .endCheckHit
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
.endCheckHit

.handleMovement
    lda #SLOT_F0_EN_MOVE
    sta BANK_SLOT

; update EnMoveNX/NY
    lda en0X,x
    lsr
    lsr
    sta EnMoveNX
    lda en0Y,x
    lsr
    lsr
    sta EnMoveNY

; check recoil movement
    lda enState,x
    and #EN_ENEMY_MOVE_RECOIL
    beq .normal_movement
    jmp EnMove_Recoil

.normal_movement

    ldy en0X,x
    lda EnMove_OffgridLUT,y
    bne .move
    ldy en0Y,x
    lda EnMove_OffgridLUT,y
    bne .move

.solveNextDirection
    jsr EnMove_Card_WallCheck
    jsr EnMove_Card_SeekDir
    sty enDir,x
.move
    lda Frame
    ror
    bcc .rts
    jsr EnMoveDir
.rts
    rts

    LOG_SIZE "En_Wallmaster", En_WallmasterCapture