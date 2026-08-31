local HttpService = game:GetService("HttpService")                 
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService") 
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
-- MOTOR DE INTRODUÇÃO V3.0 (FOFA, PARTÍCULAS E ÁUDIO)
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

    -- Áudio Sincronizado
    local sfx = Instance.new("Sound")
    sfx.SoundId = "rbxassetid://92988767341384"
    sfx.Volume = 2
    sfx.Parent = SoundService
    sfx:Play()

    -- Container Central
    local center = Instance.new("Frame")
    center.Size = UDim2.new(0, 600, 0, 200)
    center.AnchorPoint = Vector2.new(0.5, 0.5)
    center.Position = UDim2.new(0.5, 0, 0.5, 0)
    center.BackgroundTransparency = 1
    center.Parent = introGui

    -- Brilho fofo no fundo
    local brilho = Instance.new("ImageLabel")
    brilho.Image = "rbxassetid://1319266157" -- Textura de Glow
    brilho.Size = UDim2.new(0, 0, 0, 0)
    brilho.Position = UDim2.new(0.5, 0, 0.5, 0)
    brilho.AnchorPoint = Vector2.new(0.5, 0.5)
    brilho.BackgroundTransparency = 1
    brilho.ImageColor3 = Color3.fromRGB(255, 180, 220) -- Rosa claro mágico
    brilho.ImageTransparency = 1
    brilho.Parent = center

    -- Container para as letras pulantes
    local textContainer = Instance.new("Frame")
    textContainer.Size = UDim2.new(1, 0, 1, 0)
    textContainer.BackgroundTransparency = 1
    textContainer.Parent = center

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 2)
    layout.Parent = textContainer

    task.spawn(function()
        task.wait(0.3) -- Pausa estratégica para bater o visual com o áudio

        -- Expande o brilho
        TweenService:Create(brilho, TweenInfo.new(1.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 800, 0, 800),
            ImageTransparency = 0.5
        }):Play()

        -- Sistema de Partículas saindo do chão
        for i = 1, 25 do
            task.spawn(function()
                local part = Instance.new("Frame")
                local pSize = math.random(6, 16)
                part.Size = UDim2.new(0, pSize, 0, pSize)
                -- Nascem lá no fundo (Y = 1.2)
                part.Position = UDim2.new(math.random(10, 90)/100, 0, 1.2, 0)
                part.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(1, 0); corner.Parent = part
                part.Parent = introGui
                
                -- Sobe, vira pra os lados e some
                local tInfo = TweenInfo.new(math.random(15, 30)/10, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
                local tw = TweenService:Create(part, tInfo, {
                    Position = UDim2.new(part.Position.X.Scale + (math.random(-10, 10)/100), 0, math.random(20, 60)/100, 0),
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 0, 0, 0)
                })
                tw:Play()
                tw.Completed:Connect(function() part:Destroy() end)
            end)
            task.wait(0.01)
        end

        -- Criação das Letras que Pulam (Bounce)
        local textoReal = "HapieBlox Script"
        for i = 1, #textoReal do
            local char = string.sub(textoReal, i, i)
            
            -- Caixa protetora da letra
            local charWrap = Instance.new("Frame")
            charWrap.Size = char == " " and UDim2.new(0, 20, 0, 80) or UDim2.new(0, 42, 0, 80)
            charWrap.BackgroundTransparency = 1
            charWrap.Parent = textContainer

            if char ~= " " then
                local lbl = Instance.new("TextLabel")
                lbl.Text = char
                lbl.Size = UDim2.new(1, 0, 1, 0)
                lbl.Position = UDim2.new(0, 0, 0.8, 0) -- Nasce caida
                lbl.BackgroundTransparency = 1
                lbl.Font = Enum.Font.GothamBlack
                lbl.TextSize = 0 -- Nasce invisivel
                lbl.TextColor3 = Color3.fromRGB(25, 25, 30)
                lbl.Parent = charWrap

                local str = Instance.new("UIStroke")
                str.Color = Color3.fromRGB(255, 255, 255)
                str.Thickness = 4
                str.Parent = lbl

                task.spawn(function()
                    local tInfo = TweenInfo.new(0.6, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
                    TweenService:Create(lbl, tInfo, {
                        TextSize = 65,
                        Position = UDim2.new(0, 0, 0, 0) -- Pula para a posição normal
                    }):Play()
                end)
            end
            task.wait(0.04) -- Efeito de digitação/cascata rápida
        end

        -- Função para os Emojis Fofos
        local function criarDoodle(emoji, pos, rotacao, tamanhoFinal, delayAparecer)
            task.delay(delayAparecer, function()
                local lbl = Instance.new("TextLabel")
                lbl.BackgroundTransparency = 1
                lbl.Text = emoji
                lbl.TextSize = 0
                lbl.Rotation = rotacao - 60 
                lbl.Position = pos
                lbl.Font = Enum.Font.GothamBold
                lbl.Parent = center

                local anim = TweenInfo.new(0.8, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
                TweenService:Create(lbl, anim, {TextSize = tamanhoFinal, Rotation = rotacao}):Play()
            end)
        end

        -- Emojis fofos e brilhantes
        criarDoodle("🌸", UDim2.new(0.9, 0, 0.25, 0), 15, 55, 0.2)
        criarDoodle("💖", UDim2.new(0.85, 0, -0.05, 0), -10, 45, 0.3)
        criarDoodle("☁️", UDim2.new(0.12, 0, 0.15, 0), -20, 60, 0.4)
        criarDoodle("🎀", UDim2.new(0.20, 0, 0.8, 0), 10, 50, 0.5)
        criarDoodle("🧸", UDim2.new(0.08, 0, 0.55, 0), 5, 45, 0.6)
        criarDoodle("✨", UDim2.new(0.88, 0, 0.75, 0), -15, 50, 0.7)

        task.wait(2.8) -- Tempo que a arte fica na tela

        -- Fade Out completo
        local fadeInfo = TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
        TweenService:Create(brilho, fadeInfo, {ImageTransparency = 1, Size = UDim2.new(0, 1000, 0, 1000)}):Play()
        
        for _, wrap in ipairs(textContainer:GetChildren()) do
            if wrap:IsA("Frame") then
                for _, obj in ipairs(wrap:GetChildren()) do
                    if obj:IsA("TextLabel") then
                        TweenService:Create(obj, fadeInfo, {TextTransparency = 1, Position = UDim2.new(0, 0, -0.5, 0)}):Play()
                        if obj:FindFirstChild("UIStroke") then
                            TweenService:Create(obj.UIStroke, fadeInfo, {Transparency = 1}):Play()
                        end
                    end
                end
            end
        end

        for _, obj in ipairs(center:GetChildren()) do
            if obj:IsA("TextLabel") then
                TweenService:Create(obj, fadeInfo, {TextTransparency = 1, TextSize = 0}):Play()
            end
        end

        task.wait(0.6)
        pcall(function() sfx:Destroy() end)
        introGui:Destroy()
        if aoTerminar then aoTerminar() end
    end)
end

-- Toca a intro na inicialização
tocarIntro()

-- ==========================================
-- PAINEL PRINCIPAL & BOTOES
-- ==========================================
local tela = Instance.new("ScreenGui")
tela.Name = "HapiebloxPanel"
tela.ResetOnSpawn = false
tela.Parent = guiParent

local janela = Instance.new("Frame")
janela.Size = UDim2.new(0, 350, 0, 280)
janela.Position = UDim2.new(0.5, -175, 0.5, -140)
janela.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
janela.Active = true; janela.Draggable = true
janela.Parent = tela

local titulo = Instance.new("TextLabel")
titulo.Size = UDim2.new(1, -40, 0, 40)
titulo.BackgroundTransparency = 1
titulo.Text = " 🛠️ Hapieblox Hub | v" .. currentVersion
titulo.TextColor3 = Color3.fromRGB(255, 255, 255)
titulo.TextXAlignment = Enum.TextXAlignment.Left
titulo.Font = Enum.Font.GothamBold; titulo.TextSize = 15
titulo.Parent = janela

local btnFechar = Instance.new("TextButton")
btnFechar.Size = UDim2.new(0, 40, 0, 40)
btnFechar.Position = UDim2.new(1, -40, 0, 0)
btnFechar.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
btnFechar.Text = "X"; btnFechar.TextColor3 = Color3.new(1, 1, 1)
btnFechar.Font = Enum.Font.GothamBold; btnFechar.TextSize = 16
btnFechar.Parent = janela
btnFechar.MouseButton1Click:Connect(function() janela.Visible = false end)

local linha = Instance.new("Frame")
linha.Size = UDim2.new(1, 0, 0, 2)
linha.Position = UDim2.new(0, 0, 0, 40)
linha.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
linha.BorderSizePixel = 0; linha.Parent = janela

local btnScanner = Instance.new("TextButton")
btnScanner.Size = UDim2.new(0.9, 0, 0, 45)
btnScanner.Position = UDim2.new(0.05, 0, 0, 60)
btnScanner.BackgroundColor3 = Color3.fromRGB(40, 120, 255)
btnScanner.Text = "🔍 Executar Economy Scanner"
btnScanner.TextColor3 = Color3.fromRGB(255, 255, 255)
btnScanner.Font = Enum.Font.GothamBold; btnScanner.TextSize = 14
btnScanner.Parent = janela
local c1 = Instance.new("UICorner"); c1.CornerRadius = UDim.new(0, 6); c1.Parent = btnScanner

btnScanner.MouseButton1Click:Connect(function()
    btnScanner.Text = "⏳ Baixando..."
    pcall(function() loadstring(game:HttpGet(rawScannerUrl .. "?t=" .. tostring(tick())))() end)
    task.wait(1)
    btnScanner.Text = "🔍 Executar Economy Scanner"
end)

local btnAnimacao = Instance.new("TextButton")
btnAnimacao.Size = UDim2.new(0.9, 0, 0, 45)
btnAnimacao.Position = UDim2.new(0.05, 0, 0, 115)
btnAnimacao.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
btnAnimacao.Text = "🎬 Testar Animação"
btnAnimacao.TextColor3 = Color3.fromRGB(255, 255, 255)
btnAnimacao.Font = Enum.Font.GothamBold; btnAnimacao.TextSize = 14
btnAnimacao.Parent = janela
local c2 = Instance.new("UICorner"); c2.CornerRadius = UDim.new(0, 6); c2.Parent = btnAnimacao

btnAnimacao.MouseButton1Click:Connect(function()
    janela.Visible = false
    tocarIntro(function() janela.Visible = true end)
end)

local toggleGui = Instance.new("ScreenGui")
toggleGui.Name = "HapiebloxToggle"
toggleGui.ResetOnSpawn = false
toggleGui.Parent = guiParent

local iconeBotao = Instance.new("TextButton")
iconeBotao.Size = UDim2.new(0, 50, 0, 50)
iconeBotao.Position = UDim2.new(0, 20, 0.5, -25)
iconeBotao.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
iconeBotao.Text = "HB"
iconeBotao.TextColor3 = Color3.new(1, 1, 1)
iconeBotao.Font = Enum.Font.GothamBlack; iconeBotao.TextSize = 18
iconeBotao.Active = true; iconeBotao.Draggable = true
iconeBotao.Parent = toggleGui

local c3 = Instance.new("UICorner"); c3.CornerRadius = UDim.new(1, 0); c3.Parent = iconeBotao
iconeBotao.MouseButton1Click:Connect(function() if janela then janela.Visible = not janela.Visible end end)

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
