config = {

    general = {
        placaItem = '',
    },

}

-- // troque pela logica do seu inv


hasItem = function(player)
    if exports['hash_inventory']:getPlayerItem(player, 'placa', 1) then
        return true
    end
end

notifyS = function(player, message, type)
    exports['[HS]Notify_System']:notify(player, message, type) 
end