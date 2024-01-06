;==============================================================================
; mzxrules 2024
;==============================================================================
EN_LYNEL_TYPE_RED = $1
EN_LYNEL_TYPE_BLUE = $3


En_LynelBlue: SUBROUTINE
    lda #EN_LYNEL_TYPE_BLUE
    sta enState,x
    lda #6-1
    sta enHp,x
    bpl .commmon_init

En_Lynel:
    lda #EN_LYNEL_TYPE_RED
    sta enState,x
    lda #3-1
    sta enHp,x

.commmon_init
    lda #EN_LYNEL_MAIN
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

En_LynelMain:

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
    lda EnDam_Lynel,y
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
.endCheckDamaged

    ; Check player hit
    lda enStun,x
    bmi .endCheckHit
    bit plState2
    bvc .endCheckHit ; EN_LAST_DRAWN
    bit CXPPMM
    bpl .endCheckHit
    lda enType
    and #EN_LYNEL_TYPE_RED
    beq .blue_damage
    lda #-8
    bmi .update_player_health ; jmp
.blue_damage
    lda #-16
.update_player_health
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
    LOG_SIZE "En_Lynel", En_Lynel