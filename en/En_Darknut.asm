;==============================================================================
; mzxrules 2021
;==============================================================================
EN_DARKNUT_TYPE_RED = $1
EN_DARKNUT_TYPE_BLUE = $3


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

    lda en0X,x
    lsr
    lsr
    sta enNX,x
    lda en0Y,x
    lsr
    lsr
    sta enNY,x
    jsr Random
    and #7
    sta enDarknutStep,x
    rts

En_DarknutMain:

; update stun timer
    lda enStun,x
    cmp #1
    adc #0
    sta enStun,x


.checkDamaged
; if collided with weapon && stun == 0,
    lda enStun,x
    bne .endCheckDamaged
    lda #SLOT_BATTLE
    sta BANK_SLOT
    jsr HbGetPlAtt
    jsr HbPlAttCollide_EnBB

; Get damage
    ldy HbDamage
    lda EnDam_Darknut,y
    sta Temp0

    lda #SLOT_EN_A
    sta BANK_SLOT
    lda HbFlags
    beq .endCheckDamaged

; Test if darknut takes damage
    lda HbFlags
    and #HB_PL_FIRE
    bne .endCheckDamaged
    lda HbFlags
    and #HB_PL_SWORD | #HB_PL_BOMB
    beq .defSfx ; block non-damaging attacks

; Test if item hit Darknut's shield
    ldy enDir,x
    cpy plItemDir
    bne .gethit

    ; Test if sword hit shield
    and #HB_PL_SWORD
    bne .defSfx
    ; Bomb hit shield
    lda #-2
    sta Temp0

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
    lda #SLOT_EN_MOV
    sta BANK_SLOT

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

    dec enDarknutStep,x
    bpl .seek_next
    jsr Random
    and #7
    sta enDarknutStep,x

    jsr EnMov_Card_WallCheck
    jsr EnMov_Card_RandDir
    sty enDir,x
    bpl .move

.seek_next
    jsr EnMov_Card_WallCheck
    jsr EnMov_Card_RandDirIfBlocked
    sty enDir,x
.move
    lda Frame
    and #1
    beq .rts
    jsr EnMoveDir
.rts
    rts
    LOG_SIZE "En_Darknut", En_Darknut