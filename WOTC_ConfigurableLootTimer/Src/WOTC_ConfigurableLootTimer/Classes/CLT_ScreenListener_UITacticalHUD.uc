class CLT_ScreenListener_UITacticalHUD
    extends UIScreenListener
    dependson (XComGameState_LootDrop);

const DEFAULT_LOOT_DROP_DISABLED_TURNS = 999;

var CLT_Settings Settings;

event OnInit(UIScreen Screen)
{
    if (UITacticalHUD(Screen) != none)
    {
        Settings = new class'CLT_Settings';
        RegisterEventHandlers();
    }
}

function RegisterEventHandlers()
{
    local Object ThisObj;
    ThisObj = self;

    `XEVENTMGR.RegisterForEvent(ThisObj, 'LootDropCreated', OnLootDropCreated, ELD_OnStateSubmitted);
}

function EventListenerReturn OnLootDropCreated(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
    local XComGameState_LootDrop LootDrop;
    
    LootDrop = XComGameState_LootDrop(EventData);
    
    if (Settings.LootExpirationEnabled)
    {
        LootDrop.LootExpirationTurnsRemaining = Settings.LootExpirationMaxTurns;
    }
    else
    {
        // Set the max turns to a high value to visually remove the turn counter.
        // We also want to unregister the 'PlayerTurnBegun' event on the loot drop, this event
        // is only used to decrement the expiration counter so this should remove loot expiration.
        LootDrop.LootExpirationTurnsRemaining = DEFAULT_LOOT_DROP_DISABLED_TURNS;
        `XEVENTMGR.UnRegisterFromEvent(LootDrop, 'PlayerTurnBegun');
    }

    return ELR_NoInterrupt;
}

defaultProperties
{
    ScreenClass=UITacticalHUD
}