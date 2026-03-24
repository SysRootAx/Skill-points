-- =============================================
--  MENU GUI - SP DO CANTO ESQUERDO (corrigido)
--  Sempre pega o "SP: XXX" que fica na lateral esquerda
-- =============================================

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Remove menu antigo
if player.PlayerGui:FindFirstChild("SP_Menu_GUI_Delta") then
    player.PlayerGui.SP_Menu_GUI_Delta:Destroy()
end

-- ====================== ENCONTRA O SP DO CANTO ESQUERDO ======================
local gameSPLabel = nil

local function findLeftSP()
    local candidates = {}
    
    for _, obj in ipairs(player.PlayerGui:GetDescendants()) do
        if obj:IsA("TextLabel") and obj.Text:find("SP:") then
            table.insert(candidates, obj)
        end
    end
    
    if #candidates == 0 then return false end
    
    -- Pega o que está mais à ESQUERDA da tela (canto esquerdo)
    local best = candidates[1]
    local minX = best.AbsolutePosition.X
    
    for _, lbl in ipairs(candidates) do
        if lbl.AbsolutePosition.X < minX then
            minX = lbl.AbsolutePosition.X
            best = lbl
        end
    end
    
    gameSPLabel = best
    print("✅ SP do canto encontrado! Valor atual: " .. best.Text)
    return true
end

-- Espera até achar (máx 10 segundos)
local start = tick()
repeat
    findLeftSP()
    task.wait(0.3)
until gameSPLabel or (tick() - start > 10)

if not gameSPLabel then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "❌ SP não encontrado";
        Text = "Execute novamente após o jogo carregar completamente.";
        Duration = 8;
    })
    return
end

-- ====================== CRIA O MENU (visual igual ao da sua print) ======================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SP_Menu_GUI_Delta"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 380, 0, 220)
mainFrame.Position = UDim2.new(0.5, -190, 0.35, -110)
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

-- Barra azul superior (igual ao jogo)
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 50)
titleBar.BackgroundColor3 = Color3.fromRGB(0, 110, 255)
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 18)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -50, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "📊 Pontos de Habilidade (SP)"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = titleBar

-- Botão fechar
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 40, 0, 40)
closeBtn.Position = UDim2.new(1, -45, 0, 5)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 70, 70)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = titleBar

-- SP grande verde (igual ao da print)
local spDisplay = Instance.new("TextLabel")
spDisplay.Size = UDim2.new(1, -40, 0, 110)
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
        mainFrame.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + delta.X, frameStart.Y.Scale, frameStart.Y.Offset + delta.Y)
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

-- Notificação
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "✅ MENU CORRIGIDO!";
    Text = "Agora mostra o SP do canto esquerdo!\nAtualiza em tempo real • Arraste pela barra azul";
    Duration = 7;
})

print("✅ Menu SP do canto esquerdo carregado com sucesso!")
