local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlaceId = tostring(game.PlaceId)
local MeuNick = LocalPlayer and LocalPlayer.Name or "Unknown"

local folderName = "Hapieblox_Farm"

local fileName = folderName .. "/game_" .. PlaceId .. "_" .. MeuNick .. "_farm.json"
local fallbackName = "fallback_" .. PlaceId .. "_" .. MeuNick .. "_farm.json"
local statusName = folderName .. "/status_" .. PlaceId .. "_" .. MeuNick .. ".json"

local targetFolder = folderName .. "/targets_active"
local targetFile = targetFolder .. "/" .. PlaceId .. ".json"

local QUATRO_DIAS_EM_SEGUNDOS = 4 * 24 * 60 * 60

if isfolder and not isfolder(folderName) then
    pcall(function() makefolder(folderName) end)
end
if isfolder and not isfolder(targetFolder) then
    pcall(function() makefolder(targetFolder) end)
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
                            Nome = stat.Name, Caminho = stat:GetFullName(),
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
                                Nome = obj.Name, Caminho = obj:GetFullName(),
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

local function rodarCiclo()
    -- 1. Regra Rápida: Atualiza o Status (Metas Ativas)
    if isfile(targetFile) then
        local targetContent = nil
        pcall(function() targetContent = readfile(targetFile) end)

        if targetContent then
            local sucessoJSON, targetData = pcall(function() return HttpService:JSONDecode(targetContent) end)

            if sucessoJSON and targetData and type(targetData.paths) == "table" then
                local dadosAlvos = {}

                for _, caminhoCuringa in ipairs(targetData.paths) do
                    local caminhoReal = string.gsub(caminhoCuringa, "%[LOCAL_PLAYER%]", MeuNick)
                    
                    local obj = resolverCaminho(caminhoReal)
                    if obj then
                        local val = "0"
                        pcall(function() val = obterValorSeguro(obj) end)

                        table.insert(dadosAlvos, {
                            Nome = obj.Name,
                            Caminho = caminhoReal,
                            Valor = tostring(val),
                            Tipo = obj.ClassName,
                            Confiabilidade = "Alvo Monitorado"
                        })
                    end
                end

                if #dadosAlvos > 0 then
                    local payload = {
                        place_id = PlaceId,
                        player_name = MeuNick,
                        last_scan = os.time(),
                        items_count = #dadosAlvos,
                        data = dadosAlvos
                    }
                    pcall(function()
                        writefile(statusName, HttpService:JSONEncode(payload))
                    end)
                end
                
                -- O "return" foi removido daqui! Agora ele segue para checar a varredura dos 4 dias.
            end
        end
    end

    -- 2. Regra Antiga (Varredura de 4 dias):
    if precisaAtualizar() then
        local dados = iniciarVarredura()

        if #dados > 0 then
            local payload = {
                place_id = PlaceId,
                player_name = MeuNick,
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

task.spawn(function()
    while true do
        rodarCiclo()
        task.wait(60)
    end
end)
