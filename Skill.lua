-- =============================================
--  MENU GUI - SP LÊ DIRETO DA TELA DO JOGO
--  Atualiza exatamente como aparece no canto esquerdo
-- =============================================

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Remove menu antigo
if player.PlayerGui:FindFirstChild("SP_Menu_GUI_Delta") then
    player.PlayerGui.SP_Menu_GUI_Delta:Destroy()
end

-- ====================== ENCONTRA O SP DA TELA ======================
local gameSPLabel = nil

local function findGameSP()
    for _, obj in ipairs(player.PlayerGui:GetDescendants()) do
        if obj:IsA("TextLabel") and obj.Text:find("SP:") then
            gameSPLabel = obj
            print("✅ SP da tela encontrado! Caminho: " .. obj:GetFullName())
            return true
        end
    end
    return false
end

-- Espera até achar (máx 10 segundos)
local start = tick()
repeat
    findGameSP()
    task.wait(0.3)
until gameSPLabel or (tick() - start > 10)

if not gameSPLabel then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "❌ Não encontrou SP na tela";
        Text = "Jogue um pouco e execute novamente.\nOu me manda print do console do Delta.";
        Duration = 8;
    })
    return
end

-- ====================== CRIA O MENU ======================
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

-- Barra azul arrastável
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.BackgroundColor3 = Color3.fromRGB(0, 110, 255)
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

-- Botão fechar
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -40, 0, 5)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 70, 70)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = titleBar

-- Contador grande
local spDisplay = Instance.new("TextLabel")
spDisplay.Size = UDim2.new(1, -40, 0, 90)
spDisplay.Position = UDim2.new(0, 20, 0, 70)
spDisplay.BackgroundTransparency = 1
spDisplay.Text = gameSPLabel.Text
spDisplay.TextColor3 = Color3.fromRGB(0, 255, 100)
spDisplay.TextScaled = true
spDisplay.Font = Enum.Font.GothamBlack
spDisplay.Parent = mainFrame

-- ====================== ARRASTAR + FECHAR ======================
local dragging = false
local dragStart, frameStart

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        frameStart = mainFrame.Position
    end
end)

titleBar.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            frameStart.X.Scale, frameStart.X.Offset + delta.X,
            frameStart.Y.Scale, frameStart.Y.Offset + delta.Y
        )
    end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- ====================== ATUALIZAÇÃO EM TEMPO REAL ======================
local function updateDisplay()
    spDisplay.Text = gameSPLabel.Text
end

updateDisplay()
gameSPLabel:GetPropertyChangedSignal("Text"):Connect(updateDisplay)
gameSPLabel.Changed:Connect(updateDisplay)

-- Sucesso
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "✅ MENU PRONTO!";
    Text = "Lendo direto da tela do jogo!\nAtualiza em tempo real • Arraste pela barra azul";
    Duration = 7;
})

print("✅ Menu SP carregado! Agora mostra exatamente o que aparece na tela.")
