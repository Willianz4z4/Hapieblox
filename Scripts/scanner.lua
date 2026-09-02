local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlaceId = tostring(game.PlaceId)

-- ==========================================
-- CONFIGURAÇÕES DE DIRETÓRIO E TEMPO
-- ==========================================
local folderName = "Hapieblox_Farm"
local fileName = folderName .. "/game_" .. PlaceId .. ".json"
local TRES_DIAS_EM_SEGUNDOS = 3 * 24 * 60 * 60 -- 259200 segundos

-- Garante que a pasta de cache local exista
if isfolder and not isfolder(folderName) then
    pcall(function() makefolder(folderName) end)
end

-- ==========================================
-- FUNÇÃO: VERIFICA SE PRECISA ATUALIZAR (3 DIAS)
-- ==========================================
local function precisaAtualizar()
    if not isfile or not readfile then return true end -- Se o executor não suportar, sempre escaneia
    
    if isfile(fileName) then
        local sucesso, dados = pcall(function()
            return HttpService:JSONDecode(readfile(fileName))
        end)
        
        if sucesso and dados and dados.last_scan then
            local tempoPassado = os.time() - dados.last_scan
            if tempoPassado < TRES_DIAS_EM_SEGUNDOS then
                print("[Hapieblox Scanner] Jogo já escaneado recentemente. Pulando varredura.")
                return false
            end
        end
    end
    return true
end

-- ==========================================
-- FUNÇÃO: VARREDURA BRUTA
-- ==========================================
local function iniciarVarredura()
    local dadosColetados = {}
    local servicos = { workspace, Players, game:GetService("ReplicatedStorage") }

    for _, serv in ipairs(servicos) do
        pcall(function()
            local descendentes = serv:GetDescendants()
            for i, obj in ipairs(descendentes) do
                if i % 500 == 0 then task.wait() end -- Previne travamento do jogo durante o scan
                
                if obj:IsA("ValueBase") then
                    table.insert(dadosColetados, {
                        Nome = obj.Name,
                        Caminho = obj:GetFullName(),
                        Valor = obj.Value,
                        Tipo = obj.ClassName
                    })
                end
            end
        end)
    end
    
    return dadosColetados
end

-- ==========================================
-- EXECUÇÃO PRINCIPAL E ENVIO PARA A API
-- ==========================================
if precisaAtualizar() then
    print("[Hapieblox Scanner] Iniciando varredura silenciosa...")
    
    local dados = iniciarVarredura()
    
    if #dados > 0 then
        local payload = {
            place_id = PlaceId,
            player_name = LocalPlayer and LocalPlayer.Name or "Unknown",
            data = dados
        }

        local http_request = (syn and syn.request) or (http and http.request) or request
        
        if http_request then
            pcall(function()
                local resposta = http_request({
                    Url = "http://1.2.3.4:5000/request_data",
                    Method = "POST",
                    Headers = { ["Content-Type"] = "application/json" },
                    Body = HttpService:JSONEncode(payload)
                })

                -- Se o servidor salvou com sucesso, registramos o cache local dos 3 dias
                if resposta.StatusCode == 200 then
                    print("[Hapieblox Scanner] Dados enviados com sucesso para a API!")
                    if writefile then
                        local cacheData = {
                            place_id = PlaceId,
                            last_scan = os.time()
                        }
                        writefile(fileName, HttpService:JSONEncode(cacheData))
                    end
                else
                    warn("[Hapieblox Scanner] Falha ao enviar para a API. Status: " .. tostring(resposta.StatusCode))
                end
            end)
        else
            warn("[Hapieblox Scanner] Executor não suporta requisições HTTP.")
        end
    else
        print("[Hapieblox Scanner] Nenhum dado de valor (ValueBase) encontrado neste jogo.")
    end
end
