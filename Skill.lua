-- =============================================
--  MENU GUI - Info SP (Delta Executor)
--  Aparece automaticamente ao executar
-- =============================================

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local TweenService = game:GetService("TweenService")

-- Configuração (já corrigida para o seu jogo)
local LEADERSTATS_NAME = "leaderstats"
local SP_VALUE_NAME     = "SP"

-- Remove menu antigo
if player.PlayerGui:FindFirstChild("SP_Menu_GUI_Delta") then
    player.PlayerGui.SP_Menu_GUI_Delta:Destroy()
end

-- Espera os dados
local leaderstats = player:WaitForChild(LEADERSTATS_NAME, 10)
local skillPoints = leaderstats and leaderstats:WaitForChild(SP_VALUE_NAME, 10)

if not skillPoints then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "❌ Erro";
        Text = "Não encontrei o SP!\nVerifique se o jogo carregou completamente.";
        Duration = 6;
    })
    return
end

-- ====================== CRIAÇÃO DO MENU ======================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SP_Menu_GUI_Delta"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainMenu"
mainFrame.Size = UDim2.new(0, 320, 0, 180)
mainFrame.Position = UDim2.new(0.5, -160, 0.4, -90)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(0, 170, 255)
stroke.Thickness = 2.5
stroke.Parent = mainFrame

-- Barra de título (arrastável)
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 16)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -40, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "📊 Info SP Menu"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = titleBar

-- Botão Fechar
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = titleBar

-- Área do conteúdo
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -20, 1, -60)
content.Position = UDim2.new(0, 10, 0, 50)
content.BackgroundTransparency = 1
content.Parent = mainFrame

local spLabel = Instance.new("TextLabel")
spLabel.Size = UDim2.new(1, 0, 1, 0)
spLabel.BackgroundTransparency = 1
spLabel.Text = "Skill Points: " .. skillPoints.Value
spLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
spLabel.TextScaled = true
spLabel
