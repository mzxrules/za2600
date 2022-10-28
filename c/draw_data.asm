;==============================================================================
; mzxrules 2022
;==============================================================================
    
.HUD_SPLIT_TEST:
    .byte 0, 0, 1, 0, 0, 1, 0 ;, 0
    
.HealthPattern:
    .byte $00, $01, $03, $07, $0F, $1F, $3F, $7F
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    
.plSpriteL:
    .byte #<(SprP0 + 7), #<(SprP1 + 7), #<(SprP2 + 7), #<(SprP3 + 7)
    .byte #<(SprP4 + 7)

.Spr8WorldOff:
    .byte 11, 15, 19, 23, 27, 31, 35, 39, 43, 47, 51, 55, 59, 63, 67, 71
    .byte 75, 79, 83, 87

.RoomWorldOff:
    .byte (ROOM_PX_HEIGHT-1), (TEXT_ROOM_PX_HEIGHT-1), (SHOP_ROOM_PX_HEIGHT-1)