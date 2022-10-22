;==============================================================================
; mzxrules 2022
;==============================================================================

En_ItemGet: SUBROUTINE
    lda cdAType
    cmp #GI_TRIFORCE
    beq .rts
    lda SeqFlags
    and #$0F
    cmp #[MS_PLAY_GI & $0F]
    beq .rts
    lda plState2
    and #~PS_HOLD_ITEM
    sta plState2
    lda plState
    and #~PS_LOCK_ALL
    sta plState
    ldx #EN_NONE
    stx cdAType

    ldx #EN_SHOPKEEPER
    lda enState
    and #GI_EVENT_SHOP
    bne .end
    ldx #EN_CLEAR_DROP
.end
    stx enType
.rts 
    rts