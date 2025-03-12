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

    lda roomEX
    sta RsSpawnItem
    lda #$7E
    sta RsSpawnItemExPos

    jsr Rs_SpawnPermItem

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