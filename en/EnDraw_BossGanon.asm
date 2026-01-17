;==============================================================================
; mzxrules 2025
;==============================================================================

EnDraw_BossGanon_DrawTri: SUBROUTINE
    ldy #GI_TRIFORCE
    lda enState
    ror ; EN_BOSS_GANON_SPRITE_MASK
    bcc .draw_triforce
    ldy #GI_POWER
.draw_triforce
    jmp EnDraw_Item

EnDraw_BossGanon: SUBROUTINE
    jsr EnDraw_SmallMissile

    lda enGanonColor
    sta wEnColor

EnDraw_BossGanon_SetKernel:
    lda enState
    and #EN_BOSS_GANON_DRAW_BOSS4
    bne .Boss4

.GameView:
    lda <#KERNEL_WORLD_RESUME
    sta wWorldKernelDraw
    lda >#KERNEL_WORLD_RESUME
    sta wWorldKernelDraw+1
    lda #HALT_KERNEL_GAMEVIEW
    sta wHaltKernelId

    lda en0X
    sta enX
    lda en0Y
    sta enY

    bit enState
    bvs EnDraw_BossGanon_DrawTri

    lda #%10000
    sta wNUSIZ1_T
    jmp EnDraw_None

.Boss4
    lda #SLOT_RW_F0_BOSS4
    sta BANK_SLOT_RAM
    sta wGanonShow

    jsr Boss4_SetPlayerSpr

    lda <#KERNEL_BOSS4
    sta wWorldKernelDraw
    lda >#KERNEL_BOSS4
    sta wWorldKernelDraw+1
    lda #HALT_KERNEL_GAMEVIEW_GANON
    sta wHaltKernelId

    lda en0Y
    clc
    adc #-8
    sta enY

    lda Frame
    and #1
    tax

EnDraw_BossGanon_SpriteFrame
    lda en0X
    cmp #$0D+12
    bcs .have_x
    lda #$0D+12
.have_x
    clc
    adc .spriteOffTbl,x
    sta enX

; Allows the sprite to be drawn between Y = $08 to $38
    lda .spriteTblL,x
    sec
    sbc enY
    sta enSpr2
    adc #-$50-1
    sta enSpr

    lda .spriteTblH,x
    sta enSpr+1
    sta enSpr2+1

EnDraw_BossGanon_Boss4Missile
    lda m1X
    clc
    adc #$FF
    sta blX

    lda #>rMISPR_MEM
    sta enMSpr+1

    lda miType
    ror
    lda #<rMISPR_NONE
    bcc .no_draw

    lda #<rMISPR_MEM + $50+1
    sec
    sbc mi0Y
.no_draw
    sta enMSpr

; Calculate what draw kernel to use
    lda enX
    sec
    sbc #$0D
    ; divide by 9
    sta KERNEL_TEMP
    lsr
    lsr
    lsr
    adc KERNEL_TEMP
    ror
    adc KERNEL_TEMP
    ror
    adc KERNEL_TEMP
    ror
    lsr
    lsr
    lsr
    ; result
    sta wGanonKernelId
    rts

.spriteOffTbl:
    .byte #0-12, #8-12

.spriteTblL:
    .byte #<SprGanon2 + $30+8, #<SprGanon3 + $30+8
.spriteTblH:
    .byte #>SprGanon0, #>SprGanon1


Boss4_SetPlayerSpr:
; Flush player sprite mem
    ldy rPLSPR_y
    cpy #BOSS4_ROOM_DY_HEIGHT + 8 + 1
    bcs .skip_plspr_wipe

    lda #0
    sta wPLSPR_MEM+0,y
    sta wPLSPR_MEM+1,y
    sta wPLSPR_MEM+2,y
    sta wPLSPR_MEM+3,y
    sta wPLSPR_MEM+4,y
    sta wPLSPR_MEM+5,y
    sta wPLSPR_MEM+6,y
    sta wPLSPR_MEM+7,y
.skip_plspr_wipe

    ldy rPLMSPR_y
    cpy #BOSS4_ROOM_DY_HEIGHT + 8 + 1
    bcs .skip_plmspr_wipe
    lda #0
    sta wPLMSPR_MEM+0+1,y
    sta wPLMSPR_MEM+1+1,y
    sta wPLMSPR_MEM+2+1,y
    sta wPLMSPR_MEM+3+1,y
    sta wPLMSPR_MEM+4+1,y
    sta wPLMSPR_MEM+5+1,y
    sta wPLMSPR_MEM+6+1,y
    sta wPLMSPR_MEM+7+1,y
.skip_plmspr_wipe

    ldx m0Y
    cpx #BOSS4_ROOM_DY_HEIGHT + 8 + 1
    bcs .skip_write_plmspr
    stx wPLMSPR_y
    ldy rM0H
    lda #$FF
.plmspr_write_loop
    sta wPLMSPR_MEM+1,x
    inx
    dey
    bpl .plmspr_write_loop
.skip_write_plmspr
    rts