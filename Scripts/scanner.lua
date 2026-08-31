local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local meuNome = LocalPlayer.Name

local statsEncontrados = {}
local objetosTemporarios = {}
local contagemNomes = {}
local dadosParaLLM = {}

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title="Scanner V10 - Bridge Ativa",
        Text="Conectando com o servidor Python local...",
        Duration=5
    })
end)

local palavrasBloqueadas = {
    "animate", "animation", "scale", "bodytype", "bodywidth", "bodyheight", "bodydepth", "headscale", "proportion",
    "timestamp", "timeplayed", "lasttime", "installdate", "lastviewed", "timestarted", "timeleft", "cooldown", "date", "session",
    "setting", "config", "shadow", "quality", "volume", "camera", "blur", "render", "preset", "fov", "music", "audio", "graphic", "progress",
    "cell", "minspawn", "maxspawn", "radio", "station", "avg", "tp", "teleport",
    "vehicles", "numtimessold", "customization", "materials", "cratespins", "premiumspins", "grouprank", "roleepayoutdate", "robuxinstalldate",
    "settings", "advertisements", "join", "vehiclespawncount", "totalrefundamount", "jobsstars", "houseaccesspermission", "chatags",
    "house", "weather", "mam", "packremaining", "delaney"
}

local function ehValido(objeto)
    if not (objeto:IsA("IntValue") or objeto:IsA("NumberValue") or objeto:IsA("DoubleValue")) then return false end
    local caminho = string.lower(objeto:GetFullName())
    
    for _, p in ipairs(palavrasBloqueadas) do 
        if string.find(caminho, p) then return false end 
    end
    
    for _, p in ipairs(Players:GetPlayers()) do 
        if p.Name ~= meuNome and string.find(objeto:GetFullName(), p.Name, 1, true) then 
            return false 
        end 
    end
    
    return true
end

local servicos = { game:GetService("Workspace"), game:GetService("Players"), game:GetService("ReplicatedStorage") }

for _, serv in ipairs(servicos) do
    pcall(function()
        for i, obj in ipairs(serv:GetDescendants()) do
            if i % 1500 == 0 then task.wait() end
            if ehValido(obj) then
                contagemNomes[obj.Name] = (contagemNomes[obj.Name] or 0) + 1
                table.insert(objetosTemporarios, obj)
            end
        end
    end)
end

for _, obj in ipairs(objetosTemporarios) do
    if contagemNomes[obj.Name] <= 5 then
        table.insert(statsEncontrados, string.format("[STAT] %s | Valor: %s", obj:GetFullName(), tostring(obj.Value)))
        table.insert(dadosParaLLM, { Nome = obj.Name, Caminho = obj:GetFullName(), Valor = obj.Value, Tipo = obj.ClassName })
    end
end

-- ================= INTERFACE =================
local guiParent
pcall(function() if gethui then guiParent = gethui() else guiParent = game:GetService("CoreGui") end end)
if not guiParent then guiParent = LocalPlayer:WaitForChild("PlayerGui") end
if guiParent:FindFirstChild("ScannerMoneyGUI") then guiParent.ScannerMoneyGUI:Destroy() end

local tela = Instance.new("ScreenGui", guiParent)
tela.Name = "ScannerMoneyGUI"
local janela = Instance.new("Frame", tela)
janela.Size, janela.Position = UDim2.new(0, 700, 0, 450), UDim2.new(0.5, -350, 0.5, -225)
janela.BackgroundColor3, janela.Draggable, janela.Active = Color3.fromRGB(30, 30, 35), true, true

local titulo = Instance.new("TextLabel", janela)
titulo.Size, titulo.BackgroundTransparency = UDim2.new(1, -380, 0, 45), 1
titulo.Position = UDim2.new(0, 15, 0, 0)
titulo.Text = " 🚀 Ouro Encontrado: " .. #statsEncontrados
titulo.TextColor3, titulo.Font, titulo.TextSize = Color3.new(1,1,1), Enum.Font.GothamBold, 16
titulo.TextXAlignment = Enum.TextXAlignment.Left

local btnIA = Instance.new("TextButton", janela)
btnIA.Size, btnIA.Position = UDim2.new(0, 120, 0, 32), UDim2.new(1, -390, 0, 7)
btnIA.BackgroundColor3, btnIA.Text = Color3.fromRGB(155, 89, 182), "🧠 Enviar p/ Termux"
btnIA.TextColor3, btnIA.Font, btnIA.TextSize = Color3.new(1,1,1), Enum.Font.GothamBold, 12
Instance.new("UICorner", btnIA).CornerRadius = UDim.new(0, 5)

btnIA.MouseButton1Click:Connect(function()
    btnIA.Text = "⏳ Enviando..."
    pcall(function()
        local http_request = (syn and syn.request) or (http and http.request) or request
        if http_request then
            local jsonString = HttpService:JSONEncode(dadosParaLLM)
            local resposta = http_request({
                -- A MÁGICA ACONTECE AQUI: O IP FALSO DO IPTABLES
                Url = "http://1.2.3.4:5000/analisar",
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = jsonString
            })
            if resposta.StatusCode == 200 then
                btnIA.Text = "✅ Recebido!"
                btnIA.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
            else
                btnIA.Text = "❌ Erro Servidor"
            end
        else
            btnIA.Text = "❌ Executor Fraco"
        end
    end)
    task.wait(2)
    btnIA.Text = "🧠 Enviar p/ Termux"
    btnIA.BackgroundColor3 = Color3.fromRGB(155, 89, 182)
end)

local btnSave = Instance.new("TextButton", janela)
btnSave.Size, btnSave.Position = UDim2.new(0, 110, 0, 32), UDim2.new(1, -260, 0, 7)
btnSave.BackgroundColor3, btnSave.Text = Color3.fromRGB(52, 152, 219), "💾 Salvar JSON"
btnSave.TextColor3, btnSave.Font, btnSave.TextSize = Color3.new(1,1,1), Enum.Font.GothamBold, 12
Instance.new("UICorner", btnSave).CornerRadius = UDim.new(0, 5)

btnSave.MouseButton1Click:Connect(function() 
    pcall(function() 
        if writefile then 
            writefile("Hapieblox_Dump.json", HttpService:JSONEncode(dadosParaLLM)) 
            btnSave.Text = "✅ Salvo!" 
            task.wait(2) 
            btnSave.Text = "💾 Salvar JSON" 
        end 
    end) 
end)

local btnCopy = Instance.new("TextButton", janela)
btnCopy.Size, btnCopy.Position = UDim2.new(0, 100, 0, 32), UDim2.new(1, -140, 0, 7)
btnCopy.BackgroundColor3, btnCopy.Text = Color3.fromRGB(46, 204, 113), "📋 Copiar"
btnCopy.TextColor3, btnCopy.Font, btnCopy.TextSize = Color3.new(1,1,1), Enum.Font.GothamBold, 12
Instance.new("UICorner", btnCopy).CornerRadius = UDim.new(0, 5)

btnCopy.MouseButton1Click:Connect(function() 
    pcall(function() 
        if setclipboard then
            setclipboard(HttpService:JSONEncode(dadosParaLLM)) 
            btnCopy.Text = "✅ Copiado!" 
            task.wait(2) 
            btnCopy.Text = "📋 Copiar" 
        end
    end) 
end)

local btnFechar = Instance.new("TextButton", janela)
btnFechar.Size, btnFechar.Position = UDim2.new(0, 30, 0, 32), UDim2.new(1, -35, 0, 7)
btnFechar.BackgroundColor3, btnFechar.Text = Color3.fromRGB(231, 76, 60), "✕"
btnFechar.TextColor3, btnFechar.Font, btnFechar.TextSize = Color3.new(1,1,1), Enum.Font.GothamBold, 16
Instance.new("UICorner", btnFechar).CornerRadius = UDim.new(0, 5)
btnFechar.MouseButton1Click:Connect(function() tela:Destroy() end)

local scroll = Instance.new("ScrollingFrame", janela)
scroll.Size, scroll.Position = UDim2.new(1, -20, 1, -60), UDim2.new(0, 10, 0, 50)
scroll.BackgroundColor3, scroll.ScrollBarThickness = Color3.fromRGB(20, 20, 25), 6
local layout = Instance.new("UIListLayout", scroll)

for i, res in ipairs(statsEncontrados) do
    local item = Instance.new("TextLabel", scroll)
    item.Size, item.BackgroundColor3 = UDim2.new(1, 0, 0, 28), (i % 2 == 0) and Color3.fromRGB(35, 35, 40) or Color3.fromRGB(25, 25, 30)
    item.Text, item.TextColor3, item.Font, item.TextSize = "  " .. res, Color3.fromRGB(150, 255, 150), Enum.Font.Code, 13
    item.TextXAlignment, item.TextTruncate = Enum.TextXAlignment.Left, Enum.TextTruncate.AtEnd
end

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
end)
scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
