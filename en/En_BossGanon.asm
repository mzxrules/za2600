;==============================================================================
; mzxrules 2025
;==============================================================================

EN_BOSS_GANON_DRAW_TRI = #$40
EN_BOSS_GANON_DRAW_BOSS4  = #$02
EN_BOSS_GANON_SPRITE_MASK = #$01

EN_BOSS_GANON_SPRITE_STANDING   = #$00
EN_BOSS_GANON_SPRITE_DOWNED     = #$01
EN_BOSS_GANON_SPRITE_TRI_WISDOM = #$40
EN_BOSS_GANON_SPRITE_TRI_POWER  = #$41

En_BossGanon: SUBROUTINE
    lda enState
    bmi .skipInit

    lda #EnBoardYD
    sta plY

    lda plState
    ora #PS_LOCK_ALL
    sta plState

    lda plState2
    ora #PS_HOLD_ITEM
    sta plState2

    lda #EnBoardYD+9
    sta en0Y

    lda plX
    sta en0X

    lda #$80 + #EN_BOSS_GANON_DRAW_TRI
    sta enState

    lda #COLOR_EN_BLACK
    sta enGanonColor

    lda #$FF
    sta enGanonStep
    sta enGanonAnim

.skipInit
    ldy enGanonStep
    lda enGanonAnim
    cmp #1
    adc #0
    sta enGanonAnim
    bne .switch
    iny
    sty enGanonStep
    lda .anim_timer,y
    sta enGanonAnim
.switch
    cpy #1
    bcc .anim_step0
    beq .anim_step1
    cpy #3
    bcc .anim_step2
    beq .anim_step3

    lda #EN_BOSS_GANON_MAIN
    sta enType
    lda #EN_BOSS_GANON_SPRITE_DOWNED
    sta enState

.anim_step0
    rts
.anim_step1
    lda enGanonAnim
; -timer
    lsr
    lsr
    eor #$FF
    sec
    adc #0
    and #$F
    sta wFgColor
    rts
.anim_step2
    lda #$40
    sta en0X
    lda #$30
    sta en0Y

    lda enGanonAnim
    lsr
    lsr
    clc
    ora #$C0
    adc #COLOR_EN_GANON
    sta enGanonColor
    lda #$80 + #EN_BOSS_GANON_DRAW_BOSS4 + #EN_BOSS_GANON_SPRITE_DOWNED
    sta enState
    rts
.anim_step3
    lda plState
    and  #~#PS_LOCK_ALL
    sta plState

    lda plState2
    and #~#PS_HOLD_ITEM
    sta plState2
    lda #0
    sta wRoomColorFlags
    rts

.anim_timer
    .byte #-32
    .byte #-[[#COLOR_PF_WHITE & #$0F]*4]
    .byte #-[[#COLOR_EN_GANON & #$0F]*4]
    .byte #-1


En_BossGanonMain: SUBROUTINE
    lda #SLOT_RW_F0_BOSS4
    sta BANK_SLOT_RAM

    lda enState
    bmi .skipInit
    lda #$80
    sta enState

    lda #$40
    sta en0X
    lda #$30
    sta en0Y

    lda #15-1
    sta enHp

    lda #0
    sta enState+1
    sta enGanonStep
    sta enGanonStun
    sta enGanonSpdFrac
    sta enGanonShootT
.skipInit

    jsr En_BossGanon_ClampPlayerPos

.checkDamaged
    lda #SLOT_F0_BATTLE
    sta BANK_SLOT

    jsr HbGetPlAtt
    jsr HbGanon
    jsr HbPlAttCollide

    lda HbResult
    bpl .end_checkDamaged

    ldy enHp
    bpl .sword_hit_check

.arrow_hit_check
    lda HbPlFlags
    and #HB_PL_ARROW
    beq .end_checkDamaged
    lda ITEMV_ARROW_SILVER
    and #ITEMF_ARROW_SILVER
    beq .end_checkDamaged
.kill
    lda #EN_BOSS_GANON_DEAD
    sta enType
    rts

.sword_hit_check
    lda enGanonStun
    bmi .end_checkDamaged
    lda HbPlFlags
    and #HB_PL_SWORD
    beq .end_checkDamaged
.sword_hit
    lda #SFX_EN_DAMAGE
    sta SfxFlags
    ldy HbDamage
    lda EnDam_Common,y
    clc
    adc enHp
    sta enHp

    ldy #$-32
    lda #$80 + #EN_BOSS_GANON_DRAW_BOSS4 + #EN_BOSS_GANON_SPRITE_DOWNED
    bit enHp
    bpl .set_stun
    ldy #$-120
    lda #$80 + #EN_BOSS_GANON_DRAW_BOSS4 + #EN_BOSS_GANON_SPRITE_STANDING
.set_stun
    sty enGanonStun
    sta enState
.end_checkDamaged


.last_do ; last chance to do things unconditionally
    lda #COLOR_EN_GANON
    bit enHp
    bpl .set_color
    lda #COLOR_EN_RED
.set_color
    sta enGanonColor

; Check if stunned, and skip everything else if true
    lda enGanonStun
    cmp #1
    adc #0
    sta enGanonStun
    bmi .rts
    ; A = 0
    bit enHp
    bpl .skip_reset_hp
    lda #15-1
    sta enHp
.skip_reset_hp

    lda #$80
    sta enState

; Check player hit
    lda enStun
    bmi .endCheckPlayerHit
    bit plStun
    bmi .endCheckPlayerHit
    jsr HbPlBodyCollide_Ganon
    bcs .endCheckPlayerHit

    lda #1
    eor enDir
    sta enDir

    lda #8
    sta enGanonStep

    lda #-16
    jsr UPDATE_PL_HEALTH
    jsr En_BossGanon_UpdateStunDir
.endCheckPlayerHit

    jsr En_BossGanon_FireMissile

; Movement
    lda #SLOT_F0_EN_MOVE
    sta BANK_SLOT

; update EnMoveNX/NY
    lda en0X
    lsr
    lsr
    sta EnMoveNX
    lda en0Y
    lsr
    lsr
    sta EnMoveNY

.normal_movement
    lda en0X
    and #3
    bne .move
    lda en0Y
    and #3
    bne .move

    jsr En_BossGanon_Card_WallCheck

    dec enGanonStep
    bpl .seek_next
    jsr Random
    and #$7
    clc
    adc #4
    sta enGanonStep

    ldy enDir
    lda EnMoveBlockedDir
    ora Bit8,y
    sta EnMoveBlockedDir
    jsr EnMove_Card_SeekDir
    sty enDir
    bpl .move ; jmp

.seek_next
    jsr EnMove_Card_SeekDirIfBlocked
    sty enDir
.move
    lda #$A0 ; Speed
    clc
    adc enGanonSpdFrac
    sta enGanonSpdFrac
    bcc .rts
    jsr EnMoveDir
.rts
    rts


En_BossGanon_Card_WallCheck: SUBROUTINE
.checkBounds
; Check board boundaries
    lda EnMoveNX
    cmp #[[#EnBoardXR-12]/4]
    lda #0
    bcc .setBlockedL
    ora #EN_BLOCKED_DIR_R
.setBlockedL
    ldx EnMoveNX
    cpx #[[#EnBoardXL+#12]/4] + 1
    bcs .setBlockedD
    ora #EN_BLOCKED_DIR_L
.setBlockedD
    ldx EnMoveNY
    cpx #[[#EnBoardYD+8]/4] + 1
    bcs .setBlockedU
    ora #EN_BLOCKED_DIR_D
.setBlockedU
    cpx #[[#EnBoardYU-8]/4]
    bcc .checkPFHit
    ora #EN_BLOCKED_DIR_U
.checkPFHit
    sta EnMoveBlockedDir
    ldx enNum
    rts


En_BossGanon_FireMissile: SUBROUTINE
    lda enGanonShootT
    cmp #1
    adc #0
    sta enGanonShootT
    bmi .skip_fire_missle

    lda miType
    ror
    bcs .skip_fire_missle

    SET_A_miType #MI_SPAWN_BALL, -8
    sta miType

    lda en0X
    sta mi0X
    lda en0Y
    sta mi0Y

    lda #-32
    sta enGanonShootT
.skip_fire_missle
    rts

En_BossGanon_ClampPlayerPos
; Clamp player position
; X between $0C to $74
; Y between $10 to $48

    lda #$0C
    cmp plX
    bcs .clamp_setX
    lda #$74
    cmp plX
    bcs .clamp_checkY
.clamp_setX
    sta plX

.clamp_checkY
    lda #$10
    cmp plY
    bcs .clamp_setY
    lda #$48
    cmp plY
    bcs .clamp_end
.clamp_setY
    sta plY
.clamp_end
    rts

En_BossGanon_UpdateStunDir: SUBROUTINE
    lda plDir
    and #2
    bne .y_test
.x_test
    ldx #PL_STUN_TIME + [#PL_DIR_R]
    lda plX
    cmp en0X
    bcc .set_plStun
    ldx #PL_STUN_TIME + [#PL_DIR_L]
    bcs .set_plStun ; jmp

.y_test
    ldx #PL_STUN_TIME + [#PL_DIR_U]
    lda plY
    cmp en0Y
    bcc .set_plStun
    ldx #PL_STUN_TIME + [#PL_DIR_D]

.set_plStun
    stx plStun
    rts