-- =============================================
--  MENU GUI - MODIFICAR / ADICIONAR SP REAL
--  Busca ampla: leaderstats, Estatisticas, e mais
--  Design Moderno | Delta Executor
-- =============================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer

-- Remove menu antigo
if player.PlayerGui:FindFirstChild("SP_Menu_GUI") then
    player.PlayerGui.SP_Menu_GUI:Destroy()
end

-- ====================== HELPERS ======================
local function notify(title, text, duration)
    StarterGui:SetCore("SendNotification", {Title=title, Text=text, Duration=duration or 5})
end

local function addCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 12)
    c.Parent = parent
    return c
end

local function makeButton(parent, text, bgColor, size, pos)
    local btn = Instance.new("TextButton")
    btn.Size = size
    btn.Position = pos
    btn.BackgroundColor3 = bgColor
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.Parent = parent
    addCorner(btn, 10)
    local savedColor = bgColor
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = savedColor:Lerp(Color3.fromRGB(255, 255, 255), 0.15)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = savedColor
    end)
    return btn
end

-- ====================== ENCONTRA SP DA TELA ====================== 
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

-- ====================== BUSCA AMPLA DO VALOR INTERNO ====================== 
-- Imprime TUDO que encontrar para facilitar debug
local skillValue = nil

local function debugPrintAllValues()
    print("=== [SP Manager] ESCANEANDO TODOS OS VALORES DO PLAYER ===")
    for _, v in ipairs(player:GetDescendants()) do
        if v:IsA("IntValue") or v:IsA("NumberValue") or v:IsA("StringValue") then
            print("  [" .. v.ClassName .. "] " .. v:GetFullName() .. " = " .. tostring(v.Value))
        end
    end
    print("=== FIM DO ESCANEAMENTO ===")
end

local function findRealSPValue()
    -- 1) Procura em leaderstats
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        for _, v in ipairs(leaderstats:GetChildren()) do
            if v:IsA("IntValue") or v:IsA("NumberValue") then
                local name = v.Name:lower()
                if name:find("sp") or name:find("skill") or name:find("point") or
                   name:find("habilidade") or name:find("pontos") or name:find("estat") then
                    skillValue = v
                    print("[SP Manager] Encontrado em leaderstats: " .. v.Name .. " = " .. v.Value)
                    return true
                end
            end
        end
    end

    -- 2) Procura em pasta chamada "Estatisticas", "Stats", "Attributes" ou similar
    local statsFolderNames = {"Estatisticas", "Estatísticas", "Stats", "Attributes", "Data", "PlayerData", "PlayerStats"}
    for _, folderName in ipairs(statsFolderNames) do
        local folder = player:FindFirstChild(folderName)
        if folder then
            for _, v in ipairs(folder:GetDescendants()) do
                if v:IsA("IntValue") or v:IsA("NumberValue") then
                    local name = v.Name:lower()
                    if name:find("sp") or name:find("skill") or name:find("point") or
                       name:find("habilidade") or name:find("pontos") then
                        skillValue = v
                        print("[SP Manager] Encontrado em '" .. folderName .. "': " .. v.Name .. " = " .. v.Value)
                        return true
                    end
                end
            end
            -- Se a pasta existe mas nao achou pelo nome, pega o primeiro IntValue/NumberValue dela
            for _, v in ipairs(folder:GetChildren()) do
                if v:IsA("IntValue") or v:IsA("NumberValue") then
                    skillValue = v
                    print("[SP Manager] Usando primeiro valor de '" .. folderName .. ": " .. v.Name .. " = " .. v.Value)
                    return true
                end
            end
        end
    end

    -- 3) Busca geral em todos os descendentes do player
    for _, v in ipairs(player:GetDescendants()) do
        if v:IsA("IntValue") or v:IsA("NumberValue") then
            local name = v.Name:lower()
            if name:find("sp") or name:find("skill") or name:find("point") or
               name:find("habilidade") or name:find("pontos") then
                skillValue = v
                print("[SP Manager] Encontrado (busca geral): " .. v:GetFullName() .. " = " .. v.Value)
                return true
            end
        end
    end

    return false
end

-- Espera encontrar os valores (maximo 15 segundos)
local startTime = tick()
do
    findLeftSP()
    if not skillValue then findRealSPValue() end
    task.wait(0.4)
end until (gameSPLabel and skillValue) or (tick() - startTime > 15)

-- Imprime todos os valores para debug (ver no console do executor)
debugPrintAllValues()

if not gameSPLabel then
    notify("Erro", "Nao encontrou SP na tela.", 6)
    return
end

if not skillValue then
    print("[SP Manager] AVISO: Nenhum valor interno encontrado. Funcionando em modo visual.")
    notify("Aviso", "SP so pode ser alterado visualmente.\nVeja o console para detalhes.\n", 7)
end

-- ====================== SCREENGUI ====================== 
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SP_Menu_GUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

-- ====================== FRAME PRINCIPAL ====================== 
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 420, 0, 390)
mainFrame.Position = UDim2.new(0.5, -210, 0.5, -195)
mainFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui
addCorner(mainFrame, 18)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(80, 140, 255)
stroke.Thickness = 2.5
stroke.Parent = mainFrame

local grad = Instance.new("UIGradient")
grad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 22, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 18))
})
grad.Rotation = 135
grad.Parent = mainFrame

-- ====================== BARRA DE TITULO ====================== 
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 52)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 80, 200)
titleBar.BorderSizePixel = 0
titleBar.ZIndex = 2

local titleGrad = Instance.new("UIGradient")
titleGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 100, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 60, 180))
})
titleGrad.Rotation = 90
titleGrad.Parent = titleBar

local titleIcon = Instance.new("TextLabel")
titleIcon.Size = UDim2.new(0, 40, 1, 0)
titleIcon.Position = UDim2.new(0, 12, 0, 0)
titleIcon.BackgroundTransparency = 1
titleIcon.Text = "SP"
titleIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
titleIcon.TextScaled = true
titleIcon.Font = Enum.Font.GothamBlack
titleIcon.ZIndex = 3
titleIcon.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -100, 1, 0)
titleLabel.Position = UDim2.new(0, 54, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Skill Points Manager"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.ZIndex = 3
titleLabel.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 36, 0, 36)
closeBtn.Position = UDim2.new(1, -44, 0.5, -18)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.ZIndex = 4
closeBtn.Parent = titleBar
addCorner(closeBtn, 8)

-- ====================== INFO: VALOR ENCONTRADO ====================== 
local infoBar = Instance.new("Frame")
infoBar.Size = UDim2.new(1, -32, 0, 28)
infoBar.Position = UDim2.new(0, 16, 0, 58)
infoBar.BackgroundColor3 = Color3.fromRGB(18, 30, 60)
infoBar.BorderSizePixel = 0
infoBar.Parent = mainFrame
addCorner(infoBar, 8)

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, -10, 1, 0)
infoLabel.Position = UDim2.new(0, 8, 0, 0)
infoLabel.BackgroundTransparency = 1
infoLabel.TextScaled = true
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.Parent = infoBar
if skillValue then
    infoLabel.Text = "Valor: " .. skillValue:GetFullName()
    infoLabel.TextColor3 = Color3.fromRGB(80, 220, 120)
else
    infoLabel.Text = "Valor interno nao encontrado — modo visual"
    infoLabel.TextColor3 = Color3.fromRGB(255, 160, 40)
end

-- ====================== DISPLAY SP ATUAL ====================== 
local spBg = Instance.new("Frame")
spBg.Size = UDim2.new(1, -32, 0, 66)
spBg.Position = UDim2.new(0, 16, 0, 94)
spBg.BackgroundColor3 = Color3.fromRGB(20, 26, 50)
spBg.BorderSizePixel = 0
spBg.Parent = mainFrame
addCorner(spBg, 14)

local spStroke = Instance.new("UIStroke")
spStroke.Color = Color3.fromRGB(60, 120, 255)
spStroke.Thickness = 1.5
spStroke.Parent = spBg

local spSubLabel = Instance.new("TextLabel")
spSubLabel.Size = UDim2.new(1, 0, 0, 20)
spSubLabel.Position = UDim2.new(0, 0, 0, 6)
spSubLabel.BackgroundTransparency = 1
spSubLabel.Text = "SP ATUAL"
spSubLabel.TextColor3 = Color3.fromRGB(100, 160, 255)
spSubLabel.TextScaled = true
spSubLabel.Font = Enum.Font.GothamSemibold
spSubLabel.Parent = spBg

local spDisplay = Instance.new("TextLabel")
spDisplay.Size = UDim2.new(1, -20, 0, 34)
spDisplay.Position = UDim2.new(0, 10, 0, 26)
spDisplay.BackgroundTransparency = 1
spDisplay.Text = gameSPLabel.Text
spDisplay.TextColor3 = Color3.fromRGB(80, 255, 160)
spDisplay.TextScaled = true
spDisplay.Font = Enum.Font.GothamBlack
spDisplay.Parent = spBg

-- ====================== SEPARADOR ====================== 
local sep = Instance.new("Frame")
sep.Size = UDim2.new(1, -32, 0, 1)
sep.Position = UDim2.new(0, 16, 0, 170)
sep.BackgroundColor3 = Color3.fromRGB(50, 70, 140)
sep.BorderSizePixel = 0
sep.Parent = mainFrame

-- ====================== LABEL QUANTIDADE ====================== 
local qtyLabel = Instance.new("TextLabel")
qtyLabel.Size = UDim2.new(1, -32, 0, 20)
qtyLabel.Position = UDim2.new(0, 16, 0, 180)
qtyLabel.BackgroundTransparency = 1
qtyLabel.Text = "QUANTIDADE DE SP"
qtyLabel.TextColor3 = Color3.fromRGB(160, 180, 255)
qtyLabel.TextScaled = true
qtyLabel.Font = Enum.Font.GothamSemibold
qtyLabel.TextXAlignment = Enum.TextXAlignment.Left
qtyLabel.Parent = mainFrame

-- ====================== CAIXA DE TEXTO ====================== 
local inputBg = Instance.new("Frame")
inputBg.Size = UDim2.new(1, -32, 0, 44)
inputBg.Position = UDim2.new(0, 16, 0, 204)
inputBg.BackgroundColor3 = Color3.fromRGB(22, 28, 52)
inputBg.BorderSizePixel = 0
inputBg.Parent = mainFrame
addCorner(inputBg, 10)

local inputStroke = Instance.new("UIStroke")
inputStroke.Color = Color3.fromRGB(60, 100, 200)
inputStroke.Thickness = 1.5
inputStroke.Parent = inputBg

local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(1, -20, 1, 0)
textBox.Position = UDim2.new(0, 10, 0, 0)
textBox.BackgroundTransparency = 1
textBox.PlaceholderText = "Digite o valor (ex: 9999)"
textBox.PlaceholderColor3 = Color3.fromRGB(100, 110, 150)
textBox.Text = ""
textBox.TextColor3 = Color3.fromRGB(220, 230, 255)
textBox.TextScaled = true
textBox.Font = Enum.Font.Gotham
textBox.ClearTextOnFocus = false
textBox.Parent = inputBg

textBox.Focused:Connect(function()
    inputStroke.Color = Color3.fromRGB(100, 160, 255)
    inputStroke.Thickness = 2
end)
textBox.FocusLost:Connect(function()
    inputStroke.Color = Color3.fromRGB(60, 100, 200)
    inputStroke.Thickness = 1.5
end)

-- ====================== BOTOES ====================== 
local btnRow = Instance.new("Frame")
btnRow.Size = UDim2.new(1, -32, 0, 44)
btnRow.Position = UDim2.new(0, 16, 0, 260)
btnRow.BackgroundTransparency = 1
btnRow.Parent = mainFrame

local setBtn = makeButton(
    btnRow, "DEFINIR SP",
    Color3.fromRGB(30, 140, 60),
    UDim2.new(0.48, 0, 1, 0),
    UDim2.new(0, 0, 0, 0)
)

local addBtn = makeButton(
    btnRow, "ADICIONAR SP",
    Color3.fromRGB(30, 100, 220),
    UDim2.new(0.48, 0, 1, 0),
    UDim2.new(0.52, 0, 0, 0)
)

local subBtn = makeButton(
    mainFrame, "SUBTRAIR SP",
    Color3.fromRGB(180, 60, 30),
    UDim2.new(1, -32, 0, 38),
    UDim2.new(0, 16, 0, 316)
)

-- ====================== STATUS BAR ====================== 
local statusBar = Instance.new("Frame")
statusBar.Size = UDim2.new(1, 0, 0, 26)
statusBar.Position = UDim2.new(0, 0, 1, -26)
statusBar.BackgroundColor3 = Color3.fromRGB(18, 24, 44)
statusBar.BorderSizePixel = 0
statusBar.Parent = mainFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -10, 1, 0)
statusLabel.Position = UDim2.new(0, 8, 0, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Pronto."
statusLabel.TextColor3 = Color3.fromRGB(180, 200, 255)
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = statusBar

-- ====================== ATUALIZACAO EM TEMPO REAL ====================== 
local function updateDisplay()
    spDisplay.Text = gameSPLabel.Text
    if skillValue then
        -- Atualiza infoLabel com valor atual do objeto
        infoLabel.Text = skillValue:GetFullName() .. " = " .. tostring(skillValue.Value)
        infoLabel.TextColor3 = Color3.fromRGB(80, 220, 120)
    end
end
updateDisplay()
gameSPLabel:GetPropertyChangedSignal("Text"):Connect(updateDisplay)

-- ====================== FUNCAO CENTRAL ====================== 
local function applySP(newVal)
    if skillValue then
        -- Tenta modificar o valor interno
        local ok, err = pcall(function()
            skillValue.Value = newVal
        end)
        if not ok then
            print("[SP Manager] Erro ao modificar valor interno: " .. tostring(err))
            -- Fallback visual
            gameSPLabel.Text = "SP: " .. newVal
            statusLabel.Text = "Erro interno — alterado visualmente"
            statusLabel.TextColor3 = Color3.fromRGB(255, 160, 40)
        else
            statusLabel.Text = "Valor alterado: " .. tostring(newVal)
            statusLabel.TextColor3 = Color3.fromRGB(80, 220, 120)
        end
    else
        gameSPLabel.Text = "SP: " .. newVal
        statusLabel.Text = "Modo visual — alterado na tela"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 60)
    end
    updateDisplay()
end

-- ====================== BOTAO: DEFINIR SP ====================== 
setBtn.MouseButton1Click:Connect(function()
    local val = tonumber(textBox.Text)
    if not val or val < 0 then
        notify("Erro", "Digite um numero valido e positivo!", 4)
        return
    end
    local old = skillValue and skillValue.Value or 0
    applySP(val)
    notify("SP Definido!", "Antigo: " .. old .. " -> Novo: " .. val, 5)
    print("[SP Manager] Definido: " .. old .. " -> " .. val)
end)

-- ====================== BOTAO: ADICIONAR SP ====================== 
addBtn.MouseButton1Click:Connect(function()
    local val = tonumber(textBox.Text)
    if not val or val < 0 then
        notify("Erro", "Digite um numero valido e positivo!", 4)
        return
    end
    local current = 0
    if skillValue then
        current = skillValue.Value
    else
        local raw = gameSPLabel.Text:match("SP:%s*(%d+)")
        current = tonumber(raw) or 0
    end
    local newVal = current + val
    applySP(newVal)
    notify("SP Adicionado!", "+" .. val .. " (Total: " .. newVal .. ")", 5)
    print("[SP Manager] Adicionado: " .. current .. " + " .. val .. " = " .. newVal)
end)

-- ====================== BOTAO: SUBTRAIR SP ====================== 
subBtn.MouseButton1Click:Connect(function()
    local val = tonumber(textBox.Text)
    if not val or val < 0 then
        notify("Erro", "Digite um numero valido e positivo!", 4)
        return
    end
    local current = 0
    if skillValue then
        current = skillValue.Value
    else
        local raw = gameSPLabel.Text:match("SP:%s*(%d+)")
        current = tonumber(raw) or 0
    end
    local newVal = math.max(0, current - val)
    applySP(newVal)
    notify("SP Subtraido!", "-" .. val .. " (Total: " .. newVal .. ")", 5)
    print("[SP Manager] Subtraido: " .. current .. " - " .. val .. " = " .. newVal)
end)

-- ====================== FECHAR ====================== 
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- ====================== ARRASTAR JANELA ====================== 
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

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- ====================== NOTIFICACAO INICIAL ====================== 
notify(
    "SP Manager Carregado!",
    "Use DEFINIR, ADICIONAR ou SUBTRAIR SP.\nArraste pelo titulo para mover.",
    7
)
print("[SP Manager] Carregado! skillValue = " .. (skillValue and skillValue:GetFullName() or "NAO ENCONTRADO"))
