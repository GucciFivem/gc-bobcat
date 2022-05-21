fx_version 'cerulean'
game 'gta5'

ui_page 'html/index.html'
file 'html/index.html'

shared_scripts { 
	'config.lua'
}

server_scripts {
	'config.lua',
	'server/main.lua'
}

client_scripts {
    'config.lua',
    'client/main.lua'
}