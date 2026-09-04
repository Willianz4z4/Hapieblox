local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlaceId = tostring(game.PlaceId)

local folderName = "Hapieblox_Farm"
local fileName = folderName .. "/game_" .. PlaceId .. "_farm.json"
local fallbackName = "game_" .. PlaceId .. "_farm.json"
local targetFolder = folderName .. "/targets_active"
local targetFile = targetFolder .. "/" .. PlaceId .. ".json"

local QUATRO_DIAS_EM_SEGUNDOS = 4 * 24 * 60 * 60 -- 345.600 segundos

if isfolder and not isfolder(folderName) then
    pcall(function() makefolder(folderName) end)
end
if isfolder and not isfolder(targetFolder) then
    pcall(function() makefolder(targetFolder) end)
end

-- ==========================================
-- SISTEMA DE MÁSCARA CURINGA [LOCAL_PLAYER]
-- ==========================================
local function substituirTextoSeguro(str, find, replace)
    if not find or find == "" or not str then return str end
    local s = ""
    local startIdx = 1
    while true do
        local findStart, findEnd = str:find(find, startIdx, true)
        if not findStart then
            s = s .. str:sub(startIdx)
            break
        end
        s = s .. str:sub(startIdx, findStart - 1) .. replace
        startIdx = findEnd + 1
    end
    return s
end

local function mascararCaminho(caminho)
    local str = caminho
    if LocalPlayer and LocalPlayer.Name and LocalPlayer.Name ~= "" then
        str = substituirTextoSeguro(str, LocalPlayer.Name, "[LOCAL_PLAYER]")
    end
    if LocalPlayer and LocalPlayer.UserId then
        str = substituirTextoSeguro(str, tostring(LocalPlayer.UserId), "[LOCAL_USER_ID]")
    end
    return str
end

local function desmascararCaminho(caminho)
    local str = caminho
    if LocalPlayer and LocalPlayer.Name then
        str = substituirTextoSeguro(str, "[LOCAL_PLAYER]", LocalPlayer.Name)
    end
    if LocalPlayer and LocalPlayer.UserId then
        str = substituirTextoSeguro(str, "[LOCAL_USER_ID]", tostring(LocalPlayer.UserId))
    end
    return str
end

local function precisaAtualizar()
    if not isfile or not readfile then return true end
    local conteudo = nil
    if isfile(fileName) then
        pcall(function() conteudo = readfile(fileName) end)
    elseif isfile(fallbackName) then
        pcall(function() conteudo = readfile(fallbackName) end)
    end

    if conteudo then
        local sucesso, dados = pcall(function() return HttpService:JSONDecode(conteudo) end)
        if sucesso and dados and dados.last_scan then
            if os.time() - dados.last_scan < QUATRO_DIAS_EM_SEGUNDOS then
                return false
            end
        end
    end
    return true
end

-- ==========================================
-- FILTRO SUPREMO PARA A INTERFACE
-- ==========================================
local TIPOS_LIXO = {
    Color3Value = true, BrickColorValue = true, Vector3Value = true,
    CFrameValue = true, BoolValue = true, ObjectValue = true, RayValue = true
}

local LIXO_CAMINHO = {
    "animate", "camera", "viewport", "worldmodel", "mesh", "texture", "decal", "sound",
    "resources", "placetype", "gitinfo", "debug", "tvgui", "options", "appearance",
    "privateserver", "houses", "billholder", "inventory", "jointime", "hospital",
    "towing", "version", "guidelines", "timestamp", "log", "settings", "profile",
    "loading", "visualmoney", "visualblockbux", "playerscripts", "hudhandler",
    "tutorial", "testerwatermark", "easter", "aprilfools", "duck", "ikea",
    "rewardtime", "trophy", "reminder", "badge", "coregui", "startergui",
    "assetload", "ailments", "ambiance", "avatareditor", "dailiesapp", "backpack",
    "focuspet", "subscription", "milestone", "taxidestination", "tradeapp",
    "taxitimer", "mannequin", "petrecycler", "journalapp", "paintinventory",
    "toolapp", "screentap", "roleplaypay", "promos", "dialog", "ftue", "friend",
    "news", "party", "performance", "peopleinside", "minigame", "jackbox",
    "housepurchase", "merch", "radio", "surfacegui"
}

local LIXO_NOME = {
    "color", "size", "position", "transparency", "visible", "zindex", "layoutorder",
    "cheer", "climb", "dance", "fall", "idle", "jump", "laugh", "run", "swim", "walk",
    "accessoryscale", "placesubtype"
}

local function obterValorSeguro(obj)
    if obj:IsA("TextLabel") or obj:IsA("TextButton") then
        return obj.Text
    end
    return tostring(obj.Value)
end

local function isItemImportante(obj)
    if TIPOS_LIXO[obj.ClassName] then return false end

    local localName = LocalPlayer and LocalPlayer.Name or ""
    local localUserId = LocalPlayer and tostring(LocalPlayer.UserId) or ""
    local pai = obj.Parent

    while pai and pai ~= game do
        if pai.Name == localName or pai.Name == localUserId then break end
        if pai:IsA("Player") and pai.Name ~= localName then return false end
        if Players:FindFirstChild(pai.Name) and pai.Name ~= localName then return false end
        if pai:IsA("Model") and pai:FindFirstChildOfClass("Humanoid") and pai.Name ~= localName then return false end
        pai = pai.Parent
    end

    local caminhoLower = obj:GetFullName():lower()
    local nomeLower = obj.Name:lower()

    for _, lixo in ipairs(LIXO_CAMINHO) do
        if string.find(caminhoLower, lixo) then return false end
    end

    for _, lixo in ipairs(LIXO_NOME) do
        if string.find(nomeLower, lixo) then return false end
    end

    if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("StringValue") then
        local val = ""
        pcall(function() val = string.lower(obterValorSeguro(obj)) end)

        if val == "" or val == "nil" then return false end
        if string.find(val, "<font") or string.find(val, "<i") or string.find(val, "<b") then return false end
        if string.find(val, "%d+:%d+") then return false end
        if string.find(val, "/") and not string.find(nomeLower, "xp") and not string.find(nomeLower, "level") then return false end
        if string.match(val, "^x%d+") then return false end

        local badWords = {"buy", "purchase", "off", "fps", "reward", "page", "hang tight", "last seen", "month", "days"}
        for _, word in ipairs(badWords) do
            if string.find(val, word) then return false end
        end

        if (obj:IsA("TextLabel") or obj:IsA("TextButton")) and not string.match(val, "%d") then
            return false
        end
    end

    if obj:IsA("IntValue") or obj:IsA("NumberValue") or obj:IsA("StringValue") or obj:IsA("TextLabel") or obj:IsA("TextButton") then
        return true
    end

    return false
end

-- ==========================================
-- BUSCA E RESOLUÇÃO DE CAMINHOS
-- ==========================================
local function resolverCaminho(caminhoString)
    local partes = string.split(caminhoString, ".")
    local atual = game

    for i, parte in ipairs(partes) do
        if not atual then return nil end

        if atual == game then
            local sucesso, servico = pcall(function() return game:GetService(parte) end)
            if sucesso and servico then
                atual = servico
            else
                atual = game:FindFirstChild(parte)
            end
        else
            atual = atual:FindFirstChild(parte)
        end
    end

    return atual
end

local function iniciarVarredura()
    local dadosColetados = {}
    local nomesVistos = {}

    local PASTAS_STATUS = {"leaderstats", "Stats", "Data", "PlayerData", "leaderboard", "Currency"}

    for _, nomePasta in ipairs(PASTAS_STATUS) do
        local pasta = LocalPlayer:FindFirstChild(nomePasta)
        if pasta then
            for _, stat in ipairs(pasta:GetChildren()) do
                if stat:IsA("IntValue") or stat:IsA("NumberValue") or stat:IsA("StringValue") then
                    local chaveRastreio = stat.Name
                    if not nomesVistos[chaveRastreio] then
                        table.insert(dadosColetados, {
                            Nome = stat.Name, Caminho = mascararCaminho(stat:GetFullName()),
                            Valor = tostring(stat.Value), Tipo = stat.ClassName,
                            Confiabilidade = "Alta (Status Oficial)"
                        })
                        nomesVistos[chaveRastreio] = true
                    end
                end
            end
        end
    end

    local servicos = { LocalPlayer, game:GetService("ReplicatedStorage") }

    for _, serv in ipairs(servicos) do
        pcall(function()
            local descendentes = serv:GetDescendants()
            for i, obj in ipairs(descendentes) do
                if i % 500 == 0 then task.wait() end
                if obj:IsA("ValueBase") or obj:IsA("TextLabel") or obj:IsA("TextButton") then
                    if isItemImportante(obj) then
                        local chaveRastreio = obj.Name
                        if not nomesVistos[chaveRastreio] then
                            local valorSeguro = "nil"
                            pcall(function() valorSeguro = obterValorSeguro(obj) end)
                            table.insert(dadosColetados, {
                                Nome = obj.Name, Caminho = mascararCaminho(obj:GetFullName()),
                                Valor = valorSeguro, Tipo = obj.ClassName,
                                Confiabilidade = "Baixa (Interface/Replicated)"
                            })
                            nomesVistos[chaveRastreio] = true
                        end
                    end
                end
            end
        end)
    end

    return dadosColetados
end

-- ==========================================
-- LOOP PRINCIPAL (GERENCIADOR DE METAS)
-- ==========================================
local function rodarCiclo()
    -- 1. Nova Regra Rápida: Atualiza apenas Metas Ativas (se existirem)
    if isfile(targetFile) then
        local targetContent = nil
        pcall(function() targetContent = readfile(targetFile) end)

        if targetContent then
            local sucessoJSON, targetData = pcall(function() return HttpService:JSONDecode(targetContent) end)

            if sucessoJSON and targetData and type(targetData.paths) == "table" then
                local dadosAlvos = {}

                for _, caminho in ipairs(targetData.paths) do
                    -- DESMASCARA o caminho curinga pro script achar o caminho real da conta
                    local obj = resolverCaminho(desmascararCaminho(caminho))
                    if obj then
                        local val = "0"
                        pcall(function() val = obterValorSeguro(obj) end)

                        table.insert(dadosAlvos, {
                            Nome = obj.Name,
                            Caminho = caminho, -- Mantém o coringa ao salvar
                            Valor = tostring(val),
                            Tipo = obj.ClassName,
                            Confiabilidade = "Alvo Monitorado"
                        })
                    end
                end

                -- Se as metas estão ativas, salva apenas elas e pula a varredura pesada
                if #dadosAlvos > 0 then
                    local payload = {
                        place_id = PlaceId,
                        player_name = LocalPlayer and LocalPlayer.Name or "Unknown",
                        last_scan = os.time(),
                        items_count = #dadosAlvos,
                        data = dadosAlvos
                    }
                    pcall(function()
                        writefile(fileName, HttpService:JSONEncode(payload))
                    end)
                end

                return -- Sai da função aqui para garantir que a varredura global NÃO rode
            end
        end
    end

    -- 2. Regra Antiga: Só cai aqui se NÃO houver metas ativas E se passaram 4 dias
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

            local sucessoJson, corpoJson = pcall(function() return HttpService:JSONEncode(payload) end)

            if sucessoJson and writefile then
                local sucessoWrite = pcall(function() writefile(fileName, corpoJson) end)
                if not sucessoWrite then
                    pcall(function() writefile(fallbackName, corpoJson) end)
                end
            end
        end
    end
end

-- ==========================================
-- DAEMON WORKER (Atualiza a cada 60s)
-- ==========================================
task.spawn(function()
    while true do
        rodarCiclo()
        task.wait(60) -- Intervalo de leitura
    end
end)
