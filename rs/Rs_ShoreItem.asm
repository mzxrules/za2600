;==============================================================================
; mzxrules 2022
;==============================================================================
Rs_ShoreItem: SUBROUTINE
    lda #RF_PF_AXIS
    ora roomFlags
    sta roomFlags
    lda #44
    cmp plX
    bmi .skipWallback
    sta plX
.skipWallback
    ; check if item should appear
    lda enType
    cmp #EN_CLEAR_DROP
    bne .rts
    ldx roomId
    lda rWorldRoomFlags,x
    bmi .rts ; #WRF_SV_ITEM_GET ;.NoLoad

    lda #$6C
    sta cdAX
    lda #$2C
    sta cdAY
    lda #EN_ITEM
    sta cdAType
.rts
    rts