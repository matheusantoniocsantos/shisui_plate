addEventHandler('onResourceStart', resourceRoot,
function(resourceName)
    if (resourceName == resource) then
        outputDebugString('[ '.. getResourceName(getThisResource()) ..' ]: The resource was launched successfully', 4, 0, 119, 192)
    end
end)

function getproxveh(ply,distance)
	local x, y, z = getElementPosition (ply) 
	local dist = distance
	local id = false
    local players = getElementsByType("vehicle")
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
        iprint('asd')
        triggerClientEvent(ply, 'shisui.plateOpenRender', ply)
    end
end

addCommandHandler('teste', function(ply, cmd)
    open(ply)
end)

function execDB()
    config.functionConce
end
addEvent('shisui.plateOpenRender', true)
addEventHandler('shisui.plateOpenRender', root, showPanel)