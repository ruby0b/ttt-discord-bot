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

hook.Add("PlayerSpawn", "discord/PlayerSpawn", function(ply)
    if not DISCORD.util.enabled() then return end
    if not ULib then return end
    if ply:discordGetID() then return end
    -- user can't manage their own discord account, don't annoy them
    if not ULib.ucl.query(ply, "discord_manage") then return end

    ULib.tsay(ply, "[DISCORD] You are not connected to Discord! Please type !discord YOUR_18_DIGIT_DISCORD_ID")
end)

-- chat command: !discord DISCORD_ID [USER_NAME]
if ULib then
    ULib.ucl.registerAccess("discord_manage", "user",
        "Can use \"!discord <discord_id>\" to set their Discord account.")
    ULib.ucl.registerAccess("discord_manage_others", "superadmin",
        "Can use \"!discord <discord_id> <player>\" to set other players' Discord accounts.")
end
local discord_cmd = "!discord"
hook.Add("PlayerSay", "discord/PlayerSay", function(ply, msg)
    if string.sub(msg, 1, string.len(discord_cmd)) ~= discord_cmd then return end

    if not ULib then
        DISCORD.util.err("ULib is not installed")
        return ""
    end

    local discord_id_start = string.len(discord_cmd) + 2
    local discord_id_end = discord_id_start
    while discord_id_end <= string.len(msg) do
        if msg[discord_id_end + 1] == " " then break end
        discord_id_end = discord_id_end + 1
    end
    local discord_id = string.sub(msg, discord_id_start, discord_id_end)
    local player_name = string.sub(msg, discord_id_end + 2)

    if string.len(discord_id) < 17 then
        if ULib.ucl.query(ply, "discord_manage_others") then
            ULib.tsay(ply, "[DISCORD] Usage: " .. discord_cmd .. " DISCORD_ID PLAYER_NAME")
        else
            ULib.tsay(ply, "[DISCORD] Usage: " .. discord_cmd .. " YOUR_18_DIGIT_DISCORD_ID")
        end
        return ""
    end

    local discord_ply = nil
    if player_name ~= "" then
        -- add any player
        if not ULib.ucl.query(ply, "discord_manage_others") then
            DISCORD.util.err(ply ..
                " tried to set another player's Discord account but does not have the discord_manage_others permission.")
            ULib.tsay(ply, "[DISCORD] You do not have permission to set other players' Discord accounts.")
            return ""
        end
        -- find mentioned player
        for _, other_ply in pairs(player.GetAll()) do
            if IsValid(other_ply) and not other_ply:IsNPC() and other_ply:Nick() == player_name then
                discord_ply = other_ply
                break
            end
        end
        if not IsValid(discord_ply) then
            ULib.tsay(ply, "[DISCORD] Player not found: \"" .. player_name .. "\"")
            return ""
        end
    else
        if not ULib.ucl.query(ply, "discord_manage") then
            DISCORD.util.err(ply ..
                " tried to set their Discord account but does not have the discord_manage permission.")
            ULib.tsay(ply, "[DISCORD] You do not have permission to set your own Discord account.")
            return ""
        end
        -- add yourself
        discord_ply = ply
    end

    local steam_id = discord_ply:SteamID()
    DISCORD.player_map:set(steam_id, discord_id)
    ULib.tsay(nil, "[DISCORD] Successfully bound " .. steam_id .. " to Discord ID " .. discord_id)
    return ""
end)

if ULib then
    ULib.ucl.registerAccess("discord_pause", "superadmin", "Access to the discord_pause command", "Command")
end
net.Receive("discord_pause", function(len, ply)
    if not ULib then DISCORD.util.err("ULib is not installed") end
    if not ULib.ucl.query(ply, "discord_pause") then return end
    DISCORD.util.toggle_pause()
end)
