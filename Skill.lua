-- =============================================
--  MENU GUI - Info SP (Delta Executor)
--  BUSCA AUTOMÁTICA de "pontos de habilidade"
-- =============================================

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local TweenService = game:GetService("TweenService")

-- Remove menu antigo
if player.PlayerGui:FindFirstChild("SP_Menu_GUI_Delta") then
    player.PlayerGui.SP_Menu_GUI_Delta:Destroy()
end

-- ====================== BUSCA AUTOMÁTICA DO SP ======================
local skillPoints = nil

local function findSP()
    for _, v in ipairs(player:GetDescendants()) do
        if (v:IsA("IntValue") or v:IsA("NumberValue")) then
            local name = v.Name:lower()
            if name:find("sp") or name:find("skill") or name:find("point") or 
               name:find("habilidade") or name:find("pontos") then
                skillPoints = v
                print("✅ SP encontrado! Nome real: " .. v.Name)
                return true
            end
        end
    end
    return false
end

-- Espera até encontrar (máx 12 segundos)
local startTime = tick()
repeat
    findSP()
    task.wait(0.5)
until skillPoints or (tick() - startTime > 12)

if not skillPoints then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "❌ SP NÃO ENCONTRADO";
        Text = "Não achei o valor de Skill Points.\nMe manda o print do console do Delta que eu arrumo em 5s!";
        Duration = 8;
    })
    return
end

-- ====================== CRIAÇÃO DO MENU ======================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SP_Menu_GUI_Delta"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 340, 0, 190)
mainFrame.Position = UDim2.new(0.5, -170, 0.35, -95)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 18)
corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(0, 180, 255)
stroke.Thickness = 3
stroke.Parent = mainFrame

-- Barra de título (arrastável)
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.BackgroundColor3 = Color3.fromRGB(0, 110, 255)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 18)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -45, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "📊 Pontos de Habilidade (SP)"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = titleBar

-- Botão Fechar
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -40, 0, 5)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 70, 70)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = titleBar

-- Contador SP
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -30, 1, -70)
content.Position = UDim2.new(0, 15, 0, 55)
content.BackgroundTransparency = 1
content.Parent = mainFrame

local spLabel = Instance.new("TextLabel")
spLabel.Size = UDim2.new(1, 0, 1, 0)
spLabel.BackgroundTransparency = 1
spLabel.Text = "SP: " .. skillPoints.Value
spLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
spLabel.TextScaled = true
spLabel.Font = Enum.Font.GothamBlack
spLabel.Parent = content

-- ====================== ARRASTAR MENU ======================
local dragging, dragInput, mousePos, framePos
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        mousePos = input.Position
        framePos = mainFrame.Position
    end
end)

titleBar.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - mousePos
        mainFrame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
    end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- ====================== FECHAR ======================
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- ====================== ATUALIZAÇÃO EM TEMPO REAL ======================
local function updateSP()
    spLabel.Text = "SP: " .. tostring(skillPoints.Value)
end

updateSP()
skillPoints.Changed:Connect(updateSP)
skillPoints:GetPropertyChangedSignal("Value"):Connect(updateSP)

-- Notificação final
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "✅ MENU SP CARREGADO!";
    Text = "Encontrado automaticamente!\nArraste pela barra azul • ✕ para fechar";
    Duration = 7;
})

print("✅ MENU Pontos de Habilidade carregado! Nome interno: " .. skillPoints.Name)
