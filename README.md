# onjobchange

This addon cobbles together code from the following addons to provide a LuAshitacast-like config for triggering arbitrary chat commands on changing jobs (including when subjob changes):

* Thorny's LuAshitacast (https://github.com/ThornyFFXI/LuAshitacast)
* Jyouya's JobChange (https://github.com/Jyouya/Ashita-Stuff/blob/master/addons/libs/events/jobChange.lua) 

Use cases for this are typically to automatically set macro books / sets due to different mainjob/subjob combinations and run binds, aliases or /exec scripts for that specific job automatically on switching.

This is primarily also used in conjunction with LuAshitacast to separate responsibility of running job setup scripts or commands from LuAshitacast's OnLoad function.

Type the following to generate a new template file at ..\\config\\addons\\onjobchange\\
```
/ojc new
```

The OnJobChangeRun function can then be populated with arbitrary chat commands to be executed on any job change. e.g.
```lua
profile.OnJobChangeRun = function(mainJob, subJob)
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
    elseif (mainJob == 'PLD') then
        queue('/macro book 2')
        queue('/macro set 1')
        queue('/bind F8 //holy')
        queue('/exec pld_alias_script')
    end
end
```
