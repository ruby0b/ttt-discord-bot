DISCORD.cv                      = {}
DISCORD.cv.enabled              = CreateConVar('discord_enable', 1, { FCVAR_ARCHIVE },
    'Enable / disable the bot')
DISCORD.cv.token                = CreateConVar('discord_token', '', { FCVAR_ARCHIVE, FCVAR_PROTECTED },
    'Set the bot token')
DISCORD.cv.guildID              = CreateConVar('discord_guild', '', { FCVAR_ARCHIVE },
    'Set the guild the bot is in')
DISCORD.cv.mute_icon_enabled    = CreateConVar('discord_mute_icon_enabled', 1, { FCVAR_ARCHIVE },
    'Should muted players have a mute icon in the top right of their screen?')

DISCORD.cv.alive_mute           = CreateConVar('discord_alive_mute', 'nil', { FCVAR_ARCHIVE },
    'Alive players are muted? (1 = true, 0 = false, "nil" = no override)')
DISCORD.cv.alive_deaf           = CreateConVar('discord_alive_deaf', 'nil', { FCVAR_ARCHIVE },
    'Alive players are deaf? (1 = true, 0 = false, "nil" = no override)')

DISCORD.cv.dead_mute            = CreateConVar('discord_dead_mute', 'nil', { FCVAR_ARCHIVE },
    'Dead players are muted? (1 = true, 0 = false, "nil" = no override)')
DISCORD.cv.dead_deaf            = CreateConVar('discord_dead_deaf', 'nil', { FCVAR_ARCHIVE },
    'Dead players are deaf? (1 = true, 0 = false, "nil" = no override)')
DISCORD.cv.dead_duration        = CreateConVar('discord_dead_duration', 0, { FCVAR_ARCHIVE },
    'How long should the death voice state be applied for in seconds? (0 = unlimited)')

DISCORD.cv.ttt_inactive_mute    = CreateConVar('discord_ttt_inactive_mute', 0, { FCVAR_ARCHIVE },
    'Overrides mute state of everyone when not an active round (1 = true, 0 = false, "nil" = no override)')
DISCORD.cv.ttt_inactive_deaf    = CreateConVar('discord_ttt_inactive_deaf', 0, { FCVAR_ARCHIVE },
    'Overrides deaf state of everyone when not an active round (1 = true, 0 = false, "nil" = no override)')

DISCORD.cv.ttt_preparing_active = CreateConVar('discord_ttt_preparing_active', 0, { FCVAR_ARCHIVE },
    'Treat TTT preparing as active?')
DISCORD.cv.ttt_postround_active = CreateConVar('discord_ttt_postround_active', 0, { FCVAR_ARCHIVE },
    'Treat TTT postround as active?')
