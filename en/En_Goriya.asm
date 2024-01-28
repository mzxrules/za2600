;==============================================================================
; mzxrules 2024
;==============================================================================
EN_GORIYA_TYPE_BLUE = $1

En_GoriyaBlue: SUBROUTINE
    lda #EN_GORIYA_TYPE_BLUE
    sta enState,x
    lda #5-1
    sta enHp,x
    bpl .commmon_init

En_Goriya:
    lda #3-1
    sta enHp,x

.commmon_init
    lda #EN_GORIYA_MAIN
    sta enType,x
    jsr Random
    and #3
    sta enDir,x

    jsr Random
    and #$F
    sta enGoriyaStep,x
    rts

En_GoriyaMain:
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

    dec enGoriyaStep,x
    bpl .seek_next
    jsr Random
    and #$F
    sta enGoriyaStep,x

    jsr EnMove_Card_WallCheck
    jsr EnMove_Card_RandDir
    sty enDir,x
    bpl .move ; jmp

.seek_next
    jsr EnMove_Card_WallCheck
    jsr EnMove_Card_RandDirIfBlocked
    sty enDir,x
.move
    lda Frame
    and #1
    bne .rts
    jsr EnMoveDir
.rts
    rts