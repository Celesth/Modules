G.DashCD = 0;-- Cooldown between different dashes.
_G.DashSpeed = 2000;-- The speed at which you dash.
_G.DashDistance = 100;-- The distance you get with each dash.
 if (_G.OldWait) then hookfunction(wait, _G.OldWait); end;-- In case the script is re-executed, it doesn't cause lag.
 local Players = game:GetService("Players");
local Player = Players.LocalPlayer;
 local DashCDConsts = {"Disconnect", "WalkSpeed", 0, "AutoRotate"};-- Identifies the CD stage.
local DashDtConsts = {"UserInputType", "Enum", "MouseButton1"};-- Identifies the DashDistance stage.
 local function ModifyDash()
    local HumanoidRootPart = Player.Character.HumanoidRootPart
    local Dash = HumanoidRootPart.Dash;
    local Distance = (Dash.Position - HumanoidRootPart.Position);
    local Direction = Distance.Unit;
    Dash.P = _G.DashSpeed;
    Dash.Position = HumanoidRootPart.Position + Direction * _G.DashDistance;
end;
 local OldWait;
OldWait = hookfunction(wait, function (Secs, ...)
    if (getcallingscript().Name ~= "ClientControl") then return OldWait(Secs, ...); end;
    local Consts = debug.getconstants(3);
    if (Consts[1] == DashCDConsts[1] and Consts[2] == DashCDConsts[2] and Consts[3] == DashCDConsts[3] and Consts[4] == DashCDConsts[4]) then-- Enough Identification
        Secs = _G.DashCD;
    elseif (Consts[1] == DashDtConsts[1] and Consts[2] == DashDtConsts[2] and Consts[3] == DashDtConsts[3] and Secs == 0.4) then
        pcall(ModifyDash);
    end;
    return OldWait(Secs, ...);
end);
_G.OldWait = OldWait;-- Backing up in case of re-execution
