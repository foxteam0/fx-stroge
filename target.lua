exports['qb-target']:AddBoxZone("buyshops", Config.ShopsTarget, 1.5, 1.6, {
  heading = 325.91, -- The heading of the boxzone, this has to be a float value
  debugPoly = false, -- This is for enabling/disabling the drawing of the box, it accepts only a boolean value (true or false), when true it will draw the polyzone in green
  minZ = 8.0, -- This is the bottom of the boxzone, this can be different from the Z value in the coords, this has to be a float value
  maxZ = 11.0, -- This is the top of the boxzone, this can be different from the Z value in the coords, this has to be a float value
}, {
  options = { 
    { 
      type = "client", 
      event = "shop:open",
      icon = 'fas fa-example',
      label = 'Bill',

    }
  },
  distance = 2.5, -- This is the distance for you to be at for the target to turn blue, this is in GTA units and has to be a float value
})

local basePosition = Config.Garagepeds

-- Pozisyonlar dizinizi üzerinde döngü yapın
for i, positionData in ipairs(Config.Garagepeds) do
    local zoneName = "garagezone" .. i  -- İndexe bağlı olarak dinamik olarak zone adı oluşturuluyor
    local position = positionData.pos
    local heading = positionData.pos.w  -- 'w' bileşeninin başlığı temsil ettiği varsayılarak

    exports['qb-target']:AddBoxZone(zoneName, position, 1.5, 1.6, {
        heading = heading,
        debugPoly = false,
        minZ = 8.0,
        maxZ = 11.0,
    }, {
        options = {
            {
                type = "client",
                event = "garagemenu",
                icon = 'fas fa-example',
                label = 'Garaj Menüsü',
            },
            -- Diğer seçenekleri gerektiği gibi ekleyin...
        },
        distance = 2.5,
    })
end
