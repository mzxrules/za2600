; ****************************************
; * Variables                            *
; ****************************************
    SEG.U VARS_ZERO
    ORG $80
Frame       ds 1
Rand16      ds 2
KernelId    ds 1
plX         ds 1
enX         ds 1
m0X         ds 1
m1X         ds 1
blX         ds 1
plY         ds 1
enY         ds 1
m0Y         ds 1
m1Y         ds 1
blY         ds 1
plDY        ds 1
enDY        ds 1
m0DY        ds 1
m1DY        ds 1
blDY        ds 1

; KERNEL VARS
; ENH
; M0H
; M1H
; BLH

plXL        ds 1
enXL        ds 1
plYL        ds 1
enYL        ds 1
plSpr       ds 2 ; plSprOff
enSpr       ds 2 ; enSprOff
plDir       ds 1
enDir       ds 1
enType      ds 1
enColor     ds 1

EN_VARIABLES:
; EnemyCommon
enState     ds 1
enHp        ds 1
enStun      ds 1
enBlockDir  ds 1
EN_ENEMY_VARIABLES:
    ORG EN_ENEMY_VARIABLES
; Darknut
    ORG EN_ENEMY_VARIABLES
; Wallmaster
enWallPhase ds 1 ; anim timer for phasing through wall
enPX        ds 1 ; posX last frame, after collision check
enPY        ds 1 ; posY last frame, after collision check
    ORG EN_ENEMY_VARIABLES
; Octorok
enTimer     ds 1
enMDX       ds 1
enMDY       ds 1
    ORG EN_ENEMY_VARIABLES
; LikeLike
enLLTimer   ds 1
    ORG EN_VARIABLES
; Gameover
enInputDelay ds 1
    ORG EN_VARIABLES + 1
; ClearDrop
;enState     ds 1
CD_UPDATE_B     = $80
CD_UPDATE_A     = $40
CD_LAST_UPDATE  = $01 ; Stores previous frame's active entity
cdBTimer    ds 1
cdAType     ds 1 ; Equivalent to enType
cdBType     ds 1 ; Correspond to GiItems, such that 1 = GiItem 0
CD_ITEM_RAND = $FF
cdAX        ds 1
cdBX        ds 1
cdAY        ds 1
cdBY        ds 1
    ORG EN_VARIABLES + 1
; EnShopkeeper
shopItem    ds 3
shopDigit   ds 3
    ORG EN_VARIABLES + 1
enTestDir   ds 1
enTestFX    ds 1
enTestFY    ds 1
enTestTimer ds 1


    ORG EN_VARIABLES
En0V        ds 10 ; Zero initialized enemy vars
EN_0V_END:

; Missile Vars
mAType      ds 1
mBType      ds 1
mAx         ds 1
mBx         ds 1
mAxf        ds 1
mBxf        ds 1
mAy         ds 1
mBy         ds 1
mAyf        ds 1
mByf        ds 1
mADir       ds 1
mBDir       ds 1
mATimer     ds 1
mBTimer     ds 1

blType      ds 1 ;
blTemp      ds 1 ; Room ball state
blDir       ds 1        

;BgColor    ds 1
;FgColor    ds 1
worldId     ds 1
worldSX     ds 1 ; respawn X
worldSY     ds 1 ; respawn Y
worldSR     ds 1 ; respawn room
roomId      ds 1
roomSpr     ds 1
roomTimer   ds 1 ; Shutter animation timer
roomFlags   ds 1
RF_LOAD_EV      = $80 ; 1000_0000 Force Load Room
RF_LOADED_EV    = $40 ; 0100_0000 Room Load happened this frame
RF_ENCLEAR_EV   = $20 ; 0010_0000 Enemy Clear event
RF_NO_ENCLEAR   = $10 ; 0001_0000 Blocks Enemy Cleared from setting Room Cleared
RF_CLEAR        = $08 ; 0000_1000 Room Cleared (Enemies dead, or puzzle solved)
roomDoors   ds 1
    ; xxxx_xx11 N
    ; xxxx_11xx S
    ; xx11_xxxx E
    ; 11xx_xxxx W
roomRS      ds 1
roomEN      ds 1 ; encounter type
roomENCount ds 1 ; num encounters
roomEX      ds 1
roomWA      ds 1
plState     ds 1
    ; 1000_0000 Fire Pressed Last Frame
    ; 0100_0000 Use Current Item Event
    ; 0010_0000 Move Until Unblocked
    ; 0001_0000 Swap item event
    ; 0000_1000 P1 Is Wall
    ; 0000_0100 Playfield Ignore
    ; 0000_0010 Lock Player
    ; 0000_0001 Lock Player Axis - Hover Boots
plState2    ds 1
    ; 0000_0011 Active Item
    ;        00 Sword
    ;        01 Bombs
    ;        10 Bow
    ;        11 Flame
plStun      ds 1
plHealthMax ds 1
plHealth    ds 1
plItemTimer ds 1
plItemDir   ds 1
itemRupees  ds 1
itemKeys    ds 1 ; Sign bit = Master Key
itemBombs   ds 1
itemTri     ds 1
itemMaps    ds 1 ; Level 2-9
itemFlags   ds 3
; ITEMV_name = item var
; ITEMF_name = item flag
    ITEM SWORD2,        0,$40
    ITEM SWORD3,        0,$80

    ITEM BOW,           1,$01
    ITEM RAFT,          1,$02
    ITEM BOOTS,         1,$04
    ITEM FLUTE,         1,$08
    ITEM FIRE_MAGIC,    1,$10
    ITEM BRACELET,      1,$20
    ITEM MEAT,          1,$40
    ITEM NOTE,          1,$80

    ITEM ARROWS,        2,$01
    ITEM ARROWS_SILVER, 2,$02
    ITEM CANDLE_BLUE,   2,$04
    ITEM CANDLE_RED,    2,$08
    ITEM RING_BLUE,     2,$10
    ITEM RING_RED,      2,$20
    ITEM POTION_BLUE,   2,$40
    ITEM POTION_RED,    2,$80

mesgId      ds 1
SeqFlags    ds 1
    ; 1xxx_xxxx New Sequence
    ; 11xx_xxxx Play Region Sequence
    ; xxxx_1xxx Reserved for sequence's second channel
    ; xxxx_x111 Sequence
SeqTFrame   ds 2
SeqCur      ds 2
SfxFlags    ds 1
    ; 1xxx_xxxx New Sfx
SfxCur      ds 1

NUSIZ0_T    ds 1
NUSIZ1_T    ds 1

atan2Temp   ds 1

; Context Temp Vars
Temp0       ds 1
Temp1       ds 1
Temp2       ds 1
Temp3       ds 1
Temp4       ds 1
Temp5       ds 1
Temp6       ds 1

    SEG.U VARS_AUD_ZERO
    ORG Temp0 + 4
AUDCT0      ds 1
AUDCT1      ds 1
AUDFT0      ds 1
AUDFT1      ds 1
AUDVT0      ds 1
AUDVT1      ds 1

    SEG.U VARS_HUD_ZERO
    ORG Temp0
THudMapSpr      ds 2
THudMapPosY     ds 1
THudHealthMaxL  ds 1
THudHealthL     ds 1
THudHealthMaxH  ds 1
THudHealthH     ds 1
THudTemp        ds 1
THudDigits      ds 6
    ORG THudHealthMaxH
THudHealthDisp  ds 1
    
    SEG.U VARS_EN_SYS
    ORG Temp0 + 1
;Temp0          ds 1
EnSysSpawnTry   ds 1
EnSysNext       ds 1
EnSysClearOff   ds 1 ; offset to byte that room clear is stored at
EnSysClearMask  ds 1 ; stores bitmask for room clear flag
    
    SEG.U VARS_MI_SYS
    ORG Temp0
MiSysDir        ds 1
MiSysDX         ds 1
MiSysDY         ds 1
MiSysAddType    ds 1
MiSysAddX       ds 1
MiSysAddY       ds 1

    SEG.U VARS_SHOP_KERNEL
    ORG Temp0
ShopSpr0    ds 2
ShopSpr1    ds 2
ShopSpr2    ds 2
ShopDrawY   ds 1

    SEG.U VARS_TEXT_ZERO
    ORG Temp0
TextLoop    ds 1
TMesgPtr    ds 2
Temp        ds 1
Text0       ds 1
Text1       ds 1
Text2       ds 1
Text3       ds 1
Text4       ds 1
Text5       ds 1
Text6       ds 1
Text7       ds 1
Text8       ds 1
Text9       ds 1
Text10      ds 1
Text11      ds 1

    echo "-RAM-",$80,(.)

; Level Data Banks 1 and 2

    ORG $F400
WORLD_T_PF1L    ds 128
WORLD_T_PF1R    ds 128
WORLD_T_PF2     ds 128
WORLD_COLOR     ds 128
WORLD_RS        ds 128 ; Room Script
WORLD_EX        ds 128 ; Extra Data (Exits, Items)
WORLD_EN        ds 128 ; Enemy Encounter
WORLD_WA        ds 128 ; Bombable walls

; Ram Bank 0
    SEG.U VARS_RAM
    ORG $FA00
wRAM_SEG
wKERNEL     ds KERNEL_LEN
wPF1RoomL   ds ROOM_PX_HEIGHT
wPF2Room    ds ROOM_PX_HEIGHT
wPF1RoomR   ds ROOM_PX_HEIGHT
wRoomClear  ds 256/8            ; All Enemies Defeated flags
    ORG $FB00
wRoomFlag   ds 256

    ORG $F800
rRAM_SEG
rKERNEL     ds KERNEL_LEN
rPF1RoomL   ds ROOM_PX_HEIGHT
rPF2Room    ds ROOM_PX_HEIGHT
rPF1RoomR   ds ROOM_PX_HEIGHT
rRoomClear  ds 256/8            ; All Enemies Defeated flags
    ORG $F900
rRoomFlag   ds 256
    ; all world types
    ; 1xxx_xxxx Got Item
    ; dungeons only
    ; xxxx_xxx1 N open
    ; xxxx_x1xx S open
    ; xxx1_xxxx E open
    ; x1xx_xxxx W open
    
; ****************************************
; * Constants                            *
; ****************************************

KERNEL_LEN  = $90   ; World Kernel length

ROOM_PX_HEIGHT      = 20 ; height of room in pixels
ROOM_SPR_HEIGHT     = 16 ; height of room sprite sheet
ROOM_SPR_SHEET      = 16 ; width of room sprite sheet in 8 bit sprites
ROOM_HEIGHT         = [(8*ROOM_PX_HEIGHT)/2-1] ; Screen visible height of play
TEXT_ROOM_PX_HEIGHT = 16 ; height of room in pixels, when text is displayed
TEXT_ROOM_HEIGHT    = [(8*TEXT_ROOM_PX_HEIGHT)/2-1] ;
SHOP_ROOM_PX_HEIGHT = 13 ; height of room in pixels
SHOP_ROOM_HEIGHT    = [(8*SHOP_ROOM_PX_HEIGHT)/2-1] ;
GRID_STEP           = 4 ; unit grid that the player should snap to
MAX_LOCKS           = 16

BoardXL = $04
BoardXR = $7C
BoardYU = $50
BoardYD = $08
EnBoardXL = BoardXL+8
EnBoardXR = BoardXR-8
EnBoardYU = BoardYU-8
EnBoardYD = BoardYD+8

EN_V0_COUNT = EN_0V_END - EN_VARIABLES

; U/D, pX $3C-$44
; L/R, pY $28-$30
BoardKeydoorUDA = $3C
BoardKeydoorLRA = $28
BoardKeydoorUY = $48+1
BoardKeydoorDY = $10-1
BoardKeydoorLX = $0C-1
BoardKeydoorRX = $74+1


ItemTimerSword  = <-9 ; counts up to 0

PlState_ItemButtonRepeat    = $80
PlState_ItemButton          = $40
PlState_Stab                = $20

COLOR_BLACK         = $00
COLOR_WHITE         = $0E
COLOR_DARKNUT_RED   = $42
COLOR_OCTOROK_BLUE  = $72
COLOR_DARKNUT_BLUE  = $74
COLOR_PATH          = $3C
COLOR_GREEN_ROCK    = $D0
COLOR_CHOCOLATE     = $F0
COLOR_EARTH         = $F2
COLOR_LIGHT_WATER   = $A4
COLOR_LIGHT_BLUE    = $88
COLOR_LIGHT_BLUE2   = $86 ; World
COLOR_DARK_BLUE     = $90
COLOR_GOLDEN        = $1E
COLOR_TRIFORCE      = $2A

COLOR_PLAYER_00 = $C6
COLOR_PLAYER_01 = $08
COLOR_PLAYER_02 = $46

COLOR_MINIMAP   = $84

MS_PLAY_NONE    = $80
MS_PLAY_DUNG    = $81
MS_PLAY_GI      = $82
MS_PLAY_OVER    = $83
MS_PLAY_THEME   = $84 ; Overworld Theme with intro
MS_PLAY_THEME_L = $85 ; Overworld Theme without intro
MS_PLAY_RSEQ    = $40 | MS_PLAY_THEME   ; Plays region local sequence
MS_PLAY_RSEQ_L  = $40 | MS_PLAY_THEME_L ; Plays region local sequence
MS_PLAY_FINAL   = $86

; ATAN2 Lookup Constants
ATAN2_SIGNX     = $80
ATAN2_SIGNY     = $40
DEG_000         = $01
DEG_090         = $08
DEG_180         = DEG_000 | ATAN2_SIGNX
DEG_270         = DEG_090 | ATAN2_SIGNY

BIT_01 = Bit8
BIT_02 = Bit8 + 1
BIT_04 = Bit8 + 2
BIT_08 = Bit8 + 3
BIT_10 = Bit8 + 4
BIT_20 = Bit8 + 5
BIT_40 = Bit8 + 6
BIT_80 = Bit8 + 7

EN_BLOCKDIR_L = 1
EN_BLOCKDIR_R = 2
EN_BLOCKDIR_U = 4
EN_BLOCKDIR_D = 8

RAMSEG_F0 = $00
RAMSEG_F4 = $40
RAMSEG_F8 = $80
RAMSEG_FC = $C0

BANK_SLOT_RAM = $3E
BANK_SLOT = $3F

SLOT_ALWAYS = RAMSEG_FC | 1
SLOT_DRAW   = RAMSEG_F4 | 2
SLOT_ROOM   = RAMSEG_F0 | 3

SLOT_PF_A   = RAMSEG_F4 | 4
SLOT_SP_A   = RAMSEG_F0 | 5
SLOT_SP_A2  = RAMSEG_F4 | 5

SLOT_W0     = RAMSEG_F4 | 6
SLOT_W1     = RAMSEG_F4 | 7
SLOT_W2     = RAMSEG_F4 | 8

SLOT_RW0    = RAMSEG_F8 | 0
SLOT_RW1    = RAMSEG_F8 | 1
SLOT_RW2    = RAMSEG_F8 | 2

SLOT_TX_A   = RAMSEG_F0 | 10
SLOT_TX_B   = RAMSEG_F4 | 11

SLOT_EN_A   = RAMSEG_F0 | 12
SLOT_EN_B   = RAMSEG_F4 | 13

SLOT_AU_A   = RAMSEG_F0 | 14
SLOT_AU_B   = RAMSEG_F4 | 15

SLOT_RS_A   = RAMSEG_F0 | 16
SLOT_RS_B   = RAMSEG_F4 | 17

SLOT_PL_A   = RAMSEG_F0 | 16
SLOT_PL_B   = RAMSEG_F4 | 17

SLOT_SH     = RAMSEG_F0 | 18