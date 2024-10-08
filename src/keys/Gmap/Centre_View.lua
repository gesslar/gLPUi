local room_id = getPlayerRoom()

if not room_id then
  echo("The mapper cannot determine your current location.")
  return
end

centerview(room_id)
