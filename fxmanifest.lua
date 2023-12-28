fx_version'cerulean'
game 'gta5'

description 'fx-stroge'
version '1.0.0'
shared_scripts {
  '@qb-core/shared/locale.lua',
  'config.lua',
  'en.lua',
}

client_script {
  'client.lua',
  'target.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua',
}
