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
-- SISTEMA DE CACHE BLINDADO
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
-- FILTRO ESTRUTURAL SUPER RIGOROSO (A NATA DA COISA)
-- ==========================================

-- Tipos que NUNCA serão dinheiro/nível. Cortamos na raiz.
local TIPOS_LIXO = {
    Color3Value = true,      -- Cores
    BrickColorValue = true,  -- Cores de blocos
    Vector3Value = true,     -- Posições 3D
    CFrameValue = true,      -- Rotações/Posições
    BoolValue = true,        -- Verdadeiro/Falso (IsLoaded, IsSaving)
    ObjectValue = true,      -- Referências a partes do mapa
    RayValue = true          -- Lasers/Física
}

-- Palavras no nome que indicam lixo visual ou de configuração
local PALAVRAS_LIXO = {
    "color", "size", "position", "scale", "offset", "transparency",
    "rotation", "weight", "animate", "title", "text", "image",
    "sound", "volume", "camera", "layout", "stroke", "corner",
    "effect", "loading", "saving", "message", "viewport", "shadow"
}

local function isItemImportante(obj)
    -- 1. BARRADO NA PORTA: É um tipo de valor visual/físico? Lixo!
    if TIPOS_LIXO[obj.ClassName] then return false end

    local nomeLower = obj.Name:lower()

    -- 2. BARRADO NO NOME: Tem nome de configuração de tela? Lixo!
    for _, palavra in ipairs(PALAVRAS_LIXO) do
        if string.find(nomeLower, palavra) then
            return false
        end
    end

    -- [NOVO] 3. FILTRO DE PRIVACIDADE: Ignorar dados de OUTROS jogadores
    local localName = LocalPlayer and LocalPlayer.Name or ""
    local pai = obj.Parent
    while pai and pai ~= game do
        -- Se estiver dentro da nossa própria pasta, está seguro.
        if pai.Name == localName then
            break
        end
        
        -- Se for um "Player" e não formos nós, lixo!
        if pai:IsA("Player") and pai.Name ~= localName then
            return false
        end
        
        -- Se a pasta tem o nome de OUTRO jogador que está no servidor (ex: ReplicatedStorage.Stats.catloverforever2094), lixo!
        if pai.Name ~= localName and Players:FindFirstChild(pai.Name) then
            return false
        end
        
        pai = pai.Parent
    end

    local caminhoLower = obj:GetFullName():lower()

    -- 4. PASSAPORTE VIP: Se estiver nas pastas de status/data, é ouro puro.
    if string.find(caminhoLower, "leaderstats") or
       string.find(caminhoLower, "playerdata") or
       string.find(caminhoLower, "stats") or
       string.find(caminhoLower, "currency") then
        return true
    end

    -- 5. REGRA DA INTERFACE (GUI): Só passa se sobreviveu aos filtros anteriores.
    pai = obj.Parent
    while pai and pai ~= game do
        if pai:IsA("ScreenGui") or pai:IsA("SurfaceGui") or pai:IsA("BillboardGui") or pai:IsA("PlayerGui") or pai:IsA("StarterGui") then
            return true
        end
        pai = pai.Parent
    end

    return false
end

-- ==========================================
-- VARREDURA FOCADA NO FARM
-- ==========================================
local function iniciarVarredura()
    local dadosColetados = {}
    local servicos = { workspace, Players, game:GetService("ReplicatedStorage") }

    for _, serv in ipairs(servicos) do
        pcall(function()
            local descendentes = serv:GetDescendants()
            for i, obj in ipairs(descendentes) do
                if i % 1000 == 0 then task.wait() end

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
