local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title="Scanner V11 - Live Raw Mode",
        Text="Captura bruta em tempo real ativada e operando em segundo plano.",
        Duration=5
    })
end)

-- Tabelas Globais (Captura Viva)
local objetosValidos = {}
local dadosFiltradosParaEnvio = {}

-- Checa se é um item de valor cru e bruto
local function ehValido(objeto)
    return objeto:IsA("ValueBase")
end

local function registrarObjeto(obj)
    if ehValido(obj) then
        objetosValidos[obj] = true
    end
end

local function removerObjeto(obj)
    if objetosValidos[obj] then
        objetosValidos[obj] = nil
    end
end

-- ================= SCANNER DINÂMICO =================
-- Varredura Inicial Assíncrona (Não trava o jogo)
task.spawn(function()
    local servicos = { workspace, Players, game:GetService("ReplicatedStorage") }
    for _, serv in ipairs(servicos) do
        pcall(function()
            local descendentes = serv:GetDescendants()
            for i, obj in ipairs(descendentes) do
                if i % 1000 == 0 then task.wait() end -- Ler dinâmico sem travar
                registrarObjeto(obj)
            end
        end)
    end
end)

-- Eventos para manter a lista 100% atualizada em tempo real (Ao vivo)
game.DescendantAdded:Connect(registrarObjeto)
game.DescendantRemoving:Connect(removerObjeto)

-- ================= INTERFACE =================
local guiParent
pcall(function() if gethui then guiParent = gethui() else guiParent = game:GetService("CoreGui") end end)
if not guiParent then guiParent = LocalPlayer:WaitForChild("PlayerGui") end
if guiParent:FindFirstChild("ScannerMoneyGUI") then guiParent.ScannerMoneyGUI:Destroy() end

local tela = Instance.new("ScreenGui", guiParent)
tela.Name = "ScannerMoneyGUI"
local janela = Instance.new("Frame", tela)
janela.Size, janela.Position = UDim2.new(0, 700, 0, 500), UDim2.new(0.5, -350, 0.5, -250)
janela.BackgroundColor3, janela.Draggable, janela.Active = Color3.fromRGB(30, 30, 35), true, true

local titulo = Instance.new("TextLabel", janela)
titulo.Size, titulo.BackgroundTransparency = UDim2.new(1, -380, 0, 45), 1
titulo.Position = UDim2.new(0, 15, 0, 0)
titulo.Text = " 📡 Scanner Live (Modo Bruto)"
titulo.TextColor3, titulo.Font, titulo.TextSize = Color3.new(1,1,1), Enum.Font.GothamBold, 16
titulo.TextXAlignment = Enum.TextXAlignment.Left

-- BARRA DE PESQUISA (Para visualizar e filtrar o que será enviado)
local searchBar = Instance.new("TextBox", janela)
searchBar.Size, searchBar.Position = UDim2.new(1, -30, 0, 35), UDim2.new(0, 15, 0, 45)
searchBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
searchBar.TextColor3, searchBar.Font, searchBar.TextSize = Color3.fromRGB(200, 200, 200), Enum.Font.Gotham, 14
searchBar.PlaceholderText = " 🔎 Filtre o caminho ou nome que deseja visualizar/enviar..."
searchBar.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", searchBar).CornerRadius = UDim.new(0, 5)

-- Botoes Superiores
local btnIA = Instance.new("TextButton", janela)
btnIA.Size, btnIA.Position = UDim2.new(0, 140, 0, 32), UDim2.new(1, -410, 0, 7)
btnIA.BackgroundColor3, btnIA.Text = Color3.fromRGB(155, 89, 182), "🧠 Enviar Visualizado"
btnIA.TextColor3, btnIA.Font, btnIA.TextSize = Color3.new(1,1,1), Enum.Font.GothamBold, 11
Instance.new("UICorner", btnIA).CornerRadius = UDim.new(0, 5)

local btnSave = Instance.new("TextButton", janela)
btnSave.Size, btnSave.Position = UDim2.new(0, 110, 0, 32), UDim2.new(1, -260, 0, 7)
btnSave.BackgroundColor3, btnSave.Text = Color3.fromRGB(52, 152, 219), "💾 Salvar JSON"
btnSave.TextColor3, btnSave.Font, btnSave.TextSize = Color3.new(1,1,1), Enum.Font.GothamBold, 12
Instance.new("UICorner", btnSave).CornerRadius = UDim.new(0, 5)

local btnCopy = Instance.new("TextButton", janela)
btnCopy.Size, btnCopy.Position = UDim2.new(0, 100, 0, 32), UDim2.new(1, -140, 0, 7)
btnCopy.BackgroundColor3, btnCopy.Text = Color3.fromRGB(46, 204, 113), "📋 Copiar"
btnCopy.TextColor3, btnCopy.Font, btnCopy.TextSize = Color3.new(1,1,1), Enum.Font.GothamBold, 12
Instance.new("UICorner", btnCopy).CornerRadius = UDim.new(0, 5)

local btnFechar = Instance.new("TextButton", janela)
btnFechar.Size, btnFechar.Position = UDim2.new(0, 30, 0, 32), UDim2.new(1, -35, 0, 7)
btnFechar.BackgroundColor3, btnFechar.Text = Color3.fromRGB(231, 76, 60), "✕"
btnFechar.TextColor3, btnFechar.Font, btnFechar.TextSize = Color3.new(1,1,1), Enum.Font.GothamBold, 16
Instance.new("UICorner", btnFechar).CornerRadius = UDim.new(0, 5)
btnFechar.MouseButton1Click:Connect(function() tela:Destroy() end)

local scroll = Instance.new("ScrollingFrame", janela)
scroll.Size, scroll.Position = UDim2.new(1, -30, 1, -100), UDim2.new(0, 15, 0, 90)
scroll.BackgroundColor3, scroll.ScrollBarThickness = Color3.fromRGB(20, 20, 25), 6
local layout = Instance.new("UIListLayout", scroll)

-- Função central: Atualiza a lista da UI e prepara a tabela baseada na pesquisa do usuário
local function atualizarLista()
    local filtro = string.lower(searchBar.Text)
    
    -- Limpa interface
    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("TextLabel") then child:Destroy() end
    end

    -- Reseta os dados que serão exportados/enviados para o seu servidor
    dadosFiltradosParaEnvio = {}
    local count = 0

    for obj, _ in pairs(objetosValidos) do
        -- Proteção para caso o objeto suma subitamente do jogo
        if obj and obj.Parent then
            local caminho = obj:GetFullName()
            local nome = obj.Name
            local strBusca = string.lower(caminho)

            if filtro == "" or string.find(strBusca, filtro, 1, true) then
                count = count + 1
                
                -- Se passou no filtro, entra na lista de envio para sua API
                table.insert(dadosFiltradosParaEnvio, {
                    Nome = nome,
                    Caminho = caminho,
                    Valor = obj.Value,
                    Tipo = obj.ClassName
                })

                -- Limitador visual para não lagar a tela (mostra só os primeiros 150)
                if count <= 150 then
                    local item = Instance.new("TextLabel", scroll)
                    item.Size, item.BackgroundColor3 = UDim2.new(1, 0, 0, 28), (count % 2 == 0) and Color3.fromRGB(35, 35, 40) or Color3.fromRGB(25, 25, 30)
                    item.Text = string.format("  [%s] %s | Valor: %s", obj.ClassName, caminho, tostring(obj.Value))
                    item.TextColor3, item.Font, item.TextSize = Color3.fromRGB(150, 255, 150), Enum.Font.Code, 12
                    item.TextXAlignment, item.TextTruncate = Enum.TextXAlignment.Left, Enum.TextTruncate.AtEnd
                end
            end
        end
    end

    local textVis = count > 150 and " (Mostrando 150 de " .. count .. ")" or ""
    titulo.Text = " 📡 Scanner Live | Itens: " .. count .. textVis
    scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
end

searchBar:GetPropertyChangedSignal("Text"):Connect(atualizarLista)

-- Thread secundária: Atualiza o valor visual da tela periodicamente caso um valor cru mude
task.spawn(function()
    while tela and tela.Parent do
        task.wait(1.5)
        if not searchBar:IsFocused() then
            atualizarLista()
        end
    end
end)

-- ================= FUNÇÕES DE ENVIO / BOTÕES =================
btnIA.MouseButton1Click:Connect(function()
    if #dadosFiltradosParaEnvio == 0 then
        btnIA.Text = "❌ Lista Vazia"
        task.wait(1)
        btnIA.Text = "🧠 Enviar Visualizado"
        return
    end

    btnIA.Text = "⏳ Enviando..."
    pcall(function()
        local http_request = (syn and syn.request) or (http and http.request) or request
        if http_request then
            local jsonString = HttpService:JSONEncode(dadosFiltradosParaEnvio)
            local resposta = http_request({
                Url = "http://1.2.3.4:5000/analisar",
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = jsonString
            })
            if resposta.StatusCode == 200 then
                btnIA.Text = "✅ Enviado!"
                btnIA.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
            else
                btnIA.Text = "❌ Erro Servidor"
            end
        else
            btnIA.Text = "❌ Executor Fraco"
        end
    end)
    task.wait(2)
    btnIA.Text = "🧠 Enviar Visualizado"
    btnIA.BackgroundColor3 = Color3.fromRGB(155, 89, 182)
end)

btnSave.MouseButton1Click:Connect(function()
    pcall(function()
        if writefile then
            writefile("Hapieblox_Live_Dump.json", HttpService:JSONEncode(dadosFiltradosParaEnvio))
            btnSave.Text = "✅ Salvo!"
            task.wait(2)
            btnSave.Text = "💾 Salvar JSON"
        end
    end)
end)

btnCopy.MouseButton1Click:Connect(function()
    pcall(function()
        if setclipboard then
            setclipboard(HttpService:JSONEncode(dadosFiltradosParaEnvio))
            btnCopy.Text = "✅ Copiado!"
            task.wait(2)
            btnCopy.Text = "📋 Copiar"
        end
    end)
end)

-- Chamada inicial para preencher a tela
atualizarLista()
