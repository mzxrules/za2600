;==============================================================================
; mzxrules 2024
;==============================================================================

WeaponWidth:
WeaponWidth_4px_thick:
    .byte $20, $20, $10, $10
WeaponWidth_8px_thick:
    .byte $30, $30, $10, $10
WeaponWidth_4px_thin:
    .byte $20, $20, $00, $00
WeaponWidth_8px_thin:
    .byte $30, $30, $00, $00


WeaponHeight:
WeaponHeight_4px_thick:
    .byte 1, 1, 3, 3
WeaponHeight_8px_thick:
    .byte 1, 1, 7, 7
WeaponHeight_4px_thin:
    .byte 0, 0, 3, 3
WeaponHeight_8px_thin:
    .byte 0, 0, 7, 7

WeaponOffX:
WeaponOffX_4px:
    .byte -2, 8, 4, 4
WeaponOffX_8px:
    .byte -6, 8, 4, 4

WeaponOffY:
WeaponOffY_4px:
    .byte 3, 3, 7, -3
WeaponOffY_8px:
    .byte 3, 3, 7, -7