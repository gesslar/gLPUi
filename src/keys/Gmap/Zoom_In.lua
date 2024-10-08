local room_id = getPlayerRoom()

if not room_id then
  echo("The mapper cannot determine your current location.")
  return
end

local area_id = getRoomArea(room_id)

setMapZoom(-2.5 + getMapZoom(area_id), area_id)
centerview(room_id)
