local HttpService = game:GetService("HttpService")                 
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService") -- ADICIONADO PARA ANIMAÇÕES SUAVES

local LocalPlayer = Players.LocalPlayer                            
local versionUrl = "https://raw.githubusercontent.com/Willianz4z4/Hapieblox/main/version.json"
local rawMainUrl = "https://raw.githubusercontent.com/Willianz4z4/Hapieblox/main/main.lua"
local rawScannerUrl = "https://raw.githubusercontent.com/Willianz4z4/Hapieblox/main/Scripts/scanner.lua"
                                                                   
local currentVersion = "1.0.0"

pcall(function()                                                       
    local req = game:HttpGet(versionUrl .. "?t=" .. tostring(tick()))                                                                     
    local data = HttpService:JSONDecode(req)
    if data and data.version then 
        currentVersion = data.version 
    end
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
-- MOTOR DE INTRODUÇÃO RECRIADO COM GUI (SEM IMAGENS)
-- ==========================================
local function tocarIntro(aoTerminar)
    if guiParent:FindFirstChild("HapiebloxIntro") then
        guiParent.HapiebloxIntro:Destroy()
    end

    -- Cria a tela da Intro
    local introGui = Instance.new("ScreenGui")
    introGui.Name = "HapiebloxIntro"
    introGui.ResetOnSpawn = false
    introGui.IgnoreGuiInset = true
    introGui.Parent = guiParent

    -- Fundo branco puro
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(245, 245, 245) -- Branco meio "papel"
    bg.Parent = introGui

    -- Container central para organizar os elementos
    local center = Instance.new("Frame")
    center.Size = UDim2.new(0, 500, 0, 150)
    center.Position = UDim2.new(0.5, -250, 0.5, -75)
    center.BackgroundTransparency = 1
    center.Parent = bg

    -- Texto principal da Intro
    local textoPrincipal = Instance.new("TextLabel")
    textoPrincipal.Size = UDim2.new(1, 0, 1, 0)
    textoPrincipal.BackgroundTransparency = 1
    textoPrincipal.Font = Enum.Font.GothamBlack -- Fonte gordinha parecida com a do video
    textoPrincipal.TextSize = 50
    textoPrincipal.TextColor3 = Color3.fromRGB(15, 15, 15)
    textoPrincipal.Text = ""
    textoPrincipal.TextXAlignment = Enum.TextXAlignment.Center
    textoPrincipal.Parent = center

    -- Script de animação puramente via código
    task.spawn(function()
        local textoReal = "HapieBlox Script"
        
        -- 1. Efeito do Cursor piscando antes de digitar
        task.wait(0.5)
        textoPrincipal.Text = "|"
        task.wait(0.4)
        textoPrincipal.Text = ""
        task.wait(0.3)
        textoPrincipal.Text = "|"
        task.wait(0.4)

        -- 2. Efeito de Digitação Realista
        for i = 1, #textoReal do
            -- Pega letra por letra e adiciona o cursor na frente
            textoPrincipal.Text = string.sub(textoReal, 1, i) .. "|"
            -- Tempo aleatório para parecer que alguém está digitando de verdade
            task.wait(math.random(4, 9) / 100) 
        end
        
        -- Cursor pisca no final depois de escrever tudo
        for i = 1, 2 do
            textoPrincipal.Text = textoReal
            task.wait(0.3)
            textoPrincipal.Text = textoReal .. "|"
            task.wait(0.3)
        end
        textoPrincipal.Text = textoReal -- Remove o cursor no final

        -- 3. O "Impacto" / "Glitch" (Tremida na tela)
        local posOriginal = center.Position
        for i = 1, 8 do
            center.Position = posOriginal + UDim2.new(0, math.random(-8, 8), 0, math.random(-8, 8))
            bg.BackgroundColor3 = i % 2 == 0 and Color3.fromRGB(220, 220, 220) or Color3.fromRGB(255, 255, 255)
            task.wait(0.02)
        end
        center.Position = posOriginal
        bg.BackgroundColor3 = Color3.fromRGB(245, 245, 245)

        -- 4. Função criadora dos "Doodles" (as carinhas em volta)
        local function criarDoodle(emoji, pos, rotacao, tamanhoFinal)
            local lbl = Instance.new("TextLabel")
            lbl.BackgroundTransparency = 1
            lbl.Text = emoji
            lbl.TextSize = 0 -- Nasce invisivel/pequeno
            lbl.Rotation = rotacao
            lbl.Position = pos
            lbl.Font = Enum.Font.GothamBold
            lbl.TextColor3 = Color3.fromRGB(30, 30, 30)
            lbl.Parent = center

            -- Tween faz ele "pular" e estourar no tamanho real
            local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            TweenService:Create(lbl, tweenInfo, {TextSize = tamanhoFinal}):Play()
        end

        -- Cria as decorações em volta do texto (simulando os desenhos do video)
        criarDoodle("😉", UDim2.new(0.9, -10, 0.4, 0), 15, 45) -- Rosto piscando lado direito
        criarDoodle("👁️", UDim2.new(0.85, 0, -0.1, 0), -10, 40) -- Olho em cima
        criarDoodle("✨", UDim2.new(0.1, 0, 0.1, 0), -20, 35) -- Estrelas/Risco lado esquerdo
        criarDoodle("~", UDim2.new(0.2, 0, 0.8, 0), 10, 50) -- Risquinho embaxo
        criarDoodle("{", UDim2.new(0.05, 0, 0.6, 0), 0, 40) -- Chaves na esquerda
        criarDoodle("💥", UDim2.new(0.95, 0, 0.8, 0), -15, 30) -- Explosão pequena direita

        task.wait(2) -- Tempo mostrando os desenhos

        -- 5. Transição / Fade out de tudo (dissolver)
        local fadeBg = TweenService:Create(bg, TweenInfo.new(0.6), {BackgroundTransparency = 1})
        fadeBg:Play()

        for _, obj in ipairs(center:GetChildren()) do
            if obj:IsA("TextLabel") then
                TweenService:Create(obj, TweenInfo.new(0.4), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
            end
        end

        task.wait(0.6)
        
        introGui:Destroy()
        if aoTerminar then aoTerminar() end
    end)
end

-- Toca a intro na inicialização do Hub
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

local iconeBotao = Instance.new("TextButton")
iconeBotao.Size = UDim2.new(0, 50, 0, 50)
iconeBotao.Position = UDim2.new(0, 20, 0.5, -25)
iconeBotao.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
iconeBotao.Text = "HB"
iconeBotao.TextColor3 = Color3.new(1, 1, 1)
iconeBotao.Font = Enum.Font.GothamBlack
iconeBotao.TextSize = 18
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
