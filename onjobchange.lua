--[[
* Addons - Copyright (c) 2021 Ashita Development Team
* Contact: https://www.ashitaxi.com/
* Contact: https://discord.gg/Ashita
*
* This file is part of Ashita.
*
* Ashita is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* Ashita is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with Ashita.  If not, see <https://www.gnu.org/licenses/>.
hp

--]]

addon.author   = 'Rag';
addon.name     = 'onjobchange';
addon.desc     = 'Executes generic scripts on job change';
addon.version  = '1.0.0';

require('common');
local chat = require('chat');

local gProfile = nil;

function queue(command)
    AshitaCore:GetChatManager():QueueCommand(-1, command)
end

local function getProfilePath()
    local playerId = AshitaCore:GetMemoryManager():GetParty():GetMemberServerId(0);
    local playerName = AshitaCore:GetMemoryManager():GetParty():GetMemberName(0);
    local fileName = playerName .. '_' .. playerId
    return ('%sconfig\\addons\\onjobchange\\%s.lua'):fmt(AshitaCore:GetInstallPath(), fileName);
end

local function safeCall(profile, name, ...)
    if (profile ~= nil) then
        if (type(profile[name]) == 'function') then
            local success,err = pcall(profile[name], ...);
            if (not success) then
                print(chat.header('onjobchange') .. chat.error('Error in profile function: ') .. chat.color1(2, name));
                print(chat.header('onjobchange') .. chat.error(err));
            end
        elseif (profile[name] ~= nil) then
            print(chat.header('onjobchange') .. chat.error('Profile member exists but is not a function: ') .. chat.color1(2, name));
        end
    end
end

local function loadProfile()
    local profilePath = getProfilePath();

    local success, loadError = loadfile(profilePath);
    if not success then
        print(chat.header('onjobchange') .. chat.error(loadError));
        return;
    end

    gProfile = success();
end

local function updateJob(mainJob, subJob)
    safeCall(gProfile, 'OnJobChangeRun', mainJob, subJob);
end

ashita.events.register('load', 'load_cb', function ()
    local mainJobOnLoad = AshitaCore:GetMemoryManager():GetPlayer():GetMainJob();
    local subJobOnLoad = AshitaCore:GetMemoryManager():GetPlayer():GetSubJob();
    local mainJobOnLoadString = AshitaCore:GetResourceManager():GetString("jobs.names_abbr", mainJobOnLoad)
    local subJobOnLoadString = AshitaCore:GetResourceManager():GetString("jobs.names_abbr", subJobOnLoad)

    loadProfile();
    updateJob(mainJobOnLoadString, subJobOnLoadString);

    local onJobChange = require('events.jobChange').onJobChange;
    onJobChange:register(updateJob);
end);

local createDirectories = function(path)
    local backSlash = string.byte('\\');
    for c = 1,#path,1 do
        if (path:byte(c) == backSlash) then
            local directory = string.sub(path,1,c);
            if (ashita.fs.create_directory(directory) == false) then
                print(chat.header('onjobchange') .. chat.error('Failed to create directory: ') .. chat.color1(2, directory));
                return false;
            end
        end
    end
    return true;
end

local function createProfile()
    local profilePath = getProfilePath();

    if ashita.fs.exists(profilePath) then
        print(chat.header('onjobchange') .. chat.error('Profile already exists: ') .. chat.color1(2, profilePath));
        return false;
    end

    if (createDirectories(profilePath) == false) then
        return;
    end

    local file = io.open(profilePath, 'w');
    if (file == nil) then
        print(chat.header('onjobchange') .. chat.error('Failed to access file: ') .. chat.color1(2, profilePath));
        return false;
    end
    file:write('local profile = {};\n\n');
    file:write('profile.OnJobChangeRun = function(mainJob, subJob)\nend\n\n');
    file:write('return profile;\n');
    file:close();
    return true;
end

ashita.events.register('command', 'command_cb', function (e)
    local args = e.command:args()

    if (#args == 2 and args[1] == '/ojc' and args[2] == 'new') then
        createProfile()

        e.blocked = true
        return
    end
end)
