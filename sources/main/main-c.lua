local table = {
    eventHandler = false,
}

function render()
    dxDrawImage(391, 243, 564, 282, placeFolder('background')) 
    createEditBox('plate', 487, 351, 367, 91, {using = false, font = loadFont('semibold', 62), masked = false, onlynumber = false, textalign = 'center', maxcharacters = 7, othertext = 'Placa', text = {62, 60, 60, 255}, selected = {62, 60, 60, 255}}, false)

end

function showPanel()
    if table.eventHandler == false then
        addEventHandler('onClientRender', root, render)
        showCursor(true)
        table.eventHandler = true
    else
        removeEventHandler('onClientRender', root, render)
        showCursor(false)
        setCameraTarget(localPlayer, nil)
        table.eventHandler = false
    end
end
addEvent('shisui.plateOpenRender', true)
addEventHandler('shisui.plateOpenRender', root, showPanel)

function getproxveh(player, distanciaMaxima)
    if not isElement(player) or getElementType(player) ~= "player" then
        return false, "Elemento do jogador inválido."
    end

    if type(distanciaMaxima) ~= "number" or distanciaMaxima <= 0 then
        return false, "Distância máxima inválida."
    end

    local xJogador, yJogador, zJogador = getElementPosition(player)

    local veiculos = getElementsByType("vehicle")

    for _, veiculo in ipairs(veiculos) do
        local xVeiculo, yVeiculo, zVeiculo = getElementPosition(veiculo)

        local distancia = getDistanceBetweenPoints3D(xJogador, yJogador, zJogador, xVeiculo, yVeiculo, zVeiculo)

        if distancia <= distanciaMaxima then
            return true, veiculo
        end
    end

    return false, nil
end


bindKey('enter', 'up', function()
    local plate = dxGetEditBoxText('plate')
    local estaProximo, veiculoProximo = getproxveh(localPlayer, 5)

    if #plate > 6 then
        setVehiclePlateText(veiculoProximo, plate)
        triggerServerEvent('asd', localPlayer)
    end
end)

addCommandHandler('asd', function()
    showPanel()
    iprint(dxGetEditBoxText('plate'))
end)