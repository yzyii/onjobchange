--[[
Taken and edited from: https://github.com/Jyouya/Ashita-Stuff/blob/master/addons/libs/events/jobChange.lua
--]]
local event = require('event');

local onJobChange = event:new();

local lastMainJob, lastSubJob;

lastMainJob = AshitaCore:GetMemoryManager():GetPlayer():GetMainJob();
lastSubJob = AshitaCore:GetMemoryManager():GetPlayer():GetSubJob();
ashita.events.register('packet_in', 'subjob_packet_in', function(e)
    if (e.id == 0x061) then
        local mainJob = struct.unpack('B', e.data, 0x0C + 0x01);
        local subJob = struct.unpack('B', e.data, 0x0E + 0x01);

        if (mainJob == 0) then return; end

        if ((mainJob and mainJob ~= lastMainJob) or (subJob and subJob ~= lastSubJob)) then
            local main = AshitaCore:GetResourceManager():GetString("jobs.names_abbr", mainJob);
            local sub = AshitaCore:GetResourceManager():GetString("jobs.names_abbr", subJob);

            onJobChange:trigger(main, sub)
        end
    end
end);

return {
    onJobChange = onJobChange,
};
