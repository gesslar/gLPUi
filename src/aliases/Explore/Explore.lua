local input = matches[2]:trim()
local command, value = input:match("^(%S+)%s*(.*)$")

if command == "start" then
  -- call function here for starting exploration
  Explore:Explore()
elseif command == "stop" then
  -- call function here for stopping exploration
  Explore:StopExplore(true)
  if Mapper.walking then
    Mapper:ResetWalking()
  end
else
  -- Print out the explore instructions
  cecho("<orange_red>Syntax: explore [start|stop]\n")
end
