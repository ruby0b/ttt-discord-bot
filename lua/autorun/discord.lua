AddCSLuaFile()
local muteIcon = "materials/icon128/mute.png"
resource.AddFile(muteIcon)

concommand.Add("discord_pause", function(ply, cmd, args, argStr)
    if CLIENT then
        net.Start("discord_pause")
        net.SendToServer()
    else
        DISCORD.util.toggle_pause()
    end
end, nil, "Pause/Unpause the Discord addon. Pausing will temporarily unmute and undeafen everyone.")

if CLIENT then
    local discord_drawMute = false
    local muteIconAsset = Material(muteIcon, "smooth mips")
    net.Receive("discord_drawMute", function() discord_drawMute = net.ReadBool() end)
    hook.Add("HUDPaint", "discord_HUDPaint", function()
        if not discord_drawMute then return end
        surface.SetDrawColor(176, 40, 40, 255)
        surface.SetMaterial(muteIconAsset)
        surface.DrawTexturedRect(32, 32, 256, 256)
    end)
    return
end

util.AddNetworkString("discord_drawMute")
util.AddNetworkString("discord_pause")
DISCORD = {}
include("discord/cv.lua")
include("discord/player_map.lua")
include("discord/plymeta.lua")
include("discord/priority.lua")
include("discord/util.lua")

if pcall(require, "chttp") then
    DISCORD.util.log("Using CHTTP (https://github.com/timschumi/gmod-chttp)")
    HTTP = CHTTP
else
    -- Discord blocks the built-in HTTP User-Agent: https://github.com/Owningle/TTT-Discord-Immersion/issues/1
    err("CHTTP is not installed!! The addon will not work without it."
    .. " Please install it and then re-enable this addon: https://github.com/timschumi/gmod-chttp")
    DISCORD.cv.enabled:SetBool(false)
end

hook.Add("Think", "discord/Think", DISCORD.util.think)

hook.Add("ShutDown", "discord/ShutDown", function() DISCORD.util.toggle_pause(true) end)

hook.Add("PlayerDisconnected", "discord/PlayerDisconnected", function(ply)
    -- Always make sure to unmute and undeafen players that disconnect.
    -- Note [SteamID]: SteamID may return nil here so we already cached it elsewhere
    ply:discordVoiceLazy("disconnect", { mute = false, deaf = false })
    ply:discordPatch()
end)

if ULib then
    ULib.ucl.registerAccess("discord_pause", "superadmin", "Access to the discord_pause command", "Command")
end
net.Receive("discord_pause", function(len, ply)
    if not ULib then DISCORD.util.err("ULib is not installed") end
    if not ULib.ucl.query(ply, "discord_pause") then return end
    DISCORD.util.toggle_pause()
end)
