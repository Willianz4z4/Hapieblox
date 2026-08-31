local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local LocalPlayer = Players.LocalPlayer

local versionUrl = "https://raw.githubusercontent.com/Willianz4z4/Hapieblox/main/version.json"
local rawMainUrl = "https://raw.githubusercontent.com/Willianz4z4/Hapieblox/main/main.lua"
local rawScannerUrl = "https://raw.githubusercontent.com/Willianz4z4/Hapieblox/main/Scripts/scanner.lua"

-- ==========================================
-- BUSCA A VERSÃO ATUAL NO INÍCIO
-- ==========================================
local currentVersion = "1.0.0"
pcall(function()
    local req = game:HttpGet(versionUrl .. "?t=" .. tostring(tick()))
    local data = HttpService:JSONDecode(req)
    if data and data.version then currentVersion = data.version end
end)

-- ==========================================
-- DEFINIÇÃO DO PARENT DE GUI E LIMPEZA
-- ==========================================
local guiParent
pcall(function()
    if gethui then guiParent = gethui() else guiParent = game:GetService("CoreGui") end
end)
if not guiParent then guiParent = LocalPlayer:WaitForChild("PlayerGui") end

local function limparTudo()
    if guiParent:FindFirstChild("HapiebloxPanel") then guiParent.HapiebloxPanel:Destroy() end
    if guiParent:FindFirstChild("HapiebloxIntro") then guiParent.HapiebloxIntro:Destroy() end
    if guiParent:FindFirstChild("HapiebloxToggle") then guiParent.HapiebloxToggle:Destroy() end
    if guiParent:FindFirstChild("ScannerMoneyGUI") then guiParent.ScannerMoneyGUI:Destroy() end
end

limparTudo()

-- ==========================================
-- LISTA DE IDs DAS SPRITESHEETS (1 a 16)
-- ==========================================
local spriteIDs = {
    124445268552489, -- spritesheet1.png
    87795808448354,  -- spritesheet2.png
    112554054774554, -- spritesheet3.png
    106337465271290, -- spritesheet4.png
    95878461796233,  -- spritesheet5.png
    80462860316566,  -- spritesheet6.png
    73198481477967,  -- spritesheet7.png
    114599949245557, -- spritesheet8.png
    135419241637584, -- spritesheet9.png
    77477960427023,  -- spritesheet10.png
    121392541420068, -- spritesheet11.png
    111490992938234, -- spritesheet12.png
    130032484238641, -- spritesheet13.png
    108390304734606, -- spritesheet14.png
    96280898565299,  -- spritesheet15.png
    124448032038901  -- spritesheet16.png
}

-- ==========================================
-- REPRODUÇÃO DA ANIMAÇÃO INTRO (VIA SPRITESHEETS)
-- ==========================================
local function tocarIntro()
    local totalFrames = #spriteIDs
    local fps = 12 

    local introGui = Instance.new("ScreenGui")
    introGui.Name = "HapiebloxIntro"
    introGui.ResetOnSpawn = false
    introGui.IgnoreGuiInset = true
    introGui.Parent = guiParent

    local imageLabel = Instance.new("ImageLabel")
    imageLabel.Size = UDim2.new(1, 0, 1, 0)
    imageLabel.Position = UDim2.new(0, 0, 0, 0)
    imageLabel.BackgroundTransparency = 1 -- Mantém transparente caso as imagens demorem
    imageLabel.ScaleType = Enum.ScaleType.Fit
    imageLabel.Parent = introGui

    -- Tenta tocar o áudio de forma segura
    local getAsset = getcustomasset or getsynasset
    local som = Instance.new("Sound")
    som.Volume = 1
    som.Parent = SoundService

    pcall(function()
        if getAsset and isfile and isfile("Hapieblox/audio.m4a") then
            som.SoundId = getAsset("Hapieblox/audio.m4a")
            som:Play()
        end
    end)

    -- Execução baseada em tempo real
    local tempoTotal = (som.TimeLength > 0) and som.TimeLength or (totalFrames / fps)
    local inicio = tick()

    while (tick() - inicio) < tempoTotal do
        local tempoDecorrido = tick() - inicio
        local frameAtual = math.clamp(math.floor(tempoDecorrido * fps) + 1, 1, totalFrames)
        local assetIdAtual = spriteIDs[frameAtual]

        if assetIdAtual then
            imageLabel.Image = "rbxassetid://" .. tostring(assetIdAtual)
        end

        RunService.RenderStepped:Wait()
    end

    pcall(function() som:Destroy() end)
    introGui:Destroy()
end

-- Toca a introdução antes de carregar os painéis
tocarIntro()

-- ==========================================
-- CRIANDO O PAINEL PRINCIPAL
-- ==========================================
local tela = Instance.new("ScreenGui")
tela.Name = "HapiebloxPanel"
tela.ResetOnSpawn = false
tela.Parent = guiParent

local janela = Instance.new("Frame")
janela.Size = UDim2.new(0, 350, 0, 250)
janela.Position = UDim2.new(0.5, -175, 0.5, -125)
janela.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
janela.Active = true
janela.Draggable = true
janela.Parent = tela
janela.Visible = false

local titulo = Instance.new("TextLabel")
titulo.Size = UDim2.new(1, -40, 0, 40)
titulo.BackgroundTransparency = 1
titulo.Text = " 🛠️ Hapieblox Hub | v" .. currentVersion
titulo.TextColor3 = Color3.fromRGB(255, 255, 255)
titulo.TextXAlignment = Enum.TextXAlignment.Left
titulo.Font = Enum.Font.GothamBold
titulo.TextSize = 15
titulo.Parent = janela

local btnFechar = Instance.new("TextButton")
btnFechar.Size = UDim2.new(0, 40, 0, 40)
btnFechar.Position = UDim2.new(1, -40, 0, 0)
btnFechar.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
btnFechar.Text = "X"
btnFechar.TextColor3 = Color3.new(1, 1, 1)
btnFechar.Font = Enum.Font.GothamBold
btnFechar.TextSize = 16
btnFechar.Parent = janela
btnFechar.MouseButton1Click:Connect(function() janela.Visible = false end)

local linha = Instance.new("Frame")
linha.Size = UDim2.new(1, 0, 0, 2)
linha.Position = UDim2.new(0, 0, 0, 40)
linha.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
linha.BorderSizePixel = 0
linha.Parent = janela

local btnScanner = Instance.new("TextButton")
btnScanner.Size = UDim2.new(0.9, 0, 0, 45)
btnScanner.Position = UDim2.new(0.05, 0, 0, 60)
btnScanner.BackgroundColor3 = Color3.fromRGB(40, 120, 255)
btnScanner.Text = "🔍 Executar Economy Scanner"
btnScanner.TextColor3 = Color3.fromRGB(255, 255, 255)
btnScanner.Font = Enum.Font.GothamBold
btnScanner.TextSize = 14
btnScanner.Parent = janela

local canto = Instance.new("UICorner")
canto.CornerRadius = UDim.new(0, 6)
canto.Parent = btnScanner

btnScanner.MouseButton1Click:Connect(function()
    btnScanner.Text = "⏳ Baixando..."
    pcall(function()
        loadstring(game:HttpGet(rawScannerUrl .. "?t=" .. tostring(tick())))()
    end)
    task.wait(1)
    btnScanner.Text = "🔍 Executar Economy Scanner"
end)

-- ==========================================
-- CRIANDO O ÍCONE FLUTUANTE (TOGGLE)
-- ==========================================
local toggleGui = Instance.new("ScreenGui")
toggleGui.Name = "HapiebloxToggle"
toggleGui.ResetOnSpawn = false
toggleGui.Parent = guiParent

local iconeBotao = Instance.new("ImageButton")
iconeBotao.Size = UDim2.new(0, 50, 0, 50)
iconeBotao.Position = UDim2.new(0, 20, 0.5, -25)
iconeBotao.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
iconeBotao.Image = "rbxassetid://" .. tostring(spriteIDs[1])
iconeBotao.Active = true
iconeBotao.Draggable = true
iconeBotao.Parent = toggleGui

local cantoIcone = Instance.new("UICorner")
cantoIcone.CornerRadius = UDim.new(1, 0)
cantoIcone.Parent = iconeBotao

iconeBotao.MouseButton1Click:Connect(function()
    if janela then janela.Visible = not janela.Visible end
end)

janela.Visible = true

-- ==========================================
-- SISTEMA DE AUTO-UPDATE VIA JSON
-- ==========================================
task.spawn(function()
    while tela and tela.Parent do
        task.wait(15)
        pcall(function()
            local req = game:HttpGet(versionUrl .. "?t=" .. tostring(tick()))
            local data = HttpService:JSONDecode(req)

            if data and data.version and data.version ~= currentVersion then
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "🔥 Update Automático",
                    Text = "Nova versão encontrada (" .. data.version .. ").",
                    Duration = 4
                })
                task.wait(1)
                limparTudo()
                local novoMain = game:HttpGet(rawMainUrl .. "?t=" .. tostring(tick()))
                loadstring(novoMain)()
            end
        end)
    end
end)
