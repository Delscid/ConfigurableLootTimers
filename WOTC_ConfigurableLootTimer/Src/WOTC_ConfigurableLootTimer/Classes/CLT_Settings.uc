class CLT_Settings
    extends UIScreenListener
    config (LootTimer);

var config bool LootExpirationEnabled;
var config int LootExpirationMaxTurns;
var config int ConfigVersion;

`include(WOTC_ConfigurableLootTimer/Src/ModConfigMenuAPI/MCM_API_Includes.uci)
`include(WOTC_ConfigurableLootTimer/Src/ModConfigMenuAPI/MCM_API_CfgHelpers.uci)
`MCM_CH_VersionChecker(class'CLT_Settings_Defaults'.default.ConfigVersion, ConfigVersion)

event OnInit(UIScreen Screen)
{
    if (UIShell(Screen) != none)
    {
        EnsureConfigurationExists();
    }

    if (MCM_API(Screen) != none)
    {
        `MCM_API_Register(Screen, ClientModCallback)
    }
}

simulated function ClientModCallback(MCM_API_Instance ConfigAPI, int GameMode)
{
    local MCM_API_SettingsPage Page;
    local MCM_API_SettingsGroup Group;
    local MCM_API_CheckBox ExpirationEnabledCheckBox;
    local MCM_API_Slider ExpirationTurnsSlider;

    LoadSavedSettings();

    Page = ConfigAPI.NewSettingsPage("Configurable Loot Timer");
    Page.SetPageTitle("Configurable Loot Timer");
    Page.SetSaveHandler(SaveButtonClicked);

    Group = Page.AddGroup('Group1', "");

    // Loot Expiration Enabled.
    ExpirationEnabledCheckBox = Group.AddCheckBox('LootExpirationEnabled',
                      "Loot Expiration Enabled",
                      "If disabled, loot drops will not expire and will remain until picked up or the mission ends.",
                      LootExpirationEnabled,
                      SaveLootExpirationEnabled);

    // Loot Expiration Turns Slider
    ExpirationTurnsSlider = Group.AddSlider('LootExpirationMaxTurns',
                    "Loot Expiration Turns",
                    "The number of turns which loot drops will last before expiring.",
                    1, 10, 1,
                    LootExpirationMaxTurns,
                    SaveLootExpirationMaxTurns);

    if (GameMode != eGameMode_MainMenu && GameMode != eGameMode_Strategy)
    {
        ExpirationEnabledCheckBox.SetEditable(false);
        ExpirationTurnsSlider.SetEditable(false);
    }
    else
    {
        // Don't know if MCM constructs this menu once, or every time.
        // Best to re-enable these just in case.
        ExpirationEnabledCheckBox.SetEditable(true);
        ExpirationTurnsSlider.SetEditable(true);
    }
    
    Page.ShowSettings();
}

`MCM_API_BasicCheckBoxSaveHandler(SaveLootExpirationEnabled, LootExpirationEnabled)
`MCM_API_BasicSliderSaveHandler(SaveLootExpirationMaxTurns, LootExpirationMaxTurns)

function LoadSavedSettings()
{
    LootExpirationEnabled = `MCM_CH_GetValue(class'CLT_Settings_Defaults'.default.LootExpirationEnabled, LootExpirationEnabled);
    LootExpirationMaxTurns = `MCM_CH_GetValue(class'CLT_Settings_Defaults'.default.LootExpirationMaxTurns, LootExpirationMaxTurns);
}

function SaveButtonClicked(MCM_API_SettingsPage Page)
{
    self.ConfigVersion = `MCM_CH_GetCompositeVersion();
    self.SaveConfig();
}

function EnsureConfigurationExists()
{
    if (ConfigVersion == 0)
    {
        LoadSavedSettings();
        SaveButtonClicked(none);
    }
}

defaultProperties
{
    ScreenClass=none;
}