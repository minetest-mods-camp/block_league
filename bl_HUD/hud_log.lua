local function calc_action_offset(receiver) end

local row1_height_txt = 24
local row2_height_txt = 76
local row3_height_txt = 128

local row1_height_img = row1_height_txt -14
local row2_height_img = row2_height_txt -14
local row3_height_img = row3_height_txt -14


function block_league.hud_log_create(p_name)

  local icon_scale = { x = 3, y = 3}

  Panel:new("bl_log", {
    player = p_name,
    bg = "",
    position = { x = 1, y = 0 },
    alignment = { x = -1, y = 1 },

    sub_img_elems = {
      action_1 = {
        alignment = {x = -1, y = 1},
        scale = icon_scale
      },
      action_2 = {
        alignment = {x = -1, y = 1},
        scale = icon_scale
      },
      action_3 = {
        alignment = {x = -1, y = 1},
        scale = icon_scale
      },
    },
    sub_txt_elems = {
      executor_1 = {
        alignment = {x = -1, y = 1},
      },
      executor_2 = {
        alignment = {x = -1, y = 1},
      },
      executor_3 = {
        alignment = {x = -1, y = 1},
      },
      receiver_1 = {
        alignment = {x = -1, y = 1},
        offset = { x = -20, y = row1_height_txt }
      },
      receiver_2 = {
        alignment = {x = -1, y = 1},
        offset = { x = -20, y = row2_height_txt }
      },
      receiver_3 = {
        alignment = {x = -1, y = 1},
        offset = { x = -20, y = row3_height_txt }
      },
    }
  })
end



function block_league.hud_log_update(arena, action_img, executor, receiver)

  for pl_name, pl_stats in pairs(arena.players) do

    local panel = panel_lib.get_panel(pl_name, "bl_log")

    local executor_color
    local receiver_color

    if arena.players[executor].teamID == pl_stats.teamID then
      executor_color = "0xabf877"
      receiver_color = "0xff8e8e"
    else
      executor_color = "0xff8e8e"
      receiver_color = "0xabf877"
    end

    panel:update(_,

    -- icone
    {
      action_1 = {
        offset = { x = calc_action_offset(panel.receiver_2.text), y = row1_height_img },
        text = panel.action_2.text
      },
      action_2 = {
        offset = { x = calc_action_offset(panel.receiver_3.text), y = row2_height_img },
        text = panel.action_3.text
      },
      action_3 = {
        offset = { x = calc_action_offset(receiver), y = row3_height_img },
        text = action_img
      }
    },

    -- testo
    {
      executor_1 = {
        offset = { x = calc_action_offset(panel.receiver_2.text) - 60, y = row1_height_txt },
        number = panel.executor_2.number,
        text = panel.executor_2.text
      },
      executor_2 = {
        offset = { x = calc_action_offset(panel.receiver_3.text) - 60, y = row2_height_txt },
        number = panel.executor_3.number,
        text = panel.executor_3.text
      },
      executor_3 = {
        offset = { x = calc_action_offset(receiver) - 60, y = row3_height_txt },
        number = executor_color,
        text = executor
      },
      receiver_1 = {
        number = panel.receiver_2.number,
        text = panel.receiver_2.text
      },
      receiver_2 = {
        number = panel.receiver_3.number,
        text = panel.receiver_3.text
      },
      receiver_3 = {
        number = receiver_color,
        text = receiver
      }
    })

  end
end



function block_league.hud_log_clear(arena)

  for pl_name, _ in pairs(arena.players) do
    local panel = panel_lib.get_panel(pl_name, "bl_log")

    panel:update(_,

    -- icone
    {
      action_1 = {
        text = ""
      },
      action_2 = {
        text = ""
      },
      action_3 = {
        text = ""
      }
    },

    -- testo
    {
      executor_1 = {
        text = ""
      },
      executor_2 = {
        text = ""
      },
      executor_3 = {
        text = ""
      },
      receiver_1 = {
        text = ""
      },
      receiver_2 = {
        text = ""
      },
      receiver_3 = {
        text = ""
      }
    })
  end
end





----------------------------------------------
---------------FUNZIONI LOCALI----------------
----------------------------------------------

function calc_action_offset(receiver)
  return -20 - (8 * string.len(receiver))
end
