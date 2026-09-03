local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlaceId = tostring(game.PlaceId)

local folderName = "Hapieblox_Farm"
local fileName = folderName .. "/game_" .. PlaceId .. "_farm.json"
local fallbackName = "game_" .. PlaceId .. "_farm.json"
local QUATRO_DIAS_EM_SEGUNDOS = 4 * 24 * 60 * 60 -- 345.600 segundos

if isfolder and not isfolder(folderName) then
    pcall(function() makefolder(folderName) end)
end

-- ==========================================
-- SISTEMA DE CACHE
-- ==========================================
local function precisaAtualizar()
    if not isfile or not readfile then return true end

    local conteudo = nil
    if isfile(fileName) then
        pcall(function() conteudo = readfile(fileName) end)
    elseif isfile(fallbackName) then
        pcall(function() conteudo = readfile(fallbackName) end)
    end

    if conteudo then                                                                       
        local sucesso, dados = pcall(function()
            return HttpService:JSONDecode(conteudo)
        end)

        if sucesso and dados and dados.last_scan then
            local tempoPassado = os.time() - dados.last_scan
            if tempoPassado < QUATRO_DIAS_EM_SEGUNDOS then
                return false
            end
        end
    end

    return true
end

-- ==========================================
-- FILTRO "MODO DEUS" (V6.21 NATIVO)
-- ==========================================
local TIPOS_LIXO = {
    Color3Value = true, BrickColorValue = true, Vector3Value = true,
    CFrameValue = true, BoolValue = true, ObjectValue = true, RayValue = true
}

local function isItemImportante(obj)
    -- 1. Corta tipos inúteis na raiz
    if TIPOS_LIXO[obj.ClassName] then return false end

    -- 2. Filtro de Privacidade: Ignorar dados de OUTROS jogadores
    local localName = LocalPlayer and LocalPlayer.Name or ""
    local pai = obj.Parent
    while pai and pai ~= game do
        if pai.Name == localName then break end
        if pai:IsA("Player") and pai.Name ~= localName then return false end
        if pai.Name ~= localName and Players:FindFirstChild(pai.Name) then return false end
        pai = pai.Parent
    end

    local caminhoLower = obj:GetFullName():lower()

    -- 3. BARRICADA RESTRITA: Só passa o que for do ReplicatedStorage.Stats
    if string.find(caminhoLower, "replicatedstorage.stats") then
        
        -- 4. Ouro Puro: Moedas, Humor, Habilidades, Empregos, Coordenadas e Streak
        if string.find(caminhoLower, "money") or
           string.find(caminhoLower, "blockbux") or
           string.find(caminhoLower, "eventcurrency") or
           string.find(caminhoLower, "schoolcredits") or
           string.find(caminhoLower, "mooddata") or
           string.find(caminhoLower, "skilldata") or
           string.find(caminhoLower, "job") or
           string.find(caminhoLower, "coords") or
           string.find(caminhoLower, "visitstreak") then
            return true
        end
    end

    -- Removemos a regra antiga que deixava passar as GUIs (TVGui, Animações, etc)
    return false
end

-- ==========================================
-- VARREDURA FOCADA
-- ==========================================
local function iniciarVarredura()
    local dadosColetados = {}
    -- Focando a varredura apenas no ReplicatedStorage para otimização máxima de performance
    local servicos = { game:GetService("ReplicatedStorage") }

    for _, serv in ipairs(servicos) do
        pcall(function()
            local descendentes = serv:GetDescendants()
            for i, obj in ipairs(descendentes) do
                if i % 500 == 0 then task.wait() end

                if obj:IsA("ValueBase") then
                    if isItemImportante(obj) then
                        local valorSeguro = "nil"
                        pcall(function()
                            if obj.Value ~= nil then
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
            end
        end)
    end
    return dadosColetados
end

-- ==========================================
-- EXECUÇÃO PRINCIPAL
-- ==========================================
if precisaAtualizar() then
    local dados = iniciarVarredura()

    if #dados > 0 then
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
            if writefile then
                local sucessoWrite = pcall(function()
                    writefile(fileName, corpoJson)
                end)
                if not sucessoWrite then
                    pcall(function() writefile(fallbackName, corpoJson) end)
                end
            end

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
    end
end
