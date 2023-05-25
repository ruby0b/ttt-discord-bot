# TTT Discord Bot

Automatic Discord muting/deafening when configurable TTT events happen.
This addon is highly customizable and can replicate the behavior of other TTT discord addons.
It is written exclusively in Lua and does not require an extra node discord bot, unlike [Discord Muter for GMod](https://github.com/marceltransier/ttt_discord_bot).

Some common example configurations are included below.

## Setup

1. Install [CHTTP](https://github.com/timschumi/gmod-chttp) on the server.
2. Install this addon.
3. Create a discord bot, add it to your server and give it permission to deafen and mute members.
4. Set `discord_token` to your bot's token.
5. Set `discord_guild` to your [discord server ID](https://support.discord.com/hc/en-us/articles/206346498-Where-can-I-find-my-User-Server-Message-ID-).
6. Configure the ConVars to your liking (the default values won't do anything).

## Example Configurations

### Mute on Death

Mute dead players for 10 seconds. Leave `discord_dead_duration` at `0` to mute them until the end of the round.

```
discord_dead_mute 1
discord_dead_duration 10
```

### Deaf while Alive

Alive players are deafened while in an active round. Works great alongside a proximity voice chat addon such as [this one](https://steamcommunity.com/sharedfiles/filedetails/?id=2051674221) (or use your own [PlayerCanHearPlayersVoice hook](https://wiki.facepunch.com/gmod/GM:PlayerCanHearPlayersVoice)).

```
discord_alive_deaf 1
```

## All ConVars

```
discord_enable               (default: 1)     Enable / disable the bot
discord_token                (default: '')    Set the bot token
discord_guild                (default: '')    Set the guild the bot is in
discord_mute_icon_enabled    (default: 1)     Should muted players have a mute icon in the top right of their screen?
discord_alive_mute           (default: 'nil') Alive players are muted? (1 = true, 0 = false, "nil" = no override)
discord_alive_deaf           (default: 'nil') Alive players are deaf? (1 = true, 0 = false, "nil" = no override)
discord_dead_mute            (default: 'nil') Dead players are muted? (1 = true, 0 = false, "nil" = no override)
discord_dead_deaf            (default: 'nil') Dead players are deaf? (1 = true, 0 = false, "nil" = no override)
discord_dead_duration        (default: 0)     How long should the death voice state be applied for in seconds? (0 = unlimited)
discord_ttt_inactive_mute    (default: 0)     Overrides mute state of everyone when not an active round (1 = true, 0 = false, "nil" = no override)
discord_ttt_inactive_deaf    (default: 0)     Overrides deaf state of everyone when not an active round (1 = true, 0 = false, "nil" = no override)
discord_ttt_preparing_active (default: 0)     Treat TTT preparing as active?
discord_ttt_postround_active (default: 0)     Treat TTT postround as active?
```

## Discord Account Mapping

We need to know every player's [Discord user ID](https://support.discord.com/hc/en-us/articles/206346498-Where-can-I-find-my-User-Server-Message-ID-):
Players (with the `discord_manage` ULib permission) can type `!discord DISCORD_ID` to set their own Discord account.

Admins (with the `discord_manage_others` ULib permission) can also type `!discord DISCORD_ID PLAYER_NAME` to set other players' Discord accounts for them.

(You could also just manually edit `garrysmod/data/discord_player_map.json` and insert the [steamID](https://www.steamidfinder.com/) → Discord user ID mappings as JSON: `{ "STEAM_0:0:123456789": "123456789123456789" }`)

## Commands

- `discord_pause` Pause / Unpause the Discord addon. Pausing will temporarily unmute and undeafen everyone. This can come in handy when you want to announce something mid-game or when the addon somehow gets stuck. I personally use a binding for this: `bind p discord_pause`

## Implementation

The default User-Agent used by the HTTP module of Garry's Mod is [banned by Discord](https://github.com/Owningle/TTT-Discord-Immersion/issues/1).
That is why other discord addons communicate with an external Discord bot via localhost HTTP which would then send the actual requests to Discord.
This addon uses the approach from [TTT Discord Immersion](https://github.com/Owningle/TTT-Discord-Immersion) instead which is using [CHTTP](https://github.com/timschumi/gmod-chttp).
CHTTP uses a different User-Agent, meaning that we can directly communicate with Discord from our GMod server.
In fact, the addon only uses simple [modify member](https://discord.com/developers/docs/resources/guild#modify-guild-member) PATCH requests and as such will not have to deal with Discord's new Intents system.

## Credits

- [TTT Discord Immersion](https://github.com/Owningle/TTT-Discord-Immersion) is where I got the CHTTP approach from
- [Discord Muter for GMod](https://github.com/manix84/discord_gmod_bot) is where I got the `mute.png` icon from
