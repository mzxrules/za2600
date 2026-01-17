;==============================================================================
; mzxrules 2024
;==============================================================================
EN_BOSS_DON_ATE_BOMB = 1
EN_BOSS_DON_ANIM_SMOKE = #<-180
EN_BOSS_DON_ANIM_EAT_START = -120
EN_BOSS_DON_ANIM_EAT_DETONATE = -120 + 60

; Boss Don states:
; Neutral - Walk around room
; Stunned By Bomb  - Stop Walking, weak to sword
; Mouth Touch Bomb - Stop Walking, immune to attack
; Dodongo Bloat    - stop walking, immune to attack

En_BossDon: SUBROUTINE
    lda enState,x
    bmi .main
    lda #$80
    sta enState,x
    lda #1
    sta enHp,x

    jsr Random
    and #7
    sta enDonStep,x

    jsr Random
    and #3
    sta enDir,x

    lda Frame
    lsr
    and #6
    ora En_BossDon_SpawnIdx,x
    tay
    lda En_BossDon_SpawnX,y
    sta en0X,x
    lda En_BossDon_SpawnY,y
    sta en0Y,x
    rts

.main
    lda Frame
    and #$7F
    bne .checkDamaged
    lda #SFX_BOSS_ROAR
    sta SfxFlags

.checkDamaged
    lda #SLOT_F0_BATTLE
    sta BANK_SLOT
    jsr HbGetPlAtt
    lda enStun,x
    bne .skip_checkDamaged_mouth

.checkDamaged_mouth
    ldy enDir,x
    lda en0X,x
    clc
    adc En_BossDon_MouthOffX,y
    sta Hb_bb_x
    lda en0Y,x
    clc
    adc En_BossDon_MouthOffY,y
    sta Hb_bb_y
    jsr HbPlAttCollide_Invisible
    lda HbResult
    bpl .skip_checkDamaged_mouth ; not HB_BOX_HIT

.checkDamaged_hitMouth
    lda HbPlFlags
    and #HB_PL_BOMB
    beq .skip_checkDamaged_mouth
    lda HbDamage
    cmp #HB_DMG_BOMB_LIT
    bne .skip_checkDamaged_mouth
    ; kill bomb
    lda #$80
    sta plm0Y
    lda #$80 | #EN_BOSS_DON_ATE_BOMB
    sta enState,x
    lda #EN_BOSS_DON_ANIM_EAT_START
    sta enStun,x
    bne .end_checkDamaged ; jmp
.skip_checkDamaged_mouth

.checkDamaged_body
    jsr HbPlAttCollide_EnBB
    lda HbResult
    bmi .checkDamaged_hitBody ; HB_BOX_HIT
.checkDamaged_body2
    ldy enDir,x
    lda en0X,x
    clc
    adc En_BossDon_BodyOffX,y
    sta Hb_bb_x
    jsr HbPlAttCollide
    bpl .end_checkDamaged
.checkDamaged_hitBody ; not HB_BOX_HIT
    lda enState,x
    ror
    bcs .end_checkDamaged ; EN_BOSS_DON_ATE_BOMB
    lda HbDamage
    cmp #HB_DMG_BOMB
    bne .checkDamaged_testStab
    lda #EN_BOSS_DON_ANIM_SMOKE
    sta enStun,x
    bne .end_checkDamaged ; jmp

.checkDamaged_testStab
    ldy #0
    lda enStun,x
    bne .checkDamaged_DoSfx
    iny
.checkDamaged_DoSfx

    lda HbPlFlags
    and En_BossDon_ImmuneSfxFlags,y
    beq .checkDamaged_PlaySfx
    lda #SFX_EN_DEF
    bmi .checkDamaged_PlaySfx ; jmp
    lda #SFX_EN_DAMAGE
.checkDamaged_PlaySfx
    sta SfxFlags
.checkDamaged_TestSecretKill
    lda HbPlFlags
    and En_BossDon_VulnAttFlags,y
    beq .end_checkDamaged
    lda #$FF
    sta enHp,x
.end_checkDamaged


; ANIM_EAT behavior
.animEat
    lda enState,x
    ror
    bcc .end_AnimEat
    lda enStun,x
    cmp #EN_BOSS_DON_ANIM_EAT_DETONATE
    bne .animEat_DecHp
    ldy #SFX_BOMB
    sty SfxFlags
.animEat_DecHp
    cmp #$FF
    bne .end_AnimEat
    lda #$80
    sta enState,x
    dec enHp,x
.end_AnimEat


.testHp
    lda enHp,x
    bpl .end_testHp

; Kill Enemy
    lda #SFX_EN_KILL
    sta SfxFlags

    lda #SLOT_F0_EN
    sta BANK_SLOT

    lda roomRS
    cmp #RS_ITEM
    bne .no_bosskill
    lda roomEX
    cmp #GI_HEART
    bne .no_bosskill

    jsr EnSysRoomKill
.no_bosskill
    jmp EnSys_KillEnemyB

.end_testHp

; check player hit
    lda enStun,x
    bmi .endCheckHit
    bit plState2
    bvc .endCheckHit ; EN_LAST_DRAWN
    bit CXPPMM
    bpl .endCheckHit
    lda en0Y,x
    clc
    adc #7
    cmp plY
    bcc .endCheckHit
    lda #-4
    jsr UPDATE_PL_HEALTH
.endCheckHit


.Movement
; If stunned, don't move
    lda enStun,x
    beq .Movement_Cont
    inc enStun,x
    bne .rts

.Movement_Cont

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

.normal_movement
    ldy en0X,x
    lda EnMove_OffgridLUT,y
    bne .move
    ldy en0Y,x
    lda EnMove_OffgridLUT,y
    bne .move

    dec enDonStep,x
    bpl .seek_next
    jsr Random
    clc
    adc #4
    and #$1C
    sta enDonStep,x

    jsr EnMove_Card_WallCheck
    jsr EnMove_Card_RandDir
    sty enDir,x
    bpl .move ; jmp

.seek_next
    jsr EnMove_Card_WallCheck
    jsr EnMove_Card_RandDirIfBlocked
    sty enDir,x
.move
    lda enDonSpdFrac,x
    clc
    adc #$80
    sta enDonSpdFrac,x
    bcc .rts
    jsr EnMoveDir
.rts
    rts

En_BossDon_SpawnIdx:
    .byte #0, #1

En_BossDon_SpawnX:  ; $18 to $68
    .byte $20, $34, $64, $4C
    .byte $20, $34, $64, $4C

En_BossDon_SpawnY:  ; $1C to $3C
    .byte $20, $30, $38, $28
    .byte $38, $28, $20, $30

En_BossDon_BodyOffX:
    .byte #8, #-8, #0, #0

En_BossDon_MouthOffX:
    .byte #0, #4, #2, #2
En_BossDon_MouthOffY:
    .byte #2, #2, #12+2, #-2

En_BossDon_VulnAttFlags
    .byte #HB_PL_SWORD
    .byte #0

En_BossDon_ImmuneSfxFlags
    .byte ~#HB_PL_BOMB & ~#HB_PL_SWORD
    .byte ~#HB_PL_BOMB
