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
-- FILTRO UNIVERSAL (V8.0 NATIVO)
-- ==========================================
local TIPOS_LIXO = {
    Color3Value = true, BrickColorValue = true, Vector3Value = true,
    CFrameValue = true, BoolValue = true, ObjectValue = true, RayValue = true
}

local LIXO_VISUAL = {
    "animate", "camera", "gui", "viewport", "worldmodel", "color",
    "size", "position", "transparency", "mesh", "texture", "decal", "sound"
}

local function isItemImportante(obj)
    -- 1. Corta tipos físicos/inúteis na raiz
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
    local nomeLower = obj.Name:lower()

    -- 3. BARRICADA ANTI-LIXO UNIVERSAL: Corta na raiz coisas visuais
    for _, lixo in ipairs(LIXO_VISUAL) do
        if string.find(caminhoLower, lixo) or string.find(nomeLower, lixo) then
            return false
        end
    end

    -- 4. CAPTURA DE OURO (Qualquer jogo)
    -- Se for um valor inteiro, número duplo ou string, nós mandamos pro Python julgar.
    -- O Python (V8.0) é ultra rápido e tem a inteligência heurística para separar o ouro.
    if obj:IsA("IntValue") or obj:IsA("NumberValue") or obj:IsA("StringValue") then
        return true
    end

    return false
end

-- ==========================================
-- VARREDURA FOCADA (AGORA UNIVERSAL E SEM DUPLICATAS)
-- ==========================================
local function iniciarVarredura()
    local dadosColetados = {}
    local nomesVistos = {} -- Tabela de rastreamento para bloquear variáveis duplicadas
    
    -- Agora varremos o LocalPlayer (leaderstats de 99% dos jogos) e o ReplicatedStorage
    local servicos = { LocalPlayer, game:GetService("ReplicatedStorage") }

    for _, serv in ipairs(servicos) do
        pcall(function()
            local descendentes = serv:GetDescendants()
            for i, obj in ipairs(descendentes) do
                if i % 500 == 0 then task.wait() end

                if obj:IsA("ValueBase") then
                    if isItemImportante(obj) then
                        -- REGRA DE BLOQUEIO: Se o nome já existe na nossa tabela, ignoramos.
                        -- Isso impede que "Money" em ReplicatedStorage e "Money" em leaderstats repitam no JSON.
                        if not nomesVistos[obj.Name] then
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
                            
                            -- Marca o nome como capturado para que a próxima duplicata seja ignorada
                            nomesVistos[obj.Name] = true
                        end
                    end
                end
            end
        end)
    end
    return dadosColetados
end

-- ==========================================
-- EXECUÇÃO PRINCIPAL (SEM PORTAS / APENAS ARQUIVO)
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

        if sucessoJson and writefile then
            local sucessoWrite = pcall(function()
                writefile(fileName, corpoJson)
            end)
            if not sucessoWrite then
                pcall(function() writefile(fallbackName, corpoJson) end)
            end
        end
        -- OBS: Comunicação via porta 127.0.0.1:5000 removida.
        -- Agora dependemos exclusivamente do Python vigiando o arquivo .json (Delta Watcher).
    end
end
