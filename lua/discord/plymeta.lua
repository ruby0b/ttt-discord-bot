local plymeta = FindMetaTable("Player")

function plymeta:discordGetID()
    -- see Note [SteamID]
    if self.SteamID and self:SteamID() then
        self.cached_steam_id = self:SteamID()
    end
    if self.cached_steam_id then
        return DISCORD.player_map:get(self.cached_steam_id)
    end
    DISCORD.util.err("cached SteamID is nil for ", self)
end

function plymeta:discordVoice(reason, patch)
    self:discordPatchLazy(function()
        self:discordVoiceLazy(reason, patch)
    end)
end

function plymeta:discordVoiceLazy(reason, patch)
    self.discord = self.discord or {}
    self.discord[reason] = patch
end

function plymeta:discordGetPatch()
    self.discord = self.discord or {}
    return DISCORD.util.summarizePatches(self.discord)
end

function plymeta:discordPatchLazy(inner_function)
    local old_patch = self:discordGetPatch()
    inner_function()
    local new_patch = self:discordGetPatch()
    if not DISCORD.util.tableEqual(new_patch, old_patch) then
        self:discordPatch()
    end
end

function plymeta:discordPatch(patch)
    if not DISCORD.util.enabled() then return end

    local discordID = self:discordGetID()
    if not discordID then return DISCORD.util.err("No connected Discord account: ", self) end

    local guild = DISCORD.cv.guildID:GetString()
    if guild == "" then return DISCORD.util.err("You have to set the discord_guild ConVar") end

    patch = patch or self:discordGetPatch()
    DISCORD.util.log("[PATCH]", self, DISCORD.util.toJSON(patch))

    DISCORD.util.request("PATCH", "/guilds/" .. guild .. "/members/" .. discordID,
        DISCORD.util.toJSON(patch),
        function(code, body, headers)
            if code == 204 then
                net.Start("discord_drawMute")
                net.WriteBool(DISCORD.cv.mute_icon_enabled:GetBool() and patch.mute)
                net.Send(self)
                return
            end

            local res = util.JSONToTable(body)
            local ply_str = IsValid(self) and self:Nick() or tostring(self)
            DISCORD.util.err("Failed to patch user " .. ply_str .. " [" .. discordID .. "]"
            .. ": Code(" .. code .. "/" .. res.code .. ") " .. res.message)
        end)
end

function plymeta:discordVoiceThink()
    self:discordGetID() -- see Note [SteamID]

    self:discordPatchLazy(function()
        if DISCORD.util.is_active_round() then
            self:discordVoiceLazy("inactive")
            local death_timer = "discord_dead_" .. self.cached_steam_id -- see Note [SteamID]
            if self:Alive() then
                self:discordVoiceLazy("dead")
                self:discordVoiceLazy("alive", {
                    mute = DISCORD.util.get_bool_or_nil(DISCORD.cv.alive_mute),
                    deaf = DISCORD.util.get_bool_or_nil(DISCORD.cv.alive_deaf)
                })
                timer.Remove(death_timer)
            elseif not self.discord.dead then
                self:discordVoiceLazy("alive")
                self:discordVoiceLazy("dead", {
                    mute = DISCORD.util.get_bool_or_nil(DISCORD.cv.dead_mute),
                    deaf = DISCORD.util.get_bool_or_nil(DISCORD.cv.dead_deaf)
                })
                local duration = DISCORD.cv.dead_duration:GetFloat()
                if duration > 0 then
                    timer.Create(death_timer, duration, 1, function()
                        self:discordVoice("dead", {})
                    end)
                end
            end
        else
            self:discordVoiceLazy("inactive", {
                mute = DISCORD.util.get_bool_or_nil(DISCORD.cv.ttt_inactive_mute),
                deaf = DISCORD.util.get_bool_or_nil(DISCORD.cv.ttt_inactive_deaf)
            })
        end
    end)
end
