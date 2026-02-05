#!/usr/bin/env python3
import itertools

mesg_table = [
    "MesgGameOver", [
      # "012345678901234567890123",
        "        GAME OVER       ",
        " PRESS FIRE TO CONTINUE ",
        ],
    "MesgNeedTriforce", [
        "  ONES WHO DO NOT HAVE  ",
        "  TRIFORCE CAN'T GO IN  ",
        ],
    "MesgTakeThis", [
        "  IT'S DANGEROUS TO GO  ",
        "   ALONE! TAKE THIS.    ",
        ],
    "MesgMasterSword", [
        "  MASTER USING IT AND   ",
        "   YOU CAN HAVE THIS.   ",
        ],
    "MesgNote", [
        "    SHOW THIS TO THE    ",
        "       OLD WOMAN        ",
        ],
    "MesgShopCheap", [
        " BUY SOMETHIN' WILL YA? ",
        "                        ", #"   99      99      99   ", # 34, 12, 9A
        ],
    "MesgShopExpensive", [
        "THIS STUFF SURE IS PRICY",
        "                        ", #"   99      99      99   ", # 34, 12, 9A
        ],
    "MesgPotion", [
        "PLEASE SAVE THE PRINCESS",
        "                        ", #"   99      99      99   ",
        ],
    "MesgChoiceGiveItem", [
        " TAKE ANY ONE YOU WANT  ",
        "                        ", #"   99              99   ",
        ],
    "MesgChoiceTakeItem", [
        "LEAVE YOUR LIFE OR MONEY",
        "                        ", #"  -40             -01   ",
        ],
    "MesgPotion0", [
        "     I DO NOT HELP      ",
        "  FOLLOWERS OF GANON.   ",
        ],
    "MesgGiveRupees", [
        "     IT'S A SECRET      ",
        "     TO EVERYBODY.      ",
        ],
    "MesgTakeRupees", [
        "PAY ME FOR DOOR REPAIRS.",
        "          -10           ",
        ],
    "MesgPath", [
        " TAKE ANY ROAD YOU WANT ",
        "                        ",
        ],
    "MesgMoneyGame", [
        " LET'S PLAY MONEY GAME  ",
        "  -05     -05     -05   ",
        ],
    "MesgEastmostPeninsula", [
        "  EASTMOST PENINSULA    ",
        "     IS THE SECRET      ",
        ],
    "MesgDodongo", [
        " DODONGO DISLIKES SMOKE ",
        "                        ",
        ],
    "MesgHintGrave", [
        "    MEET THE OLD MAN    ",
        "      AT THE GRAVE.     ",
        ],
    "MesgHintLostWoods", [
        "NORTH, WEST, SOUTH, WEST",
        "TO CROSS THE LOST WOODS ",
        ],
    "MesgHintLostHills", [
        "GO UP, UP, THE MOUNTAIN ",
        "          AHEAD         ",
        ],
    "MesgHintTreeAtDeadEnd", [
        " SECRET IS IN THE TREE  ",
        "    AT THE DEAD-END.    ",
        ],
    "MesgPayHintStart", [
        "  PAY ME AND I'LL TALK  ",
        "   99      99      99   ",
        ],
    "MesgPayHintPoor", [
        "   THIS AIN'T ENOUGH    ",
        "         TO TALK        ",
        ],
    "MesgPayHintRich", [
        "    BOY, YOU'RE RICH    ",
        "                        ",
        ],
    "MesgGrumbleGrumble", [
        "   GRUMBLE, GRUMBLE..   ",
        "                        ",
        ],
    "MesgSpectacleRock", [
        "  SPECTACLE ROCK IS AN  ",
        "   ENTRANCE TO DEATH.   ",
        ],
    "MesgGoNextRoom", [
        "  GO TO THE NEXT ROOM   ",
        "                        ",
        ],
    "MesgEyesOfSkull", [
        "  EYES OF SKULL HAVE A  ",
        "         SECRET         ",
        ],
    "MesgHintNose", [
        "  THERE'S A SECRET IN   ",
        "  THE TIP OF THE NOSE.  ",
        ],
    "MesgChoiceGiveBomb", [
        " YOU'D HAVE MORE BOMBS. ",
        "          -40           ",
        ],
    "MesgHintSwordWaterfall", [
        " DID YOU GET THE SWORD  ",
        " FROM TOP OF WATERFALL? ",
        ],
    "MesgHintDigdogger", [
        "    DIGDOGGER HATES     ",
        " CERTAIN KIND OF SOUND. ",
        ],
    "MesgHintSecretPowerArrow", [
        "  SECRET POWER IS SAID  ",
        "   TO BE IN THE ARROW.  ",
        ],
    "MesgHintEyesOfGohma", [
        "     AIM AT THE EYES    ",
        "        OF GOHMA.       ",
        ],
    "MesgHintFairiesDontLive", [
        " THERE ARE SECRETS WHERE",
        "   FAIRIES DON'T LIVE.  ",
        ],
    "MesgHintWalkIntoTheWaterfall", [
        "     WALK INTO THE      ",
        "       WATERFALL.       ",
        ],
    "MesgHintPatraHasMap", [
        "   PATRA HAS THE MAP.   ",
        "                        ",
        ],
    "MesgHintDirectionOfArrow", [
        "    IF YOU GO IN THE    ",
        " DIRECTION OF THE ARROW ",
        ],
    "MesgHintSouthOfArrow", [
        "  SOUTH OF ARROW MARK   ",
        "     HIDES A SECRET     ",
        ],
    "MesgHintTenthEnemy", [
        "10TH ENEMY HAS THE BOMB ",
        "                        ",
        ],
    "MesgLevel", [
        "          LEVEL         ",
        "            9           ",
        ],
]

mesg_ids = mesg_table[::2]
mesg_data = list(itertools.chain.from_iterable(mesg_table[1::2]))