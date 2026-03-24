-- =============================================
--  MENU GUI - MODIFICAR SP REAL (Delta Executor)
--  Lê da tela + altera valor interno do jogo
-- =============================================

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Remove menu antigo
if player.PlayerGui:FindFirstChild("SP_Menu_GUI_Delta") then
    player.PlayerGui.SP_Menu_GUI_Delta:Destroy()
end

-- ====================== ENCONTRA SP DA TELA (canto esquerdo) ======================
local gameSPLabel = nil
local function findLeftSP()
    local candidates = {}
    for _, obj in ipairs(player.PlayerGui:GetDescendants()) do
        if obj:IsA("TextLabel") and obj.Text:find("SP:") then
            table.insert(candidates, obj)
        end
    end
    if #candidates == 0 then return false end
    
    local best = candidates[1]
    local minX = best.AbsolutePosition.X
    for _, lbl in ipairs(candidates) do
        if lbl.AbsolutePosition.X < minX then
            minX = lbl.AbsolutePosition.X
            best = lbl
        end
    end
    gameSPLabel = best
    return true
end

-- ====================== ENCONTRA VALOR INTERNO REAL ======================
local skillValue = nil
local function findRealSPValue()
    for _, v in ipairs(player:GetDescendants()) do
        if (v:IsA("IntValue") or v:IsA("NumberValue")) then
            local name = v.Name:lower()
            if name:find("sp") or name:find("skill") or name:find("point") or 
               name:find("habilidade") or name:find("pontos") then
                skillValue = v
                print("✅ Valor REAL encontrado! Nome: " .. v.Name .. " | Valor atual: " .. v.Value)
                return true
            end
        end
    end
    return false
end

-- Espera achar os dois
local start = tick()
repeat
    findLeftSP()
    findRealSPValue()
    task.wait(0.4)
until (gameSPLabel and skillValue) or (tick() - start > 12)

if not gameSPLabel then
    game:GetService("StarterGui"):SetCore("SendNotification", {Title="❌ Erro", Text="Não encontrou SP na tela.", Duration=6})
    return
end

-- ====================== CRIA O MENU ======================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SP_Menu_GUI_Delta"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 380, 0, 300)
mainFrame.Position = UDim2.new(0.5, -190, 0.3, -150)
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

-- Barra azul
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

-- SP atual grande
local spDisplay = Instance.new("TextLabel")
spDisplay.Size = UDim2.new(1, -40, 0, 90)
spDisplay.Position = UDim2.new(0, 20, 0, 65)
spDisplay.BackgroundTransparency = 1
spDisplay.Text = gameSPLabel.Text
spDisplay.TextColor3 = Color3.fromRGB(0, 255, 100)
spDisplay.TextScaled = true
spDisplay.Font = Enum.Font.GothamBlack
spDisplay.Parent = mainFrame

-- === CAMPO DE MODIFICAÇÃO ===
local inputFrame = Instance.new("Frame")
inputFrame.Size = UDim2.new(1, -40, 0, 80)
inputFrame.Position = UDim2.new(0, 20, 0, 170)
inputFrame.BackgroundTransparency = 1
inputFrame.Parent = mainFrame

local inputLabel = Instance.new("TextLabel")
inputLabel.Size = UDim2.new(1, 0, 0, 25)
inputLabel.BackgroundTransparency = 1
inputLabel.Text = "Nova quantidade de SP:"
inputLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
inputLabel.TextScaled = true
inputLabel.Font = Enum.Font.GothamSemibold
inputLabel.Parent = inputFrame

local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(1, 0, 0, 35)
textBox.Position = UDim2.new(0, 0, 0, 30)
textBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
textBox.PlaceholderText = "Digite aqui (ex: 999999999)"
textBox.Text = ""
textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
textBox.TextScaled = true
textBox.Font = Enum.Font.Gotham
textBox.Parent = inputFrame

local applyBtn = Instance.new("TextButton")
applyBtn.Size = UDim2.new(1, 0, 0, 35)
applyBtn.Position = UDim2.new(0, 0, 0, 70)
applyBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
applyBtn.Text = "🚀 MODIFICAR SP (REAL)"
applyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
applyBtn.TextScaled = true
applyBtn.Font = Enum.Font.GothamBold
applyBtn.Parent = inputFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 10)
btnCorner.Parent = applyBtn

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

closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

-- ====================== ATUALIZAÇÃO EM TEMPO REAL ======================
local function updateDisplay()
    spDisplay.Text = gameSPLabel.Text
end

updateDisplay()
gameSPLabel:GetPropertyChangedSignal("Text"):Connect(updateDisplay)

-- ====================== BOTÃO MODIFICAR ======================
applyBtn.MouseButton1Click:Connect(function()
    local newAmount = tonumber(textBox.Text)
    if not newAmount or newAmount < 0 then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "❌ Erro",
            Text = "Digite um número válido!",
            Duration = 4
        })
        return
    end

    if skillValue then
        -- MODIFICAÇÃO REAL
        local oldValue = skillValue.Value
        skillValue.Value = newAmount
        print("SP REAL alterado: " .. oldValue .. " → " .. newAmount)
        
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "✅ SP REAL MODIFICADO!",
            Text = "Novo valor: " .. newAmount .. "\n(se voltar é anti-cheat)",
            Duration = 6
        })
    else
        -- fallback visual (caso raro)
        gameSPLabel.Text = "SP: " .. newAmount
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "⚠️ Apenas visual",
            Text = "Valor interno não encontrado.\nSP mudou só na tela.",
            Duration = 6
        })
    end
    
    updateDisplay()
end)

-- Notificação final
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "✅ MENU COM MODIFICAÇÃO!",
    Text = "Digite o SP desejado e clique em MODIFICAR SP\nReal quando possível • Arraste pela barra azul",
    Duration = 8
})

print("✅ Menu com modificação real carregado!")
