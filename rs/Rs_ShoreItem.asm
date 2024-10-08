;==============================================================================
; mzxrules 2022
;==============================================================================
Rs_ShoreItem: SUBROUTINE
    lda #RS_SHORE
    sta roomRS

; check if item should appear
    ldx roomId
    lda rWorldRoomFlags,x
    bmi Rs_Shore ; #WRF_SV_ITEM_GET ;.NoLoad

; Find an open slot to spawn EN_ITEM
    ldx #0
    lda enType
    beq .spawn_item
    inx
.spawn_item
    lda #EN_ITEM
    sta enType,x
    lda #EN_ITEM_PERMANENT
    sta enState,x
    lda roomEX
    sta cdItemType,x
    lda #$6C
    sta en0X,x
    lda #$2C
    sta en0Y,x

Rs_Shore: ; SUBROUTINE
    lda #RF_PF_AXIS
    ora roomFlags
    sta roomFlags
    lda #44
    cmp plX
    bmi .skipWallback
    sta plX
.skipWallback
    rts