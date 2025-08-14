# onjobchange

This addon cobbles together code from the following addons to provide a luashitacast-like config for triggering arbitrary commands on changing jobs:

* Thorny's LuAshitacast (https://github.com/ThornyFFXI/LuAshitacast)
* Jyouya's JobChange (https://github.com/Jyouya/Ashita-Stuff/blob/master/addons/libs/events/jobChange.lua) 

Type the following to generate a new template file at ..\\config\\addons\\onjobchange\\

The OnJobChange function can then be populated with arbitrary chat commands to be executed on any job change. e.g.
```lua
profile.OnJobChange = function(mainJob, subJob)
    if (mainJob == 'NIN') then
        queue('/macro book 1')
        queue('/exec nin_alias_script')

        if (subJob == 'DRK') then
            queue('/macro set 1')
            queue('/bind F8 //stun')
        elseif (subJob == 'WAR') then
            queue('/macro set 2')
            queue('/bind F8 //provoke')
        else
            queue('/macro set 3')
            queue('/bind F8 /jump')
        end
    elseif (mainJob == 'PLD')
        queue('/macro book 2')
        queue('/macro set 1')
        queue('/bind F8 //holy')
        queue('/exec pld_alias_script')
    end
end
```
