local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local LocalPlayer = Players.LocalPlayer

local versionUrl = "https://raw.githubusercontent.com/Willianz4z4/Hapieblox/main/version.json"
local rawMainUrl = "https://raw.githubusercontent.com/Willianz4z4/Hapieblox/main/main.lua"
local rawScannerUrl = "https://raw.githubusercontent.com/Willianz4z4/Hapieblox/main/Scripts/scanner.lua"

local currentVersion = "1.0.0"
pcall(function()
    local req = game:HttpGet(versionUrl .. "?t=" .. tostring(tick()))
    local data = HttpService:JSONDecode(req)
    if data and data.version then currentVersion = data.version end
end)

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
-- OS 38 IDs OFICIAIS GERADOS (SEM SPAM)
-- ==========================================
local spriteIDs = {
    124445268552489, -- 1
    87795808448354,  -- 2
    112554054774554, -- 3
    106337465271290, -- 4
    95878461796233,  -- 5
    80462860316566,  -- 6
    73198481477967,  -- 7
    114599949245557, -- 8
    135419241637584, -- 9
    77477960427023,  -- 10
    121392541420068, -- 11
    111490992938234, -- 12
    130032484238641, -- 13
    108390304734606, -- 14
    96280898565299,  -- 15
    124448032038901, -- 16
    94806513757824,  -- 17
    89539141336426,  -- 18
    112618750732962, -- 19
    135510278591208, -- 20
    124703980687330, -- 21
    84338389302969,  -- 22
    70686782719636,  -- 23
    108358169389684, -- 24
    95973579565028,  -- 25
    87055093825723,  -- 26
    93662533123963,  -- 27
    86136436406432,  -- 28
    100661827918735, -- 29
    106579723665619, -- 30
    92012869671079,  -- 31
    84305418673666,  -- 32
    92367395730576,  -- 33
    114466099524303, -- 34
    104297138771132, -- 35
    73683396288823,  -- 36
    118772178091802, -- 37
    116859081210984  -- 38
}

-- ===================================================================
-- ⚠️ CONFIGURAÇÕES DO SPRITESHEET (MUITO IMPORTANTE!) ⚠️
-- Altere os números abaixo para bater com o formato da sua imagem
-- ===================================================================
local LARGURA_FRAME = 256  -- Quantos pixels tem a LARGURA de uma cena?
local ALTURA_FRAME = 256   -- Quantos pixels tem a ALTURA de uma cena?
local COLUNAS = 5          -- Quantos desenhos tem na horizontal da imagem?
local LINHAS = 5           -- Quantos desenhos tem na vertical da imagem?
local FRAMES_POR_SHEET = 25 -- Total de cenas/quadros dentro de 1 única imagem
local FPS = 24             -- Velocidade da animação (Quadros por segundo)

-- ==========================================
-- REPRODUÇÃO DA ANIMAÇÃO INTRO (LOOP QUADRO A QUADRO)
-- ==========================================
local function tocarIntro()
    local introGui = Instance.new("ScreenGui")
    introGui.Name = "HapiebloxIntro"
    introGui.ResetOnSpawn = false
    introGui.IgnoreGuiInset = true
    introGui.Parent = guiParent

    local imageLabel = Instance.new("ImageLabel")
    imageLabel.Size = UDim2.new(1, 0, 1, 0)
    imageLabel.Position = UDim2.new(0, 0, 0, 0)
    imageLabel.BackgroundTransparency = 1 
    imageLabel.ScaleType = Enum.ScaleType.Fit
    -- Isso avisa o Roblox para NÃO mostrar a imagem toda, apenas o tamanho de 1 cena
    imageLabel.ImageRectSize = Vector2.new(LARGURA_FRAME, ALTURA_FRAME)
    imageLabel.Parent = introGui

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

    -- Motor da animação Spritesheet
    task.spawn(function()
        for i, sheetId in ipairs(spriteIDs) do
            -- Carrega o spritesheet atual (usando o ID real)
            imageLabel.Image = "rbxassetid://" .. tostring(sheetId)
            
            -- Faz o recorte percorrer a grade (Esquerda pra direita, cima pra baixo)
            for frameAtual = 0, FRAMES_POR_SHEET - 1 do
                local coluna = frameAtual % COLUNAS
                local linha = math.floor(frameAtual / COLUNAS)
                
                -- Move a "câmera" para o quadro exato da cena
                imageLabel.ImageRectOffset = Vector2.new(coluna * LARGURA_FRAME, linha * ALTURA_FRAME)
                
                -- Espera o tempo exato de 1 frame antes de ir pro próximo
                task.wait(1 / FPS)
            end
        end
        -- Quando terminar todos os 38 sheets, fecha a intro
        pcall(function() som:Destroy() end)
        introGui:Destroy()
    end)
end

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
local canto = Instance.new("UICorner"); canto.CornerRadius = UDim.new(0, 6); canto.Parent = btnScanner

btnScanner.MouseButton1Click:Connect(function()
    btnScanner.Text = "⏳ Baixando..."
    pcall(function() loadstring(game:HttpGet(rawScannerUrl .. "?t=" .. tostring(tick())))() end)
    task.wait(1)
    btnScanner.Text = "🔍 Executar Economy Scanner"
end)

-- ==========================================
-- ÍCONE FLUTUANTE 
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
iconeBotao.ImageRectSize = Vector2.new(LARGURA_FRAME, ALTURA_FRAME)
iconeBotao.ImageRectOffset = Vector2.new(0, 0) -- Pega a primeira cena para servir de logo
iconeBotao.Active = true
iconeBotao.Draggable = true
iconeBotao.Parent = toggleGui

local cantoIcone = Instance.new("UICorner"); cantoIcone.CornerRadius = UDim.new(1, 0); cantoIcone.Parent = iconeBotao
iconeBotao.MouseButton1Click:Connect(function() if janela then janela.Visible = not janela.Visible end end)

janela.Visible = true

-- ==========================================
-- AUTO-UPDATE
-- ==========================================
task.spawn(function()
    while tela and tela.Parent do
        task.wait(15)
        pcall(function()
            local req = game:HttpGet(versionUrl .. "?t=" .. tostring(tick()))
            local data = HttpService:JSONDecode(req)
            if data and data.version and data.version ~= currentVersion then
                game:GetService("StarterGui"):SetCore("SendNotification", {Title="🔥 Update", Text="Nova versão!", Duration=4})
                task.wait(1)
                limparTudo()
                loadstring(game:HttpGet(rawMainUrl .. "?t=" .. tostring(tick())))()
            end
        end)
    end
end)
