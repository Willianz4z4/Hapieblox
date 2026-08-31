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
    if guiParent:FindFirstChild("ScannerMoneyGUI") then guiParent.ScannerMoneyGUI:Destroy() end
end

limparTudo()

-- ==========================================
-- LISTA DE IDs DAS SPRITESHEETS UPLOADADAS
-- ==========================================
local spriteIDs = {
    139349696541931, -- spritesheet1.png
    111523477811568, -- spritesheet2.png
    85258839538040,  -- spritesheet3.png
    127483555788732, -- spritesheet4.png
    70915471988634,  -- spritesheet5.png
    128758939717944, -- spritesheet6.png
    72523310652887,  -- spritesheet7.png
    124058281780048, -- spritesheet8.png
    138119397330494, -- spritesheet9.png
    122163477446613, -- spritesheet10.png
    82280085604273,  -- spritesheet11.png
    80348263108355,  -- spritesheet12.png
    134514682100114, -- spritesheet13.png
    89018115180544,  -- spritesheet14.png
    112333313549305, -- spritesheet15.png
    126959929483189, -- spritesheet16.png
    84040978100909,  -- spritesheet17.png
    124452156229953, -- spritesheet18.png
    77661189591036,  -- spritesheet19.png
    86102383957430,  -- spritesheet20.png
    124870103496816, -- spritesheet21.png
    82749324050197,  -- spritesheet22.png
    113882981598187, -- spritesheet23.png
    133116916215469, -- spritesheet24.png
    131673118778630, -- spritesheet25.png
    116954406392539, -- spritesheet26.png
    116104262751152, -- spritesheet27.png
    135163344291107, -- spritesheet28.png
    92676508844478,  -- spritesheet29.png
    113425610443135, -- spritesheet30.png
    77296919376959,  -- spritesheet31.png
    71517867804409,  -- spritesheet32.png
    87879480755296,  -- spritesheet33.png
    72325447414055,  -- spritesheet34.png
    109982090465760, -- spritesheet35.png
    113748010362844, -- spritesheet36.png
    82569011892630,  -- spritesheet37.png
    97869238274347   -- spritesheet38.png
}

-- ==========================================
-- REPRODUÇÃO DA ANIMAÇÃO INTRO (VIA SPRITESHEETS)
-- ==========================================
local function tocarIntro()
    local getAsset = getcustomasset or getsynasset
    if not getAsset then return end

    local totalFrames = #spriteIDs
    local fps = 12 -- Velocidade ajustada para transição ideal entre as sheets

    local introGui = Instance.new("ScreenGui")
    introGui.Name = "HapiebloxIntro"
    introGui.ResetOnSpawn = false
    introGui.IgnoreGuiInset = true
    introGui.Parent = guiParent

    local imageLabel = Instance.new("ImageLabel")
    imageLabel.Size = UDim2.new(1, 0, 1, 0)
    imageLabel.Position = UDim2.new(0, 0, 0, 0)
    imageLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    imageLabel.ScaleType = Enum.ScaleType.Fit
    imageLabel.Parent = introGui

    local som = Instance.new("Sound")
    som.SoundId = getAsset("Hapieblox/audio.m4a")
    som.Volume = 1
    som.Parent = SoundService
    som:Play()

    local conexao
    local finalizado = false

    conexao = RunService.RenderStepped:Connect(function()
        if not som.IsPlaying or som.TimePosition >= som.TimeLength then
            finalizado = true
            conexao:Disconnect()
            return
        end

        local frameAtual = math.clamp(math.floor(som.TimePosition * fps) + 1, 1, totalFrames)
        local assetIdAtual = spriteIDs[frameAtual]

        pcall(function()
            if assetIdAtual then
                imageLabel.Image = "rbxassetid://" .. tostring(assetIdAtual)
            end
        end)
    end)

    while not finalizado and som.IsPlaying do
        task.wait(0.1)
    end

    if conexao then conexao:Disconnect() end
    som:Destroy()
    introGui:Destroy()
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
btnFechar.MouseButton1Click:Connect(function() tela:Destroy() end)

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
                    Text = "Nova versão encontrada (" .. data.version .. "). Atualizando de forma bruta!",
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
