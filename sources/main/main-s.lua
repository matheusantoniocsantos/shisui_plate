addEventHandler('onResourceStart', resourceRoot,
function(resourceName)
    if (resourceName == resource) then
        outputDebugString('[ '.. getResourceName(getThisResource()) ..' ]: The resource was launched successfully', 4, 0, 119, 192)
    end
end)
