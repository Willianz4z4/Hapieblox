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
-- FILTRO SUPREMO (AGORA DIRETO NO ROBLOX)
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

    -- Bloqueia dados vazando de outros jogadores
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

    for _, lixo in ipairs(LIXO_CAMINHO) do
        if string.find(caminhoLower, lixo) then return false end
    end

    for _, lixo in ipairs(LIXO_NOME) do
        if string.find(nomeLower, lixo) then return false end
    end

    -- ==========================================
    -- NOVO: FILTRO DE CONTEÚDO (MATA O LIXO NA RAIZ)
    -- ==========================================
    if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("StringValue") then
        local val = ""
        pcall(function() val = string.lower(obterValorSeguro(obj)) end)
        
        if val == "" or val == "nil" then return false end

        -- 1. Ignora textos com HTML/RichText (<font>, <b>, <i>)
        if string.find(val, "<font") or string.find(val, "<i") or string.find(val, "<b") then return false end
        
        -- 2. Ignora relógios (ex: 24:00:00 ou 2:40)
        if string.find(val, "%d+:%d+") then return false end
        
        -- 3. Ignora frações (ex: 1/3, 0/255)
        if string.find(val, "/") and not string.find(nomeLower, "xp") and not string.find(nomeLower, "level") then return false end
        
        -- 4. Ignora multiplicadores de interface (ex: x99, x1000)
        if string.match(val, "^x%d+") then return false end
        
        -- 5. Ignora palavras focadas em loja, sistema ou avisos
        local badWords = {"buy", "purchase", "off", "fps", "reward", "page", "hang tight", "last seen", "month", "days"}
        for _, word in ipairs(badWords) do
            if string.find(val, word) then return false end
        end

        -- 6. Se for um botão/texto, tem que ter PELO MENOS UM número. Se for só letra, é lixo.
        if (obj:IsA("TextLabel") or obj:IsA("TextButton")) and not string.match(val, "%d") then
            return false
        end
    end

    -- Aprova apenas se for um valor real
    if obj:IsA("IntValue") or obj:IsA("NumberValue") or obj:IsA("StringValue") or obj:IsA("TextLabel") or obj:IsA("TextButton") then
        return true
    end

    return false
end

-- ==========================================
-- VARREDURA FOCADA
-- ==========================================
local function iniciarVarredura()
    local dadosColetados = {}
    local nomesVistos = {} 
    local servicos = { LocalPlayer, game:GetService("ReplicatedStorage") }

    for _, serv in ipairs(servicos) do
        pcall(function()
            local descendentes = serv:GetDescendants()
            for i, obj in ipairs(descendentes) do
                if i % 500 == 0 then task.wait() end

                if obj:IsA("ValueBase") or obj:IsA("TextLabel") or obj:IsA("TextButton") then
                    if isItemImportante(obj) then
                        local chaveRastreio = obj.Name -- Rastreamento para não pegar coisas iguais
                        
                        if not nomesVistos[chaveRastreio] then
                            local valorSeguro = "nil"
                            pcall(function() valorSeguro = obterValorSeguro(obj) end)

                            table.insert(dadosColetados, {
                                Nome = obj.Name,
                                Caminho = obj:GetFullName(),
                                Valor = valorSeguro,
                                Tipo = obj.ClassName
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

        local sucessoJson, corpoJson = pcall(function() return HttpService:JSONEncode(payload) end)

        if sucessoJson and writefile then
            local sucessoWrite = pcall(function() writefile(fileName, corpoJson) end)
            if not sucessoWrite then
                pcall(function() writefile(fallbackName, corpoJson) end)
            end
        end
    end
end
