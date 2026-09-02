local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlaceId = tostring(game.PlaceId)

-- ==========================================
-- CONFIGURAÇÕES DE DIRETÓRIO E TEMPO
-- ==========================================
local folderName = "Hapieblox_Farm"
local fileName = folderName .. "/game_" .. PlaceId .. ".json"
local TRES_DIAS_EM_SEGUNDOS = 3 * 24 * 60 * 60

-- Garante que a pasta exista
if isfolder and not isfolder(folderName) then
    pcall(function() makefolder(folderName) end)
end

-- ==========================================
-- FUNÇÃO: VERIFICA SE PRECISA ATUALIZAR (3 DIAS)
-- ==========================================
local function precisaAtualizar()
    if not isfile or not readfile then return true end
    
    if isfile(fileName) then
        local sucesso, dados = pcall(function()
            return HttpService:JSONDecode(readfile(fileName))
        end)
        if sucesso and dados and dados.last_scan then
            if os.time() - dados.last_scan < TRES_DIAS_EM_SEGUNDOS then
                print("[Hapieblox Scanner] Jogo já escaneado recentemente. Pulando varredura.")
                return false
            end
        end
    end
    return true
end

-- ==========================================
-- FUNÇÃO: VARREDURA SEGURA
-- ==========================================
local function iniciarVarredura()
    local dadosColetados = {}
    local servicos = { workspace, Players, game:GetService("ReplicatedStorage") }

    for _, serv in ipairs(servicos) do
        pcall(function()
            local descendentes = serv:GetDescendants()
            for i, obj in ipairs(descendentes) do
                if i % 500 == 0 then task.wait() end 
                
                if obj:IsA("ValueBase") then
                    local valorSeguro = "nil"
                    if obj.Value ~= nil then valorSeguro = tostring(obj.Value) end
                    
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

-- ==========================================
-- EXECUÇÃO PRINCIPAL (SALVA PRIMEIRO, ENVIA DEPOIS)
-- ==========================================
if precisaAtualizar() then
    print("[Hapieblox Scanner] Iniciando varredura silenciosa...")
    local dados = iniciarVarredura()

    if #dados > 0 then
        -- Monta o pacote COMPLETO com todos os dados do mapa
        local payload = {
            place_id = PlaceId,
            player_name = LocalPlayer and LocalPlayer.Name or "Unknown",
            last_scan = os.time(),
            data = dados
        }
        
        local sucessoJson, corpoJson = pcall(function()
            return HttpService:JSONEncode(payload)
        end)

        if sucessoJson then
            -- 1º PASSO: SALVAR O ARQUIVO NA PASTA EM FORMATO JSON
            if writefile then
                local sucessoWrite, erroWrite = pcall(function()
                    writefile(fileName, corpoJson)
                end)
                
                if sucessoWrite then
                    print("[Hapieblox Scanner] SUCESSO: Arquivo salvo no formato correto em " .. fileName)
                else
                    warn("[Hapieblox Scanner] Falha ao salvar na subpasta. Tentando salvar na raiz...")
                    pcall(function()
                        writefile("game_" .. PlaceId .. ".json", corpoJson)
                    end)
                end
            else
                warn("[Hapieblox Scanner] Executor não suporta writefile.")
            end

            -- 2º PASSO: ENVIAR PARA A API PYTHON
            local http_request = (syn and syn.request) or (http and http.request) or request
            if http_request then
                pcall(function()
                    local resposta = http_request({
                        Url = "http://127.0.0.1:5000/request_data",
                        Method = "POST",
                        Headers = { ["Content-Type"] = "application/json" },
                        Body = corpoJson
                    })
                    if resposta.StatusCode == 200 then
                        print("[Hapieblox Scanner] Dados enviados com sucesso para a API!")
                        pcall(function()
                            game:GetService("StarterGui"):SetCore("SendNotification", {
                                Title = "📡 Scanner Hapieblox",
                                Text = "JSON salvo na pasta e enviado pro Python!",
                                Duration = 4
                            })
                        end)
                    end
                end)
            end
        else
            warn("[Hapieblox Scanner] Erro ao converter dados para JSON.")
        end
    else
        print("[Hapieblox Scanner] Nenhum dado de valor (ValueBase) encontrado neste jogo.")
    end
end
