;==============================================================================
; mzxrules 2024
;==============================================================================
EN_ITEM_DRAW            = #$80
EN_ITEM_INIT            = #$40
EN_ITEM_TYPE_MASK       = #$01
EN_ITEM_TYPE_RNG        = #$00
EN_ITEM_TYPE_PERMANENT  = #$01
EN_ITEM_SET_EXPOS       = #$02
EN_ITEM_APPEAR_TIME     =  -75 ; * 4 frames

EnItem: SUBROUTINE
    lda #SLOT_F0_SHOP
    sta BANK_SLOT

; Delay item rendering in the event RS overrides type
    lda enState,x
    and #EN_ITEM_INIT
    beq .skip_set_draw
    lda enState,x
    ora #EN_ITEM_DRAW
    sta enState,x
.skip_set_draw

; Set initialized
    lda enState,x
    ora #EN_ITEM_INIT
    sta enState,x

    and #EN_ITEM_SET_EXPOS
    beq .main
; Set init position
    lda enState,x
    and #~#EN_ITEM_SET_EXPOS
    sta enState,x

    lda cdItemExPos,x
    tay
    bne .set_ex_pos

.set_center_pos
    lda #$40
    sta en0X,x
    lda #$2C
    sta en0Y,x
    bne .endCollisionCheck ; jmp

.set_ex_pos
    ; x range $0C to $74
    ; y range $10 to $48
    and #$F
    tay
    lda EnItem_ExPosX,y
    sta en0X,x
    lda cdItemExPos,x
    and #$F0
    lsr
    lsr
    adc #$10
    sta en0Y,x
    bne .endCollisionCheck ; jmp

.main
    bit plState2
    bvc .endCollisionCheck ; EN_LAST_DRAWN
    bit CXPPMM
    bpl .endCollisionCheck ; Player hasn't collided with Entity

    lda enState,x
    and #~[#GI_EVENT_RESERVED | #EN_ITEM_DRAW]
    cmp #EN_ITEM_INIT | #EN_ITEM_TYPE_PERMANENT
    beq .collide_perm_drop

.collide_rng_drop
    jsr GiItemDel
    ldx enNum
    lda #EN_NONE
    sta enType,x
    jmp .endCollisionCheck

.collide_perm_drop
    lda roomId
    and #$7F
    tay
    lda rWorldRoomFlags,y
    ora #WRF_SV_ITEM_GET
    sta wWorldRoomFlags,y

    lda cdItemType,x
    cmp #GI_TRIFORCE
    bne .skip_pos_player_tri
    lda #$40
    sta plX
    lda #$2C
    sta plY
.skip_pos_player_tri
; If key...
    cmp #GI_KEY
    beq .EnItem_GiItem
; or basic item, fast collect it
    cmp #GI_TRIFORCE
    bcc .EnItem_GiItem
    jmp ItemGet
.EnItem_GiItem
    lda #EN_NONE
    sta enType,x
    jmp GiItemDel
.endCollisionCheck

    lda enState,x
    and #EN_ITEM_TYPE_MASK
    cmp #EN_ITEM_TYPE_RNG
    bne .rts

    lda Frame
    and #3
    bne .skip_update_timer
    lda cdItemTimer,x
    cmp #1
    adc #0
    sta cdItemTimer,x
    bne .rts
    lda #SLOT_F0_EN
    sta BANK_SLOT
    jmp EnSysDelete
.skip_update_timer
.rts
    rts

EnItem_ExPosX:
    .byte $0C, $14, $18, $20
    .byte $28, $30, $34, $38
    .byte $44, $48, $4C, $54
    .byte $5C, $64, $6C, $74