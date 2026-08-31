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
-- TABELA MAPEADA AUTOMATICAMENTE (5x5 - 480x270)
-- ==========================================
local spriteIDs = {
    { id = 124445268552489, col = 5, row = 5, fw = 480, fh = 270, maxFrames = 25 },
    { id = 87795808448354, col = 5, row = 5, fw = 480, fh = 270, maxFrames = 25 },
    { id = 112554054774554, col = 5, row = 5, fw = 480, fh = 270, maxFrames = 25 },
    { id = 106337465271290, col = 5, row = 5, fw = 480, fh = 270, maxFrames = 25 },
    { id = 95878461796233, col = 5, row = 5, fw = 480, fh = 270, maxFrames = 25 },
    { id = 80462860316566, col = 5, row = 5, fw = 480, fh = 270, maxFrames = 25 },
    { id = 73198481477967, col = 5, row = 5, fw = 480, fh = 270, maxFrames = 25 },
    { id = 114599949245557, col = 5, row = 5, fw = 480, fh = 270, maxFrames = 25 },
    { id = 135419241637584, col = 5, row = 5, fw = 480, fh = 270, maxFrames = 25 },
    { id = 77477960427023, col = 5, row = 5, fw = 480, fh = 270, maxFrames = 25 },
    { id = 121392541420068, col = 5, row = 5, fw = 480, fh = 270, maxFrames = 25 },
    { id = 111490992938234, col = 5, row = 5, fw = 480, fh = 270, maxFrames = 25 },
    { id = 130032484238641, col = 5, row = 5, fw = 480, fh = 270, maxFrames = 25 },
    { id = 108390304734606, col = 5, row = 5, fw = 480, fh = 270, maxFrames = 25 },
    { id = 96280898565299, col = 5, row = 5, fw = 480, fh = 270, maxFrames = 25 },
    { id = 124448032038901, col = 5, row = 5, fw = 480, fh = 270, maxFrames = 25 },
    { id = 94806513757824, col = 5, row = 5, fw = 480, fh = 270, maxFrames = 25 },
    { id = 89539141336426, col = 5, row = 5, fw = 480, fh = 270, maxFrames = 25 },
    { id = 112618750732962, col = 5, row = 5, fw = 480, fh = 270, maxFrames = 25 },
    { id = 135510278591208, col = 5, row = 5, fw = 480, fh = 270, maxFrames = 25 },
    { id = 124703980687330, col = 5, row = 5, fw = 480, fh = 270, maxFrames = 25 },
    { id = 84338389302969, col = 5, row = 5, fw = 480, fh = 270, maxFrames = 25 },
    { id = 70686782719636, col = 5, row = 5, fw = 480, fh = 270, maxFrames = 25 },
    { id = 108358169389684, col = 5, row = 5, fw = 480, fh = 270, maxFrames = 25 },
    { id = 95973579565028, col = 5, row = 5, fw = 480, fh = 270, maxFrames = 25 },
    { id = 87055093825723, col = 5, row = 5, fw = 480, fh = 270, maxFrames = 25 },
    { id = 93662533123963, col = 5, row = 5, fw = 480, fh = 270, maxFrames = 25 },
    { id = 86136436406432, col = 5, row = 5, fw = 480, fh = 270, maxFrames = 25 },
    { id = 100661827918735, col = 5, row = 5, fw = 480, fh = 270, maxFrames = 25 },
    { id = 106579723665619, col = 5, row = 5, fw = 480, fh = 270, maxFrames = 25 },
    { id = 92012869671079, col = 5, row = 5, fw = 480, fh = 270, maxFrames = 25 },
    { id = 84305418673666, col = 5, row = 5, fw = 480, fh = 270, maxFrames = 25 },
    { id = 92367395730576, col = 5, row = 5, fw = 480, fh = 270, maxFrames = 25 },
    { id = 114466099524303, col = 5, row = 5, fw = 480, fh = 270, maxFrames = 25 },
    { id = 104297138771132, col = 5, row = 5, fw = 480, fh = 270, maxFrames = 25 },
    { id = 73683396288823, col = 5, row = 5, fw = 480, fh = 270, maxFrames = 25 },
    { id = 118772178091802, col = 5, row = 5, fw = 480, fh = 270, maxFrames = 25 },
    { id = 116859081210984, col = 5, row = 5, fw = 480, fh = 270, maxFrames = 25 }
}

-- ==========================================
-- MOTOR DE REPRODUÇÃO DA INTRO
-- ==========================================
local function tocarIntro(aoTerminar)
    if guiParent:FindFirstChild("HapiebloxIntro") then 
        guiParent.HapiebloxIntro:Destroy() 
    end

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

    task.spawn(function()
        for _, sheet in ipairs(spriteIDs) do
            imageLabel.Image = "rbxassetid://" .. tostring(sheet.id)
            imageLabel.ImageRectSize = Vector2.new(sheet.fw, sheet.fh)
            
            for frame = 0, sheet.maxFrames - 1 do
                local col = frame % sheet.col
                local row = math.floor(frame / sheet.col)
                imageLabel.ImageRectOffset = Vector2.new(col * sheet.fw, row * sheet.fh)
                task.wait(1 / 24)
            end
        end
        pcall(function() som:Destroy() end)
        introGui:Destroy()
        if aoTerminar then aoTerminar() end
    end)
end

-- Toca a intro na inicialização
tocarIntro()

-- ==========================================
-- PAINEL PRINCIPAL & BOTÃO DE TESTE DE ANIMAÇÃO
-- ==========================================
local tela = Instance.new("ScreenGui")
tela.Name = "HapiebloxPanel"
tela.ResetOnSpawn = false
tela.Parent = guiParent

local janela = Instance.new("Frame")
janela.Size = UDim2.new(0, 350, 0, 280)
janela.Position = UDim2.new(0.5, -175, 0.5, -140)
janela.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
janela.Active = true
janela.Draggable = true
janela.Parent = tela
janela.Visible = true

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

-- Botão do Scanner
local btnScanner = Instance.new("TextButton")
btnScanner.Size = UDim2.new(0.9, 0, 0, 45)
btnScanner.Position = UDim2.new(0.05, 0, 0, 60)
btnScanner.BackgroundColor3 = Color3.fromRGB(40, 120, 255)
btnScanner.Text = "🔍 Executar Economy Scanner"
btnScanner.TextColor3 = Color3.fromRGB(255, 255, 255)
btnScanner.Font = Enum.Font.GothamBold
btnScanner.TextSize = 14
btnScanner.Parent = janela
local canto1 = Instance.new("UICorner"); canto1.CornerRadius = UDim.new(0, 6); canto1.Parent = btnScanner

btnScanner.MouseButton1Click:Connect(function()
    btnScanner.Text = "⏳ Baixando..."
    pcall(function() loadstring(game:HttpGet(rawScannerUrl .. "?t=" .. tostring(tick())))() end)
    task.wait(1)
    btnScanner.Text = "🔍 Executar Economy Scanner"
end)

-- NOVO BOTÃO: Testar Animação Novamente
local btnAnimacao = Instance.new("TextButton")
btnAnimacao.Size = UDim2.new(0.9, 0, 0, 45)
btnAnimacao.Position = UDim2.new(0.05, 0, 0, 115)
btnAnimacao.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
btnAnimacao.Text = "🎬 Testar Animação"
btnAnimacao.TextColor3 = Color3.fromRGB(255, 255, 255)
btnAnimacao.Font = Enum.Font.GothamBold
btnAnimacao.TextSize = 14
btnAnimacao.Parent = janela
local canto2 = Instance.new("UICorner"); canto2.CornerRadius = UDim.new(0, 6); canto2.Parent = btnAnimacao

btnAnimacao.MouseButton1Click:Connect(function()
    janela.Visible = false
    tocarIntro(function()
        janela.Visible = true
    end)
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
iconeBotao.Image = "rbxassetid://" .. tostring(spriteIDs[1].id)
iconeBotao.ImageRectSize = Vector2.new(spriteIDs[1].fw, spriteIDs[1].fh)
iconeBotao.ImageRectOffset = Vector2.new(0, 0)
iconeBotao.Active = true
iconeBotao.Draggable = true
iconeBotao.Parent = toggleGui

local cantoIcone = Instance.new("UICorner"); cantoIcone.CornerRadius = UDim.new(1, 0); cantoIcone.Parent = iconeBotao
iconeBotao.MouseButton1Click:Connect(function() if janela then janela.Visible = not janela.Visible end end)

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
