local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
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
end
limparTudo()

-- ==========================================
-- SISTEMA DE ÁUDIO GLOBAL
-- ==========================================
local function tocarSFX(id, vol, pitch)
    task.spawn(function()
        local snd = Instance.new("Sound")
        snd.SoundId = "rbxassetid://" .. tostring(id)
        snd.Volume = vol or 1
        snd.PlaybackSpeed = pitch or 1
        snd.Parent = SoundService
        snd:Play()
        snd.Ended:Wait()
        snd:Destroy()
    end)
end

-- ==========================================
-- SISTEMA DE MEMÓRIA & CONFIGURAÇÕES (JSON)
-- ==========================================
local arqConfig = "Hapieblox_Config.json"
local arqAutoLoad = "Hapieblox_AutoLoad.json"

local function carregarConfig()
    local padrao = {
        atived = false,
        execucoes = 0,
        ultimaSessao = "Nunca",
        auto_loading = false,
        money_target = false
    }

    if isfile and readfile and pcall(function() isfile(arqConfig) end) and isfile(arqConfig) then
        local sucesso, dados = pcall(function()
            return HttpService:JSONDecode(readfile(arqConfig))
        end)
        if sucesso and dados then
            for k, v in pairs(padrao) do
                if dados[k] == nil then dados[k] = v end
            end
            return dados
        end
    end
    return padrao
end

local config = carregarConfig()

-- ==========================================
-- 🛑 TRAVA DE SEGURANÇA (KILL SWITCH) 🛑
-- ==========================================
if not config.atived then
    -- Som tech grave indicando "Sistema Desligado"
    tocarSFX(2811444158, 0.8, 0.6) 
    
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "⏸️ Hapieblox Standby",
            Text = "Modo Farm desativado. Nenhuma automação será carregada.",
            Duration = 5
        })
    end)
    -- Mata o script instantaneamente
    return 
end

-- ==========================================
-- SE PASSOU DA TRAVA, O SCRIPT ESTÁ ATIVO
-- ==========================================
local function salvarConfig(dados)
    if writefile then
        pcall(function() writefile(arqConfig, HttpService:JSONEncode(dados)) end)
    end
end

config.execucoes = config.execucoes + 1
config.ultimaSessao = os.date("%d/%m/%Y %H:%M")
salvarConfig(config)

local function carregarAutoLoad()
    local padrao = { ALL = {}, Games = {} }

    if isfile and readfile and pcall(function() isfile(arqAutoLoad) end) and isfile(arqAutoLoad) then
        local sucesso, dados = pcall(function()
            return HttpService:JSONDecode(readfile(arqAutoLoad))
        end)
        if sucesso and dados then
            if not dados.ALL then dados.ALL = {} end
            if not dados.Games then dados.Games = {} end
            return dados
        end
    end
    if writefile then pcall(function() writefile(arqAutoLoad, HttpService:JSONEncode(padrao)) end) end
    return padrao
end

-- ==========================================
-- SISTEMA ANTI-AFK
-- ==========================================
local function iniciarAntiAFK()
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end
task.spawn(iniciarAntiAFK)

-- ==========================================
-- SISTEMA DE AUTO-INJECT
-- ==========================================
local function auto_inject()
    if not config.auto_loading then return end

    local autoData = carregarAutoLoad()
    local currentPlaceId = tostring(game.PlaceId)
    local globaisInjetados = 0
    local locaisInjetados = 0

    if type(autoData.ALL) == "table" then
        for _, scriptCode in ipairs(autoData.ALL) do
            task.spawn(function()
                local func, err = loadstring(scriptCode)
                if func then pcall(func) else warn("[Hapieblox] Erro no Script Global: ", tostring(err)) end
            end)
            globaisInjetados = globaisInjetados + 1
        end
    end

    if type(autoData.Games) == "table" and type(autoData.Games[currentPlaceId]) == "table" then
        for _, scriptCode in ipairs(autoData.Games[currentPlaceId]) do
            task.spawn(function()
                local func, err = loadstring(scriptCode)
                if func then pcall(func) else warn("[Hapieblox] Erro no Script Local: ", tostring(err)) end
            end)
            locaisInjetados = locaisInjetados + 1
        end
    end

    if globaisInjetados > 0 or locaisInjetados > 0 then
        task.spawn(function()
            task.wait(2)
            -- Som tech agudo indicando "Sistema Online e Injetado"
            tocarSFX(2811444158, 0.8, 1.2)
            
            pcall(function()
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "💉 Hapieblox Inject",
                    Text = string.format("Injetados:\n🌍 %d Globais\n📍 %d Locais", globaisInjetados, locaisInjetados),
                    Duration = 6
                })
            end)
        end)
    end
end

-- ==========================================
-- EFEITOS VISUAIS DA INTRO
-- ==========================================
local originalTransparencies = {}
local function sumirComJogadores()
    originalTransparencies = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            for _, part in ipairs(plr.Character:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("Decal") or part:IsA("Texture") then
                    if part.Name ~= "HumanoidRootPart" then
                        originalTransparencies[part] = part.Transparency
                        TweenService:Create(part, TweenInfo.new(0.3), {Transparency = 1}):Play()
                    end
                end
            end
        end
    end
end

local function revelarJogadores()
    for part, originalTrans in pairs(originalTransparencies) do
        if part and part.Parent then
            TweenService:Create(part, TweenInfo.new(2.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Transparency = originalTrans}):Play()
        end
    end
end

-- ==========================================
-- INTRO V15.0
-- ==========================================
local function tocarIntro(aoTerminar)
    if guiParent:FindFirstChild("HapiebloxIntro") then guiParent.HapiebloxIntro:Destroy() end

    local introGui = Instance.new("ScreenGui")
    introGui.Name = "HapiebloxIntro"
    introGui.ResetOnSpawn = false
    introGui.IgnoreGuiInset = true
    introGui.Parent = guiParent

    sumirComJogadores()

    local cam = workspace.CurrentCamera
    local particlePart = Instance.new("Part")
    particlePart.Size = Vector3.new(1, 1, 1)
    particlePart.Transparency = 1
    particlePart.Anchored = true
    particlePart.CanCollide = false
    particlePart.Parent = cam

    local pe1 = Instance.new("ParticleEmitter")
    pe1.Texture = "rbxassetid://243660364"
    pe1.LightEmission = 1
    pe1.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, 255, 200),
        ColorSequenceKeypoint.new(0.5, 255, 255),
        ColorSequenceKeypoint.new(1, 0, 150, 255)
    })
    pe1.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.5, 2), NumberSequenceKeypoint.new(1, 0)})
    pe1.Rate = 0; pe1.Speed = NumberRange.new(25, 60); pe1.Lifetime = NumberRange.new(1.2, 2.5)
    pe1.SpreadAngle = Vector2.new(180, 180); pe1.Parent = particlePart

    local runConn = RunService.RenderStepped:Connect(function()
        particlePart.CFrame = cam.CFrame * CFrame.new(0, 0, -12)
    end)

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
    brilho.ImageColor3 = Color3.fromRGB(0, 200, 255)
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
        pe1:Emit(300)
        tocarSFX(134012322, 1.2, 1.3)

        TweenService:Create(brilho, TweenInfo.new(0.8, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 700, 0, 700), ImageTransparency = 0.4
        }):Play()

        for i = 1, 35 do
            task.spawn(function()
                local part = Instance.new("Frame")
                local pSize = math.random(6, 14)
                part.Size = UDim2.new(0, pSize, 0, pSize)
                part.Position = UDim2.new(math.random(5, 95)/100, 0, 1.2, 0)
                part.BackgroundColor3 = math.random(1, 2) == 1 and Color3.fromRGB(0, 255, 200) or Color3.fromRGB(0, 150, 255)
                local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 2); corner.Parent = part
                part.Parent = introGui

                local tInfo = TweenInfo.new(math.random(15, 30)/10, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
                local tw = TweenService:Create(part, tInfo, {
                    Position = UDim2.new(part.Position.X.Scale + (math.random(-10, 10)/100), 0, math.random(10, 60)/100, 0),
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 0, 0, 0)
                })
                tw:Play()
                tw.Completed:Connect(function() part:Destroy() end)
            end)
            task.wait(0.01)
        end

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
                lbl.TextColor3 = Color3.fromRGB(240, 240, 250)
                lbl.Parent = charWrap

                local str = Instance.new("UIStroke")
                str.Color = Color3.fromRGB(0, 200, 255)
                str.Thickness = 3
                str.Parent = lbl

                task.spawn(function()
                    TweenService:Create(lbl, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                        TextSize = fontSize,
                        Position = UDim2.new(0, 0, 0, 0)
                    }):Play()
                    tocarSFX(8777977699, 0.8, math.random(80, 140)/100)
                end)
            end
            task.wait(0.03)
        end

        local function criarTechIcon(emoji, pos, rotacao, tamanhoFinal, delayAparecer)
            task.delay(delayAparecer, function()
                local lbl = Instance.new("TextLabel")
                lbl.BackgroundTransparency = 1
                lbl.Text = emoji
                lbl.TextSize = 0
                lbl.Rotation = rotacao - 40
                lbl.Position = pos
                lbl.Font = Enum.Font.Code
                lbl.Parent = center

                local anim = TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                TweenService:Create(lbl, anim, {TextSize = tamanhoFinal, Rotation = rotacao}):Play()
                tocarSFX(2811444158, 0.5, 1.5)
            end)
        end

        criarTechIcon("</>", UDim2.new(0.83, 0, 0.22, 0), 10, 32, 0.1)
        criarTechIcon("⚡", UDim2.new(0.78, 0, -0.05, 0), -15, 38, 0.2)
        criarTechIcon("🤖", UDim2.new(0.12, 0, 0.15, 0), -10, 35, 0.3)
        criarTechIcon("💻", UDim2.new(0.18, 0, 0.8, 0), 15, 35, 0.4)
        criarTechIcon("🛡️", UDim2.new(0.07, 0, 0.52, 0), -5, 32, 0.5)
        criarTechIcon("⚙️", UDim2.new(0.88, 0, 0.72, 0), 25, 36, 0.6)

        task.wait(2.0)
        revelarJogadores()

        tocarSFX(300976136, 1, 1)

        local fadeInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(brilho, fadeInfo, {ImageTransparency = 1, Size = UDim2.new(0, 800, 0, 800)}):Play()

        for _, wrap in ipairs(textContainer:GetChildren()) do
            if wrap:IsA("Frame") then
                for _, obj in ipairs(wrap:GetChildren()) do
                    if obj:IsA("TextLabel") then
                        TweenService:Create(obj, fadeInfo, {TextTransparency = 1, Position = UDim2.new(0, 0, -0.3, 0)}):Play()
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

        task.wait(0.5)
        pcall(function()
            runConn:Disconnect()
            particlePart:Destroy()
        end)
        introGui:Destroy()

        if aoTerminar then aoTerminar() end
    end)
end

-- Roda a intro inicial
tocarIntro()

-- ==========================================
-- GATILHO DAS AUTOMAÇÕES
-- ==========================================
task.spawn(auto_inject)

if config.money_target then
    task.spawn(function()
        local http_request = (syn and syn.request) or (http and http.request) or request
        if http_request then
            while task.wait(10) do
                pcall(function()
                    local resposta = http_request({
                        Url = "http://1.2.3.4:5000/check_task",
                        Method = "GET"
                    })
                    if resposta.StatusCode == 200 then
                        local taskData = HttpService:JSONDecode(resposta.Body)
                        if taskData and taskData.action == "run_scanner" then
                            loadstring(game:HttpGet(rawScannerUrl .. "?t=" .. tostring(tick())))()
                        end
                    end
                end)
            end
        end
    end)
end

-- ==========================================
-- AUTO-UPDATER
-- ==========================================
task.spawn(function()
    while true do
        task.wait(15)
        pcall(function()
            local req = game:HttpGet(versionUrl .. "?t=" .. tostring(tick()))
            local data = HttpService:JSONDecode(req)
            if data and data.version and data.version ~= currentVersion then
                tocarSFX(2865228021, 1, 1)
                game:GetService("StarterGui"):SetCore("SendNotification", {Title="🔥 Update", Text="Nova versão detectada! Atualizando...", Duration=4})
                task.wait(1.5)
                limparTudo()
                loadstring(game:HttpGet(rawMainUrl .. "?t=" .. tostring(tick())))()
            end
        end)
    end
end)
