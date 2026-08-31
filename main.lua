local HttpService = game:GetService("HttpService")                 
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService") 

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
-- MOTOR DE INTRODUÇÃO AVANÇADO (FUNDO TRANSPARENTE)
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

    -- Container Centralizado (Fundo 100% Transparente)
    local center = Instance.new("Frame")
    center.Size = UDim2.new(0, 600, 0, 200)
    center.AnchorPoint = Vector2.new(0.5, 0.5) -- Centralização Perfeita (Coisa boa do Lua)
    center.Position = UDim2.new(0.5, 0, 0.5, 0)
    center.BackgroundTransparency = 1
    center.Parent = introGui

    -- Texto Principal
    local textoPrincipal = Instance.new("TextLabel")
    textoPrincipal.Size = UDim2.new(1, 0, 1, 0)
    textoPrincipal.BackgroundTransparency = 1
    textoPrincipal.Font = Enum.Font.GothamBlack
    textoPrincipal.TextSize = 65
    textoPrincipal.TextColor3 = Color3.fromRGB(15, 15, 15) -- Quase preto
    textoPrincipal.Text = ""
    textoPrincipal.Parent = center

    -- Borda branca forte para o texto aparecer em qualquer fundo de jogo
    local strokeTexto = Instance.new("UIStroke")
    strokeTexto.Color = Color3.fromRGB(255, 255, 255)
    strokeTexto.Thickness = 4
    strokeTexto.LineJoinMode = Enum.LineJoinMode.Round
    strokeTexto.Parent = textoPrincipal

    task.spawn(function()
        local textoReal = "HapieBlox Script"
        
        -- Cursor piscando
        for i = 1, 2 do
            textoPrincipal.Text = "|"
            task.wait(0.3)
            textoPrincipal.Text = ""
            task.wait(0.3)
        end

        -- Digitação fluida
        for i = 1, #textoReal do
            textoPrincipal.Text = string.sub(textoReal, 1, i) .. "|"
            task.wait(math.random(3, 8) / 100) 
        end
        textoPrincipal.Text = textoReal

        -- Efeito Impacto (Tween elástico no TextSize)
        local sizeOriginal = textoPrincipal.TextSize
        TweenService:Create(textoPrincipal, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {TextSize = sizeOriginal + 10}):Play()
        task.wait(0.1)
        TweenService:Create(textoPrincipal, TweenInfo.new(0.4, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {TextSize = sizeOriginal}):Play()

        -- Função Criadora de Doodles Animados
        local function criarDoodle(emoji, pos, rotacao, tamanhoFinal, delayAparecer)
            -- task.delay executa sem travar o resto do script
            task.delay(delayAparecer, function()
                local lbl = Instance.new("TextLabel")
                lbl.BackgroundTransparency = 1
                lbl.Text = emoji
                lbl.TextSize = 0
                lbl.Rotation = rotacao - 60 -- Nasce girado pra dar efeito de rotação ao crescer
                lbl.Position = pos
                lbl.Font = Enum.Font.GothamBold
                lbl.TextColor3 = Color3.fromRGB(20, 20, 20)
                lbl.Parent = center

                local stroke = Instance.new("UIStroke")
                stroke.Color = Color3.fromRGB(255, 255, 255)
                stroke.Thickness = 2.5
                stroke.Parent = lbl
                
                -- Animação Elástica ("Quique")
                local anim = TweenInfo.new(0.7, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
                TweenService:Create(lbl, anim, {TextSize = tamanhoFinal, Rotation = rotacao}):Play()
            end)
        end

        -- Spawna os desenhos em cascata (efeito de "pop pop pop")
        criarDoodle("😉", UDim2.new(0.85, 0, 0.25, 0), 15, 60, 0.0)
        criarDoodle("👁️", UDim2.new(0.80, 0, -0.05, 0), -10, 50, 0.1)
        criarDoodle("✨", UDim2.new(0.15, 0, 0.2, 0), -20, 45, 0.2)
        criarDoodle("~", UDim2.new(0.25, 0, 0.8, 0), 10, 70, 0.3)
        criarDoodle("{", UDim2.new(0.10, 0, 0.6, 0), 0, 55, 0.4)
        criarDoodle("💥", UDim2.new(0.90, 0, 0.7, 0), -15, 45, 0.5)

        task.wait(2.2)

        -- Fade Out ultra suave usando Tween
        local fadeInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        for _, obj in ipairs(center:GetChildren()) do
            if obj:IsA("TextLabel") then
                TweenService:Create(obj, fadeInfo, {TextTransparency = 1}):Play()
                if obj:FindFirstChild("UIStroke") then
                    TweenService:Create(obj.UIStroke, fadeInfo, {Transparency = 1}):Play()
                end
            end
        end

        task.wait(0.6)
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
