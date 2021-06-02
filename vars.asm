; ****************************************
; * Variables                            *
; ****************************************

    SEG.U VARS_ZERO
    ORG $80
Frame       ds 1
Rand8       ds 1
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

m0H         ds 1
m1H         ds 1
blH         ds 1

plXL        ds 1
enXL        ds 1
plYL        ds 1
enYL        ds 1
plSpr       ds 2 ; plSprOff
enSpr       ds 2 ; enSprOff
plDir       ds 1
enDir       ds 2
enType      ds 2
enState     ds 1
enColor     ds 2
enBlockDir  ds 1
enStun      ds 1
enRecoil    ds 1

bgColor     ds 1
fgColor     ds 1
worldId     ds 1
worldBank   ds 1
worldSX     ds 1 ; respawn X
worldSY     ds 1 ; respawn Y
worldSR     ds 1 ; respawn room
roomId      ds 1
roomSpr     ds 1
roomFlags   ds 1
    ; 1000_0000 Force Load Room
    ; 0100_0000 Room Load happened this frame
roomDoors   ds 1
    ; xxxx_xx11 N
    ; xxxx_11xx S
    ; xx11_xxxx E
    ; 11xx_xxxx W
roomRS      ds 1
roomEN      ds 1
roomENCount ds 1
roomEX      ds 1
roomWA      ds 1
plState     ds 1
    ; 1000_0000 Fire Pressed Last Frame
    ; 0100_0000 Use Current Item
    ; 0000_1000 Enemy Is Wall
    ; 0000_0100 Playfield Ignore
    ; 0000_0010 Lock Player
    ; 0000_0001 Lock Player Axis
plHealthMax ds 1
plHealth    ds 1
plItemTimer ds 1
itemRupees  ds 1
itemKeys    ds 1
itemBombs   ds 1
itemTri     ds 1
itemFlags   ds 2
mesgId      ds 1
SeqFlags    ds 1
    ; 1xxx_xxxx New Sequence
    ; x1xx_xxxx Mute Seq Channel 1
    ; xxxx_1xxx Sequence Channel 1
    ; xxxx_x111 Sequence
SeqTFrame   ds 2
SeqCur      ds 2
SfxFlags    ds 1
    ; 1xxx_xxxx New Sfx
SfxCur      ds 1

NUSIZ0_T    ds 1
mapSpr      ds 2
Temp0       ds 1
Temp1       ds 1
Temp2       ds 1
Temp3       ds 1
Temp4       ds 1
Temp5       ds 1
Temp6       ds 1

    SEG.U VARS_AUD_ZERO
    ORG Temp4
AUDCT0      ds 1
AUDCT1      ds 1
AUDFT0      ds 1
AUDFT1      ds 1
AUDVT0      ds 1
AUDVT1      ds 1

    SEG.U VARS_HUD_ZERO
    ORG Temp0
TMapPosY    ds 1
THudHealthL ds 1
THudHealthH ds 1
THudTemp    ds 1
THudDigits  ds 6

    SEG.U VARS_TEXT_ZERO
    ORG mapSpr
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
    
    ORG $F000
WORLD_T_PF1L    ds 256
WORLD_T_PF1R    ds 256
WORLD_T_PF2     ds 256
WORLD_COLOR     ds 256
WORLD_RS        ds 256 ; Room Script
WORLD_EX        ds 256 ; Extra Data (Exits, Items)
WORLD_EN        ds 256 ; Enemy Encounter
WORLD_WA        ds 256 ; Bombable walls


    SEG.U VARS_RAM
    ORG $F800
wPF1RoomL   ds ROOM_PX_HEIGHT
wPF2Room    ds ROOM_PX_HEIGHT
wPF1RoomR   ds ROOM_PX_HEIGHT
wRoomClear  ds 256/8

    ORG $F900
rPF1RoomL   ds ROOM_PX_HEIGHT
rPF2Room    ds ROOM_PX_HEIGHT
rPF1RoomR   ds ROOM_PX_HEIGHT
rRoomClear  ds 256/8

    SEG.U VARS_ROOM
    ORG $F800
wRAM_SEG
wRoomFlag   ds 256
rRAM_SEG
rRoomFlag   ds 256
    ; dungeons only
    ; xxxx_xxx1 N open
    ; xxxx_x1xx S open
    ; xxx1_xxxx E open
    ; x1xx_xxxx W open
    ; 1xxx_xxxx Got Item
    
; ****************************************
; * Constants                            *
; ****************************************

BANK_ROM    = $1FE0
BANK_RAM7   = $1FE7
BANK_RAM    = $1FE8

ROOM_PX_HEIGHT      = 20 ; height of room in pixels
ROOM_SPR_HEIGHT     = 16 ; height of room sprite sheet
ROOM_SPR_SHEET      = 16 ; width of room sprite sheet in 8 bit sprites
ROOM_HEIGHT         = [(8*ROOM_PX_HEIGHT)/2-1] ; Screen visible height of play
TEXT_ROOM_PX_HEIGHT = 16 ; height of room in pixels, when text is displayed
TEXT_ROOM_HEIGHT    = [(8*TEXT_ROOM_PX_HEIGHT)/2-1] ;
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

; U/D, pX $3C-$44
; L/R, pY $28-$30
BoardKeydoorUDA = $3C
BoardKeydoorLRA = $28
BoardKeydoorUY = $48+1
BoardKeydoorDY = $10-1
BoardKeydoorLX = $0C-1
BoardKeydoorRX = $74+1


ItemTimerSword  = -9 ; counts up to 0

PlState_ItemButtonRepeat    = $80
PlState_ItemButton          = $40
PlState_Stab                = $20

COLOR_DARKNUT_RED   = $42
COLOR_DARKNUT_BLUE  = $74
COLOR_PATH          = $3C
COLOR_GREEN_ROCK    = $D0
COLOR_CHOCOLATE     = $F0
COLOR_EARTH         = $F2
COLOR_LIGHT_WATER   = $A4
COLOR_LIGHT_BLUE    = $88
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
MS_PLAY_THEME   = $84
MS_PLAY_THEME_L = $85

SFX_STAB        = $81
SFX_BOMB        = $82
SFX_ITEM_PICKUP = $83
    MACRO LOG_SIZE
        echo .- {2}+$8000,{2},(.),{1}
    ENDM

    MACRO VSLEEP
    bvs .j0
.j0
    bvs .j1
.j1
    ENDM