-- =============================================
--  SP Info GUI - Para Delta Executor
--  Cole e execute direto no Delta!
-- =============================================

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- =============================================
--  CONFIGURAÇÃO (mude aqui se precisar)
-- =============================================
local LEADERSTATS_NAME = "leaderstats"
local SP_VALUE_NAME     = "SkillPoints"   -- ←←← TROQUE AQUI se no seu jogo for "SP", "Points", "SkillPoint" etc.

-- =============================================
--  REMOVE GUI ANTIGA (evita duplicação)
-- =============================================
local oldGui = player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("SP_Info_GUI_Delta")
if oldGui then
    oldGui:Destroy()
end

-- =============================================
--  ESPERA OS DADOS CARREGAREM
-- =============================================
local leaderstats = player:WaitForChild(LEADERSTATS_NAME, 10)
local skillPoints = leaderstats and leaderstats:WaitForChild(SP_VALUE_NAME, 10)

if not skillPoints then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "SP Info";
        Text = "Não encontrei o SkillPoints!\nVerifique o nome na configuração.";
        Duration = 5;
    })
    return
end

-- =============================================
--  CRIA O GUI
-- =============================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SP_Info_GUI_Delta"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 80)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
frame.BackgroundTransparency = 0.25
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(0, 200, 255)
stroke.Thickness = 3
stroke.Transparency = 0.3
stroke.Parent = frame

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, 0, 1, 0)
label.BackgroundTransparency = 1
label.Text = "SP: " .. skillPoints.Value
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextScaled = true
label.Font = Enum.Font.GothamBold
label.Parent = frame

-- =============================================
--  ATUALIZAÇÃO EM TEMPO REAL
-- =============================================
local function update()
    label.Text = "SP: " .. tostring(skillPoints.Value)
end

update()
skillPoints.Changed:Connect(update)
skillPoints:GetPropertyChangedSignal("Value"):Connect(update)

-- Notificação de sucesso
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "✅ SP Info GUI";
    Text = "Carregado com sucesso!\nAtualizando em tempo real.";
    Duration = 4;
})

print("SP Info GUI (Delta) carregado!")
