local handler = require("event_handler")
handler.add_lib(require("freeplay"))
handler.add_lib(require("silo-script"))

local function kind_of(obj)
    if type(obj) ~= 'table' then return type(obj) end
    local i = 1
    for _ in pairs(obj) do
      if obj[i] ~= nil then i = i + 1 else return 'table' end
    end
    if i == 1 then return 'table' else return 'array' end
  end
  
  local function escape_str(s)
    local in_char  = {'\\', '"', '/', '\b', '\f', '\n', '\r', '\t'}
    local out_char = {'\\', '"', '/',  'b',  'f',  'n',  'r',  't'}
    for i, c in ipairs(in_char) do
      s = s:gsub(c, '\\' .. out_char[i])
    end
    return s
  end
  
  local function num_tostring(num)
    if num ~= num then return 'NaN' end
    if num == 1/0 then return 'Infinity' end
    if num == -1/0 then return '-Infinity' end
    return tostring(num)
  end
  
  local function stringify(obj, as_key)
    local s = {}  -- We'll build the string as an array of strings to be concatenated.
    local kind = kind_of(obj)  -- This is 'array' if it's an array or type(obj) otherwise.
    if kind == 'array' then
      if as_key then error('Can\'t encode array as key.') end
      s[#s + 1] = '['
      for i, val in ipairs(obj) do
        if i > 1 then s[#s + 1] = ', ' end
        s[#s + 1] = stringify(val)
      end
      s[#s + 1] = ']'
    elseif kind == 'table' then
      if as_key then error('Can\'t encode table as key.') end
      s[#s + 1] = '{'
      for k, v in pairs(obj) do
        if #s > 1 then s[#s + 1] = ', ' end
        s[#s + 1] = stringify(k, true)
        s[#s + 1] = ':'
        s[#s + 1] = stringify(v)
      end
      s[#s + 1] = '}'
    elseif kind == 'string' then
      return '"' .. escape_str(obj) .. '"'
    elseif kind == 'number' then
      if as_key then return '"' .. num_tostring(obj) .. '"' end
      return num_tostring(obj)
    elseif kind == 'boolean' then
      return tostring(obj)
    elseif kind == 'nil' then
      return 'null'
    else
      error('Unjsonifiable type: ' .. kind .. '.')
    end
    return table.concat(s)
  end

local function slog(table)
    log("rlog: " .. serpent.dump(table))
end

script.on_event(defines.events.on_player_mined_entity,
            function(event)
                slog({event_type="on_player_mined_entity",
                tick=event.tick,
                player_index=event.player_index,
                position=event.entity.position,
                name=event.entity.name,
                type=event.entity.type})
                
            end
        )