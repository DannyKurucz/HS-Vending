fx_version 'cerulean'
game 'gta5'
lua54 'yes'
description 'Vending Machine - HS Vending'
shared_scripts {
    'config.lua',
    '@ox_lib/init.lua',

}

server_scripts {
    'config.lua',
    '@mysql-async/lib/MySQL.lua',
    '@es_extended/locale.lua',
    'Server/server.lua',
}

client_scripts {
    'config.lua',
    '@es_extended/locale.lua',
    'Client/client.lua',
}

