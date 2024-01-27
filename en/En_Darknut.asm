;==============================================================================
; mzxrules 2021
;==============================================================================
EN_DARKNUT_TYPE_RED = $0
EN_DARKNUT_TYPE_BLUE = $1
EN_DARKNUT_TYPE_MASK = $1


En_DarknutBlue: SUBROUTINE
    lda #EN_DARKNUT_TYPE_BLUE
    sta enState,x
    lda #3
    sta enHp,x
    bpl .commmon_init

En_Darknut:
    lda #EN_DARKNUT_TYPE_RED
    sta enState,x
    lda #2
    sta enHp,x

.commmon_init
    lda #EN_DARKNUT_MAIN
    sta enType,x
    jsr Random
    and #3
    sta enDir,x

    jsr Random
    and #7
    sta enDarknutStep,x
    rts

En_DarknutMain:
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

; Check player hit
    lda enStun,x
    bmi .endCheckHit
    bit plState2
    bvc .endCheckHit ; EN_LAST_DRAWN
    bit CXPPMM
    bpl .endCheckHit
    lda #-8
    jsr UPDATE_PL_HEALTH
.endCheckHit

; Movement
    lda #SLOT_F0_EN_MOV
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
    jmp EnMov_Recoil

.normal_movement
    ldy en0X,x
    lda en_offgrid_lut,y
    bne .move
    ldy en0Y,x
    lda en_offgrid_lut,y
    bne .move

    dec enDarknutStep,x
    bpl .seek_next
    jsr Random
    and #7
    sta enDarknutStep,x

    jsr EnMov_Card_WallCheck
    jsr EnMov_Card_RandDir
    sty enDir,x
    bpl .move ; jmp

.seek_next
    jsr EnMov_Card_WallCheck
    jsr EnMov_Card_RandDirIfBlocked
    sty enDir,x
.move
    lda enState
    and #EN_DARKNUT_TYPE_MASK
    tay
    lda enDarknutSpdFrac,x
    clc
    adc En_DarknutSpeed,y
    sta enDarknutSpdFrac,x
    bcc .rts
    jsr EnMoveDir
.rts
    rts
    LOG_SIZE "En_Darknut", En_Darknut

En_DarknutSpeed:
    .byte #$80, #$A0