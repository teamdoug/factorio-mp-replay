-- These are some style prototypes that the tutorial uses
-- You don't need to understand how these work to follow along
local styles = data.raw["gui-style"].default

--[[
styles["mpr_controls_flow"] = {
    type = "horizontal_flow_style",
    vertical_align = "center",
    horizontal_spacing = 16
}
]]

local characterNoClip = table.deepcopy(data.raw.character["character"])

characterNoClip.name = "character-no-clip"
characterNoClip.collision_mask = {["not-colliding-with-itself"] = true}
data:extend({characterNoClip})
