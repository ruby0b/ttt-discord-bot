DISCORD.priority = {}
DISCORD.priority.default = 20

DISCORD.priority.data = {}
DISCORD.priority.data.alive = 10
DISCORD.priority.data.dead = 30
DISCORD.priority.data.inactive = 50
DISCORD.priority.data.disconnect = 100

function DISCORD.priority:get(reason)
    return self.data[reason] or self.default
end
