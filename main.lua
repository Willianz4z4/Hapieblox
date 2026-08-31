local HttpService = game:GetService("HttpService")                 
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService") 
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")

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
end

limparTudo()

-- ==========================================
-- INTRO V5.0 (MEGA PARTICLES 3D + BOLINHAS 2D)
-- ==========================================
local function tocarIntro(aoTerminar)
    if guiParent:FindFirstChild("HapiebloxIntro") then guiParent.HapiebloxIntro:Destroy() end

    local introGui = Instance.new("ScreenGui")
    introGui.Name = "HapiebloxIntro"
    introGui.ResetOnSpawn = false
    introGui.IgnoreGuiInset = true
    introGui.Parent = guiParent

    -- 1. Efeito 3D no Mapa (Emissor DUPLO de Partículas na Câmera)
    local cam = workspace.CurrentCamera
    local particlePart = Instance.new("Part")
    particlePart.Size = Vector3.new(1, 1, 1)
    particlePart.Transparency = 1
    particlePart.Anchored = true
    particlePart.CanCollide = false
    particlePart.Parent = cam

    -- Emissor 1: Estrelas brilhantes
    local pe1 = Instance.new("ParticleEmitter")
    pe1.Texture = "rbxassetid://243660364" 
    pe1.LightEmission = 1
    pe1.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 150, 200)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 150, 255))
    })
    pe1.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.5, 2), NumberSequenceKeypoint.new(1, 0)})
    pe1.Rate = 0
    pe1.Speed = NumberRange.new(20, 50)
    pe1.Lifetime = NumberRange.new(1.5, 3)
    pe1.SpreadAngle = Vector2.new(180, 180)
    pe1.Parent = particlePart

    -- Emissor 2: Fumaça mágica/Glow
    local pe2 = Instance.new("ParticleEmitter")
    pe2.Texture = "rbxassetid://1319266157"
    pe2.LightEmission = 0.8
    pe2.Color = ColorSequence.new(Color3.fromRGB(255, 200, 230))
    pe2.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.5, 4), NumberSequenceKeypoint.new(1, 0)})
    pe2.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.2, 0.5), NumberSequenceKeypoint.new(1, 1)})
    pe2.Rate = 0
    pe2.Speed = NumberRange.new(10, 30)
    pe2.Lifetime = NumberRange.new(2, 4)
    pe2.SpreadAngle = Vector2.new(180, 180)
    pe2.Parent = particlePart

    -- Segue a câmera do jogador
    local runConn = RunService.RenderStepped:Connect(function()
        particlePart.CFrame = cam.CFrame * CFrame.new(0, 0, -12)
    end)

    -- 2. Áudio Sincronizado
    local sfx = Instance.new("Sound")
    sfx.SoundId = "rbxassetid://92988767341384"
    sfx.Volume = 2
    sfx.Parent = SoundService
    sfx:Play()

    -- 3. Elementos 2D
    local center = Instance.new("Frame")
    center.Size = UDim2.new(1, 0, 1, 0)
    center.BackgroundTransparency = 1
    center.Parent = introGui

    local brilho = Instance.new("ImageLabel")
    brilho.Image = "rbxassetid://1319266157"
    brilho.Size = UDim2.new(0, 0, 0, 0)
    brilho.Position = UDim2.new(0.5, 0, 0.5, 0)
    brilho.AnchorPoint = Vector2.new(0.5, 0.5)
    brilho.BackgroundTransparency = 1
    brilho.ImageColor3 = Color3.fromRGB(255, 170, 220)
    brilho.ImageTransparency = 1
    brilho.Parent = center

    local textContainer = Instance.new("Frame")
    textContainer.Size = UDim2.new(1, 0, 1, 0)
    textContainer.BackgroundTransparency = 1
    textContainer.Parent = center

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 0)
    layout.Parent = textContainer

    task.spawn(function()
        task.wait(0.3) 
        
        -- DISPARA EXPLOSÃO 3D MASSIVA (400 Partículas no mundo!)
        pe1:Emit(250) 
        pe2:Emit(150)

        -- Expande Brilho 2D
        TweenService:Create(brilho, TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 700, 0, 700),
            ImageTransparency = 0.4
        }):Play()

        -- BOLINHAS FLUTUANTES (V3.0) VOLTARAM!
        for i = 1, 40 do
            task.spawn(function()
                local part = Instance.new("Frame")
                local pSize = math.random(8, 20)
                part.Size = UDim2.new(0, pSize, 0, pSize)
                part.Position = UDim2.new(math.random(5, 95)/100, 0, 1.2, 0) -- Nascem em baixo
                -- Cores aleatórias entre branco e rosinha
                part.BackgroundColor3 = math.random(1, 2) == 1 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(255, 200, 230)
                local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(1, 0); corner.Parent = part
                part.Parent = introGui
                
                local tInfo = TweenInfo.new(math.random(20, 40)/10, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
                local tw = TweenService:Create(part, tInfo, {
                    Position = UDim2.new(part.Position.X.Scale + (math.random(-15, 15)/100), 0, math.random(10, 60)/100, 0),
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 0, 0, 0)
                })
                tw:Play()
                tw.Completed:Connect(function() part:Destroy() end)
            end)
            task.wait(0.01)
        end

        -- Texto Bounce Redimensionado para Celular
        local textoReal = "HapieBlox Script"
        local fontSize = 38
        
        for i = 1, #textoReal do
            local char = string.sub(textoReal, i, i)
            local charWrap = Instance.new("Frame")
            charWrap.Size = char == " " and UDim2.new(0, 10, 0, 60) or UDim2.new(0, 24, 0, 60)
            charWrap.BackgroundTransparency = 1
            charWrap.Parent = textContainer

            if char ~= " " then
                local lbl = Instance.new("TextLabel")
                lbl.Text = char
                lbl.Size = UDim2.new(1, 0, 1, 0)
                lbl.Position = UDim2.new(0, 0, 0.5, 0)
                lbl.BackgroundTransparency = 1
                lbl.Font = Enum.Font.GothamBlack
                lbl.TextSize = 0
                lbl.TextColor3 = Color3.fromRGB(20, 20, 25)
                lbl.Parent = charWrap

                local str = Instance.new("UIStroke")
                str.Color = Color3.fromRGB(255, 255, 255)
                str.Thickness = 3
                str.Parent = lbl

                task.spawn(function()
                    TweenService:Create(lbl, TweenInfo.new(0.6, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {
                        TextSize = fontSize,
                        Position = UDim2.new(0, 0, 0, 0)
                    }):Play()
                end)
            end
            task.wait(0.03)
        end

        -- Emojis fofos saltando em volta
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

        criarDoodle("🌸", UDim2.new(0.85, 0, 0.25, 0), 15, 50, 0.2)
        criarDoodle("💖", UDim2.new(0.80, 0, -0.05, 0), -10, 40, 0.3)
        criarDoodle("☁️", UDim2.new(0.12, 0, 0.15, 0), -20, 55, 0.4)
        criarDoodle("🎀", UDim2.new(0.20, 0, 0.8, 0), 10, 45, 0.5)
        criarDoodle("🧸", UDim2.new(0.08, 0, 0.55, 0), 5, 40, 0.6)
        criarDoodle("✨", UDim2.new(0.88, 0, 0.75, 0), -15, 45, 0.7)

        task.wait(2.5)

        -- Fade Out Limpo
        local fadeInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(brilho, fadeInfo, {ImageTransparency = 1, Size = UDim2.new(0, 900, 0, 900)}):Play()
        
        for _, wrap in ipairs(textContainer:GetChildren()) do
            if wrap:IsA("Frame") then
                for _, obj in ipairs(wrap:GetChildren()) do
                    if obj:IsA("TextLabel") then
                        TweenService:Create(obj, fadeInfo, {TextTransparency = 1, Position = UDim2.new(0, 0, -0.3, 0)}):Play()
                        if obj:FindFirstChild("UIStroke") then TweenService:Create(obj.UIStroke, fadeInfo, {Transparency = 1}):Play() end
                    end
                end
            end
        end
        for _, obj in ipairs(center:GetChildren()) do
            if obj:IsA("TextLabel") then TweenService:Create(obj, fadeInfo, {TextTransparency = 1, TextSize = 0}):Play() end
        end

        task.wait(0.6)
        
        -- Destrói TODAS as partículas do mapa para não dar lag!
        pcall(function() 
            sfx:Destroy()
            runConn:Disconnect()
            particlePart:Destroy()
        end)
        introGui:Destroy()
        if aoTerminar then aoTerminar() end
    end)
end

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
