local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlaceId = tostring(game.PlaceId)

local folderName = "Hapieblox_Farm"
local fileName = folderName .. "/game_" .. PlaceId .. ".json"

-- Função para mandar notificação visual na tela do Roblox
local function notificar(titulo, texto)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = titulo,
            Text = texto,
            Duration = 5
        })
    end)
end

notificar("📡 Hapieblox Scanner", "Iniciando varredura no mapa...")

if isfolder and not isfolder(folderName) then
    pcall(function() makefolder(folderName) end)
end

local function iniciarVarredura()
    local dadosColetados = {}
    local servicos = { workspace, Players, game:GetService("ReplicatedStorage") }

    for _, serv in ipairs(servicos) do
        pcall(function()
            local descendentes = serv:GetDescendants()
            for i, obj in ipairs(descendentes) do
                if i % 1000 == 0 then task.wait() end -- Previne travamento
                
                -- AGORA BUSCA VALUEBASES, REMOTE EVENTS E REMOTE FUNCTIONS
                if obj:IsA("ValueBase") or obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                    local valorSeguro = "nil"
                    pcall(function()
                        if obj:IsA("ValueBase") and obj.Value ~= nil then 
                            valorSeguro = tostring(obj.Value) 
                        end
                    end)
                    
                    table.insert(dadosColetados, {
                        Nome = obj.Name,
                        Caminho = obj:GetFullName(),
                        Valor = valorSeguro,
                        Tipo = obj.ClassName
                    })
                end
            end
        end)
    end
    return dadosColetados
end

local dados = iniciarVarredura()
notificar("📡 Hapieblox Scanner", "Varredura concluída. Encontrados: " .. tostring(#dados) .. " itens.")

local payload = {
    place_id = PlaceId,
    player_name = LocalPlayer and LocalPlayer.Name or "Unknown",
    last_scan = os.time(),
    items_count = #dados,
    data = dados
}

local sucessoJson, corpoJson = pcall(function()
    return HttpService:JSONEncode(payload)
end)

if sucessoJson then
    -- AGORA ELE SALVA DE QUALQUER JEITO, ATÉ SE A LISTA FOR ZERO
    if writefile then
        local sucessoWrite, erroWrite = pcall(function()
            writefile(fileName, corpoJson)
        end)
        
        if sucessoWrite then
            notificar("✅ Sucesso!", "Arquivo salvo DENTRO da pasta Hapieblox_Farm!")
        else
            -- Se o executor bugar a pasta, salva solto na Workspace
            pcall(function()
                writefile("game_" .. PlaceId .. ".json", corpoJson)
            end)
            notificar("⚠️ Aviso", "Falha na pasta. Arquivo salvo solto na raiz do Workspace.")
        end
    else
        notificar("❌ Erro Crítico", "Seu executor não tem suporte a writefile!")
    end

    -- Tenta mandar pro Python (Opcional)
    local http_request = (syn and syn.request) or (http and http.request) or request
    if http_request then
        pcall(function()
            http_request({
                Url = "http://127.0.0.1:5000/request_data",
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = corpoJson
            })
        end)
    end
end
