fx_version 'cerulean'
game 'gta5'

server_scripts {
	'@es_extended/locale.lua',
	'server/main.lua',
	'locales/de.lua',
	'config.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	'client/main.lua',
	'locales/de.lua',
	'config.lua'
}

ui_page 'html/index.html'

files {
	'html/index.html',
	'html/assets/css/style.css',
	'html/assets/images/*',
	'html/assets/js/*',
}