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
        setTransferBoxVisible(false)
        table.eventHandler = true
    else
        removeEventHandler('onClientRender', root, render)
        setCameraTarget(localPlayer, nil)
        table.eventHandler = false
    end
end

bindKey('enter', 'up', function()
    local plate = dxGetEditBoxText('plate')
    if #plate > 6 then
        iprint(plate)
    end
end)

addCommandHandler('asd', function()
    showPanel()
    iprint(dxGetEditBoxText('plate'))
end)