DISCORD.player_map = {}
DISCORD.player_map.data = {}
DISCORD.player_map.filename = "discord_player_map.json"

function DISCORD.player_map:read()
    if file.Exists(self.filename, "DATA") then
        local json = file.Read(self.filename, "DATA")
        self.data = json and util.JSONToTable(json) or {}
    else
        file.Write(self.filename, "{}")
        self.data = {}
    end
end

function DISCORD.player_map:write()
    -- pretty print to JSON
    local json = util.TableToJSON(self.data, true)
    file.Write(self.filename, json)
end

function DISCORD.player_map:get(key)
    return self.data[key]
end

function DISCORD.player_map:set(key, value)
    self.data[key] = value
    self:write()
end

DISCORD.player_map:read()
