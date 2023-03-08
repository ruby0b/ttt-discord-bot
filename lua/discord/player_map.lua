DISCORD.player_map = {}
DISCORD.player_map.data = {}

function DISCORD.player_map:open(filename)
    self.filename = filename
    self.data_raw = file.Read(filename, 'DATA')
    self.data = self.data_raw and util.JSONToTable(self.data_raw) or {}
end

function DISCORD.player_map:get(key)
    return self.data[key]
end

DISCORD.player_map:open('discord_player_map.json')
