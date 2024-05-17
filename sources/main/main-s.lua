addEventHandler('onResourceStart', resourceRoot,
function(resourceName)
    if (resourceName == resource) then
        outputDebugString('[ '.. getResourceName(getThisResource()) ..' ]: The resource was launched successfully https://github.com/matheusantoniocsantos/', 4, 0, 119, 192)
    end
end)

function getproxveh(ply,distance)
	local x, y, z = getElementPosition (ply) 
	local dist = distance
	local id = false
    local players = getElementsByType('vehicle')
    for i, v in ipairs (players) do 
        if ply ~= v then
            local pX, pY, pZ = getElementPosition (v) 
            if getDistanceBetweenPoints3D(x, y, z, pX, pY, pZ) < dist then
                dist = getDistanceBetweenPoints3D(x, y, z, pX, pY, pZ)
                id = v
            end
        end
    end
    if id then
        return id
    else
        return false
    end
end

function open(ply)
    if getproxveh(ply, 5) then
        if hasItem(ply) then
            triggerClientEvent(ply, 'shisui.plateOpenRender', ply)
        else
            notifyS(ply,'Voce nao possui esse item','warning')
        end
    else
        notifyS(ply,'Nenhum veiculo proximo!','warning')
    end
end
addEvent('shisui.plateOpenRenderServer', true)
addEventHandler('shisui.plateOpenRenderServer', root, open)