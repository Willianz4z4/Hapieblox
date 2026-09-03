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
-- FILTRO UNIVERSAL (V9.0 NATIVO - LEITOR DE TELA)
-- ==========================================
local TIPOS_LIXO = {
    Color3Value = true, BrickColorValue = true, Vector3Value = true,
    CFrameValue = true, BoolValue = true, ObjectValue = true, RayValue = true
}

-- Removido o "gui" para permitir a leitura da interface gráfica (PlayerGui)
local LIXO_VISUAL = {
    "animate", "camera", "viewport", "worldmodel",
    "mesh", "texture", "decal", "sound",
    "resources", "placetype", "gitinfo", "debug"
}

-- Palavras que bloqueiam apenas se forem o NOME EXATO do item
local LIXO_NOME_EXATO = {
    "color", "size", "position", "transparency", "visible", "zindex", "layoutorder"
}

local function isItemImportante(obj)
    if TIPOS_LIXO[obj.ClassName] then return false end

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

    for _, lixo in ipairs(LIXO_VISUAL) do
        if string.find(caminhoLower, lixo) or string.find(nomeLower, lixo) then
            return false
        end
    end

    for _, lixo in ipairs(LIXO_NOME_EXATO) do
        if nomeLower == lixo then
            return false
        end
    end

    -- CAPTURA DE VARIÁVEIS CLÁSSICAS
    if obj:IsA("IntValue") or obj:IsA("NumberValue") or obj:IsA("StringValue") then
        return true
    end

    -- NOVO: CAPTURA DE TELA (O ÚLTIMO RECURSO UNIVERSAL)
    -- Se for um texto na tela do jogador e contiver números, nós capturamos!
    if obj:IsA("TextLabel") or obj:IsA("TextButton") then
        if obj.Text ~= "" and string.match(obj.Text, "%d") then
            return true
        end
    end

    return false
end

local function obterValorSeguro(obj)
    if obj:IsA("TextLabel") or obj:IsA("TextButton") then
        return obj.Text
    end
    return tostring(obj.Value)
end

-- ==========================================
-- VARREDURA FOCADA (AGORA LÊ A TELA DO JOGADOR)
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
                        -- Se for TextLabel, o nome importa menos que o caminho (evita bloquear 2 botões com mesmo nome)
                        local chaveRastreio = obj:IsA("TextLabel") and obj:GetFullName() or obj.Name

                        if not nomesVistos[chaveRastreio] then
                            local valorSeguro = "nil"
                            pcall(function()
                                valorSeguro = obterValorSeguro(obj)
                            end)

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
    end
end
