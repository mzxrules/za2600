;==============================================================================
; mzxrules 2021
;==============================================================================

EN_WALLMASTER_CAPTURE = $80
EN_WALLMASTER_INIT = $40

En_WallmasterInit: SUBROUTINE
; calculate initial position
    lda #3
    sta enHp,x
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
    sta enWallPhase
    txa
    ldx enNum
    sta en0X,x
    sty en0Y,x
    lsr
    lsr
    sta enNX,x
    tya
    lsr
    lsr
    sta enNY,x

    lda #EN_WALLMASTER_INIT
    sta enState,x
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
    beq .main_thing
    bmi .incWallPhase
    dec enWallPhase,x
    rts
.incWallPhase
    inc enWallPhase,x
    rts

.main_thing
; update stun timer
    lda enStun,x
    cmp #1
    adc #0
    sta enStun,x

.checkDamaged
    lda enHp,x
    sta itemRupees
; if collided with weapon && stun == 0,
    lda enStun,x
    bne .endCheckDamaged
    lda #SLOT_BATTLE
    sta BANK_SLOT
    jsr HbGetPlAtt
    jsr HbPlAttCollide_EnBB

; Get damage
    ldy HbDamage
    lda EnDam_Wallmaster,y
    sta Temp0

    lda #SLOT_EN_A
    sta BANK_SLOT
    lda HbFlags
    beq .endCheckDamaged

.gethit
    lda Temp0 ; fetch damage
    ldy #-32
    sty enStun,x
    clc
    adc enHp,x
    sta enHp,x
    bpl .endCheckDamaged
    jmp EnSysEnDie
.defSfx
    lda #SFX_DEF
    sta SfxFlags
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
    lda #SLOT_EN_MOV
    sta BANK_SLOT
    ldx enNum

; update EnMoveNX
    lda enNX,x
    sta EnMoveNX
    lda enNY,x
    sta EnMoveNY

    lda enNX,x
    asl
    asl
    cmp en0X,x
    bne .move
    lda enNY,x
    asl
    asl
    cmp en0Y,x
    bne .move

.solveNextDirection
    jsr EnMov_Card_WallCheck
    jsr EnMov_Card_SeekDir
    sty enDir,x
.move
    lda Frame
    ror
    bcc .rts
    jsr EnMoveDir
.rts
    rts

    LOG_SIZE "En_Wallmaster", En_WallmasterCapture