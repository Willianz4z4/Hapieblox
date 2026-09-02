local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlaceId = tostring(game.PlaceId)

local folderName = "Hapieblox_Farm"
local fileName = folderName .. "/game_" .. PlaceId .. "_farm.json"
local QUATRO_DIAS_EM_SEGUNDOS = 4 * 24 * 60 * 60 -- 345.600 segundos

local function notificar(titulo, texto)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = titulo,
            Text = texto,
            Duration = 5
        })
    end)
end

if isfolder and not isfolder(folderName) then
    pcall(function() makefolder(folderName) end)
end

-- ==========================================
-- SISTEMA DE CACHE (4 DIAS)
-- ==========================================
local function precisaAtualizar()
    if not isfile or not readfile then return true end
    
    if isfile(fileName) then
        local sucesso, dados = pcall(function()
            return HttpService:JSONDecode(readfile(fileName))
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
-- FILTRO ESTRUTURAL (SÓ MOEDAS E VALORES VISÍVEIS)
-- ==========================================
local function isItemImportante(obj)
    local pai = obj.Parent
    while pai and pai ~= game do
        if pai.Name:lower() == "leaderstats" then 
            return true 
        end
        
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
    notificar("📡 Hapieblox Scanner", "Buscando valores e moedas visíveis...")
    local dados = iniciarVarredura()
    
    notificar("📡 Hapieblox Scanner", "Mapeamento concluído! " .. tostring(#dados) .. " valores encontrados.")

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
            -- Salva o arquivo localmente
            if writefile then
                local sucessoWrite = pcall(function()
                    writefile(fileName, corpoJson)
                end)
                if not sucessoWrite then
                    pcall(function() writefile("game_" .. PlaceId .. "_farm.json", corpoJson) end)
                end
            end

            -- Envia para o servidor Python
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
else
    notificar("♻️ Hapieblox Scanner", "Mapeamento recente encontrado. Pulando varredura (4 dias).")
end
