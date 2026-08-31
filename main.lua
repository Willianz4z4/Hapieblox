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
-- INTRO V4.0 (3D PARTICLES, STARBURST & RESPONSIVO)
-- ==========================================
local function tocarIntro(aoTerminar)
    if guiParent:FindFirstChild("HapiebloxIntro") then guiParent.HapiebloxIntro:Destroy() end

    local introGui = Instance.new("ScreenGui")
    introGui.Name = "HapiebloxIntro"
    introGui.ResetOnSpawn = false
    introGui.IgnoreGuiInset = true
    introGui.Parent = guiParent

    -- 1. Efeito 3D no Mapa (Emissor de Partículas na Câmera)
    local cam = workspace.CurrentCamera
    local particlePart = Instance.new("Part")
    particlePart.Size = Vector3.new(1, 1, 1)
    particlePart.Transparency = 1
    particlePart.Anchored = true
    particlePart.CanCollide = false
    particlePart.Parent = cam

    local pe = Instance.new("ParticleEmitter")
    pe.Texture = "rbxassetid://243660364" -- Textura de faísca/estrela do Roblox
    pe.LightEmission = 1
    pe.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 150, 200)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 150, 255))
    })
    pe.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.5, 1.5), NumberSequenceKeypoint.new(1, 0)})
    pe.Rate = 0
    pe.Speed = NumberRange.new(10, 25)
    pe.Lifetime = NumberRange.new(1, 2)
    pe.SpreadAngle = Vector2.new(180, 180)
    pe.Parent = particlePart

    -- Mantém a partícula na frente da câmera do jogador
    local runConn = RunService.RenderStepped:Connect(function()
        particlePart.CFrame = cam.CFrame * CFrame.new(0, 0, -8) -- 8 blocos na frente da câmera
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
    brilho.ImageColor3 = Color3.fromRGB(255, 150, 220)
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
    layout.Padding = UDim.new(0, 0) -- Sem padding pra caber na tela do celular
    layout.Parent = textContainer

    task.spawn(function()
        task.wait(0.3) 
        
        -- Dispara as partículas 3D no mapa!
        pe:Emit(80) 

        -- Animação do Brilho 2D pulsante
        TweenService:Create(brilho, TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 600, 0, 600),
            ImageTransparency = 0.4
        }):Play()

        -- Explosão Circular de Estrelas UI (Matemática Pura)
        for i = 1, 12 do
            local star = Instance.new("TextLabel")
            star.Text = "⭐"
            star.BackgroundTransparency = 1
            star.Size = UDim2.new(0, 30, 0, 30)
            star.AnchorPoint = Vector2.new(0.5, 0.5)
            star.Position = UDim2.new(0.5, 0, 0.5, 0)
            star.TextSize = 25
            star.Parent = center

            -- Calcula a posição em círculo
            local angle = math.rad((i / 12) * 360)
            local raioX = 150 * math.cos(angle)
            local raioY = 150 * math.sin(angle)

            local tweenStar = TweenService:Create(star, TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Position = UDim2.new(0.5, raioX, 0.5, raioY),
                TextSize = 0,
                Rotation = math.random(180, 360)
            })
            tweenStar:Play()
            tweenStar.Completed:Connect(function() star:Destroy() end)
        end

        -- Texto Bounce Redimensionado para Celular
        local textoReal = "HapieBlox Script"
        local fontSize = 38 -- Menor para caber no celular
        
        for i = 1, #textoReal do
            local char = string.sub(textoReal, i, i)
            local charWrap = Instance.new("Frame")
            -- Caixas menores para telas mobile
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

        task.wait(2.5)

        -- Fade Out Limpo
        local fadeInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(brilho, fadeInfo, {ImageTransparency = 1, Size = UDim2.new(0, 800, 0, 800)}):Play()
        
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

        task.wait(0.6)
        
        -- Limpeza
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
