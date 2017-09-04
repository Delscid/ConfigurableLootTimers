class CLT_ScreenListener_UITacticalHUD
    extends UIScreenListener
    config (ConfigurableLootTimer);

const DEFAULT_LOOT_DROP_MAX_TURNS = 3;
const DEFAULT_LOOT_DROP_DISABLED_TURNS = 999;

var config bool LootExpirationEnabled;
var config int LootExpirationMaxTurns;

event OnInit(UIScreen Screen)
{
    if (UITacticalHUD(Screen) != none)
    {
        RegisterEventHandlers();
    }
}

function RegisterEventHandlers()
{
    local X2EventManager EventManager;
    local Object ThisObj;

    EventManager = `XEVENTMGR;
    ThisObj = self;

    EventManager.RegisterForEvent(ThisObj, 'LootDropCreated', OnLootDropCreated, ELD_OnStateSubmitted);
}

function EventListenerReturn OnLootDropCreated(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
    local X2EventManager EventManager;
    local XComGameState_LootDrop LootDrop;
    
    EventManager = `XEVENTMGR;
    LootDrop = XComGameState_LootDrop(EventData);
    
    if (LootExpirationEnabled)
    {
        LootDrop.LootExpirationTurnsRemaining = LootExpirationMaxTurns;
    }
    else
    {
        // Set the max turns to a high value to visually remove the turn counter.
        // We also want to unregister the 'PlayerTurnBegun' event on the loot drop, this event
        // is only used to decrement the expiration counter so this should remove loot expiration.
        LootDrop.LootExpirationTurnsRemaining = DEFAULT_LOOT_DROP_DISABLED_TURNS;
        EventManager.UnRegisterFromEvent(LootDrop, 'PlayerTurnBegun');
    }

    return ELR_NoInterrupt;
}

defaultProperties
{
    ScreenClass=none
}