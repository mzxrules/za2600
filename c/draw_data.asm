;==============================================================================
; mzxrules 2022
;==============================================================================

.plSpriteL:
    .byte #<(SprP0 + 7), #<(SprP1 + 7), #<(SprP2 + 7), #<(SprP3 + 7)
    .byte #<(SprP4 + 7), #<(SprP5 + 7), #<(SprP2 + 7), #<(SprP7 + 7)
    .byte #<(SprP6 + 7)

.RoomHeight
    .byte 03, 07

.Spr8WorldOff:
    .byte 11, 15, 19, 23, 27, 31, 35, 39, 43, 47, 51, 55, 59, 63, 67, 71
    .byte 75, 79, 83, 87

.RoomWorldOff:
    .byte (ROOM_PX_HEIGHT-1), (TEXT_ROOM_PX_HEIGHT-1), (SHOP_ROOM_PX_HEIGHT-1)