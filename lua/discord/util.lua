DISCORD.util = {}

function DISCORD.util.log(context_text, ...)
    print("[DISCORD] " .. context_text .. " ", ...)
end

function DISCORD.util.err(...)
    print("[DISCORD] [ERROR] ", ...)
end

function DISCORD.util.toJSON(val)
    if type(val) == "table" then
        return util.TableToJSON(val)
    elseif type(val) == "string" then
        return val
    else
        return tostring(val)
    end
end

function DISCORD.util.tableEqual(tbl1, tbl2)
    for key, value in pairs(tbl1) do
        if value ~= tbl2[key] then return false end
    end
    for key, value in pairs(tbl2) do
        if value ~= tbl1[key] then return false end
    end
    return true
end

function DISCORD.util.enabled()
    return DISCORD.cv.enabled:GetBool() and GAMEMODE.Name ~= "Sandbox" and not DISCORD.util._paused
end

DISCORD.util._paused = false
function DISCORD.util.toggle_pause(new_paused_state)
    if new_paused_state == nil then
        new_paused_state = not DISCORD.util._paused
    end
    local msg
    if new_paused_state then
        DISCORD.util.patchAll({ mute = false, deaf = false })
        DISCORD.util._paused = true
        msg = "[DISCORD] Paused the Discord addon!"
    else
        DISCORD.util._paused = false
        DISCORD.util.patchAll()
        msg = "[DISCORD] Unpaused the Discord addon!"
    end
    if ULib then
        ULib.tsay(nil, msg)
    end
end

function DISCORD.util.is_active_round()
    return (GAMEMODE.round_state == ROUND_ACTIVE)
        or (GAMEMODE.round_state == ROUND_PREP and DISCORD.cv.ttt_preparing_active:GetBool())
        or (GAMEMODE.round_state == ROUND_POST and DISCORD.cv.ttt_postround_active:GetBool())
end

function DISCORD.util.summarizePatches(reasons)
    local summary = {
        mute = { value = false, priority = -math.huge },
        deaf = { value = false, priority = -math.huge }
    }
    for reason, patch in pairs(reasons) do
        local priority = DISCORD.priority:get(reason)
        for key, patch_value in pairs(patch) do
            -- prevent hard to spot bugs by casting to bool
            patch_value = not not patch_value
            if priority > summary[key].priority then
                summary[key] = { value = patch_value, priority = priority }
            elseif priority == summary[key].priority then
                summary[key].value = summary[key].value or patch_value
            end
        end
    end
    local patch = {}
    for key, value in pairs(summary) do
        patch[key] = value.value
    end
    return patch
end

function DISCORD.util.get_bool_or_nil(convar)
    local str = convar:GetString()
    if str == "1" then return true end
    if str == "0" then return false end
    return nil
end

function DISCORD.util.think()
    for _, ply in pairs(player.GetAll()) do
        ply:discordVoiceThink()
    end
end

function DISCORD.util.patchAll(patch)
    for _, ply in pairs(player.GetAll()) do
        ply:discordPatch(patch)
    end
end

function DISCORD.util.request(method, endpoint, body, success)
    if not DISCORD.cv.enabled:GetBool() then return end

    local token = DISCORD.cv.token:GetString()
    if token == "" then
        return DISCORD.util.err("You have to set the discord_token ConVar")
    end

    CHTTP({
        failed  = function(msg) err("Unable to communicate with the Discord API:\n" .. msg) end,
        success = success,
        method  = method,
        url     = "https://discord.com/api" .. endpoint,
        body    = body,
        headers = { Authorization = "Bot " .. token },
        type    = body and "application/json" or nil
    })
end
