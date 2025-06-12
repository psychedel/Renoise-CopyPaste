-- Copy-Paste Tool for Renoise

local APP_NAME = "Copy Paste"
local APP_VERSION = "0.1"

-- Global state for storing copied data
local copied_data = nil
local last_selection = nil
local copy_dialog = nil
local paste_dialog = nil

function keyhandler_func(dialog, key)
    return key
end

-- Utility functions
local function log(message)
    print("[" .. APP_NAME .. "] " .. tostring(message))
end

local function get_current_selection()
    local song = renoise.song()
    local selection = song.selection_in_pattern

    if not selection then
        log("No selection found")
        return nil
    end

    return {
        start_line = selection.start_line,
        end_line = selection.end_line,
        start_track = selection.start_track,
        end_track = selection.end_track,
        start_column = selection.start_column,
        end_column = selection.end_column
    }
end

local function format_note(note_value)
    if note_value == 121 then
        return "OFF"
    elseif note_value == 120 then
        return "---"
    elseif note_value >= 0 and note_value <= 119 then
        local note_names = { "C-", "C#", "D-", "D#", "E-", "F-", "F#", "G-", "G#", "A-", "A#", "B-" }
        local octave = math.floor(note_value / 12)
        local note = (note_value % 12) + 1
        return note_names[note] .. octave
    else
        return "---"
    end
end

local function format_instrument(instr_value)
    if instr_value == renoise.PatternLine.EMPTY_INSTRUMENT then
        return ".."
    else
        return string.format("%02X", instr_value)
    end
end

local function format_volume(vol_value)
    if vol_value == renoise.PatternLine.EMPTY_VOLUME then
        return ".."
    else
        return string.format("%02X", vol_value)
    end
end

local function format_effect(effect_number, effect_amount)
    if effect_number == renoise.PatternLine.EMPTY_EFFECT_NUMBER then
        return "...."
    else
        local amount = effect_amount == renoise.PatternLine.EMPTY_EFFECT_AMOUNT and 0 or effect_amount
        return string.format("%02X%02X", effect_number, amount)
    end
end

local function copy_selection_to_text()
    local selection = get_current_selection()
    if not selection then
        renoise.app():show_status("No selection to copy")
        return
    end

    last_selection = selection

    local song = renoise.song()
    local pattern = song.selected_pattern
    local output = {}

    -- Header
    table.insert(output, "=== RENOISE PATTERN DATA ===")
    table.insert(output, "Format: Safe-V1")
    table.insert(output, string.format("Selection: L%03d-%03d T%03d-%03d",
        selection.start_line, selection.end_line,
        selection.start_track, selection.end_track))
    table.insert(output, "")

    -- Track names
    local track_header = "Line"
    for track_idx = selection.start_track, selection.end_track do
        local track = song.tracks[track_idx]
        track_header = track_header .. string.format(" | T%02d:%s", track_idx, track.name)
    end
    table.insert(output, track_header)
    table.insert(output, "")

    -- Pattern data
    for line_idx = selection.start_line, selection.end_line do
        local line_str = string.format("%03d", line_idx)

        for track_idx = selection.start_track, selection.end_track do
            local track = pattern:track(track_idx)
            local line = track:line(line_idx)

            line_str = line_str .. " |"

            -- Note columns
            local visible_note_cols = song.tracks[track_idx].visible_note_columns
            for col_idx = 1, math.max(1, visible_note_cols) do
                if col_idx <= #line.note_columns then
                    local note_col = line.note_columns[col_idx]
                    local note = format_note(note_col.note_value)
                    local instr = format_instrument(note_col.instrument_value)
                    local vol = format_volume(note_col.volume_value)
                    line_str = line_str .. string.format(" %s %s %s", note, instr, vol)
                else
                    line_str = line_str .. " --- .. .."
                end
            end

            -- Effect columns
            local visible_fx_cols = song.tracks[track_idx].visible_effect_columns
            for col_idx = 1, math.max(1, visible_fx_cols) do
                if col_idx <= #line.effect_columns then
                    local fx_col = line.effect_columns[col_idx]
                    local effect = format_effect(fx_col.number_value, fx_col.amount_value)
                    line_str = line_str .. " " .. effect
                else
                    line_str = line_str .. " ...."
                end
            end
        end

        table.insert(output, line_str)
    end

    table.insert(output, "")
    table.insert(output, "=== END PATTERN DATA ===")

    copied_data = table.concat(output, "\n")

    log("Selection copied (" .. (selection.end_line - selection.start_line + 1) .. " lines, " ..
        (selection.end_track - selection.start_track + 1) .. " tracks)")

    -- Show copy dialog with the text
    show_copy_dialog(copied_data)
end

local function parse_note(note_str)
    if note_str == "---" then
        return 120 -- Empty note
    elseif note_str == "OFF" then
        return 121 -- Note off
    else
        local note_names = {
            ["C-"] = 0,
            ["C#"] = 1,
            ["D-"] = 2,
            ["D#"] = 3,
            ["E-"] = 4,
            ["F-"] = 5,
            ["F#"] = 6,
            ["G-"] = 7,
            ["G#"] = 8,
            ["A-"] = 9,
            ["A#"] = 10,
            ["B-"] = 11
        }
        local note_name = note_str:sub(1, 2)
        local octave = tonumber(note_str:sub(3, 3))
        if note_names[note_name] and octave then
            return note_names[note_name] + (octave * 12)
        end
    end
    return 120 -- Default to empty
end

local function parse_hex_value(hex_str, empty_value)
    if hex_str == ".." then
        return empty_value
    else
        return tonumber(hex_str, 16) or empty_value
    end
end

local function apply_text_data(text_data)
    if not text_data or text_data == "" then
        renoise.app():show_status("No data to paste")
        return false
    end

    local selection = get_current_selection()
    if not selection then
        renoise.app():show_status("No selection for pasting")
        return false
    end

    local lines = {}
    for line in text_data:gmatch("[^\n]+") do
        table.insert(lines, line)
    end

    -- Find pattern data section
    local data_start = nil
    local data_end = nil

    for i, line in ipairs(lines) do
        if line:match("^%d%d%d") then -- Line starts with 3 digits
            if not data_start then data_start = i end
            data_end = i
        end
    end

    if not data_start then
        renoise.app():show_status("No valid pattern data found")
        return false
    end

    local song = renoise.song()
    local pattern = song.selected_pattern
    local paste_line = selection.start_line

    -- Paste data
    for i = data_start, data_end do
        if paste_line > selection.end_line then break end

        local line_data = lines[i]
        local line_num = tonumber(line_data:sub(1, 3))

        if line_num then
            local track_idx = selection.start_track

            -- Parse track data
            for track_data in line_data:gmatch("|([^|]*)") do
                if track_idx > selection.end_track then break end

                local track = pattern:track(track_idx)
                local line = track:line(paste_line)

                -- Parse note columns and effects from track_data
                local parts = {}
                for part in track_data:gmatch("%S+") do
                    table.insert(parts, part)
                end

                -- Apply note column data
                if #parts >= 3 then
                    if #line.note_columns > 0 then
                        local note_col = line.note_columns[1]
                        note_col.note_value = parse_note(parts[1])
                        note_col.instrument_value = parse_hex_value(parts[2], renoise.PatternLine.EMPTY_INSTRUMENT)
                        note_col.volume_value = parse_hex_value(parts[3], renoise.PatternLine.EMPTY_VOLUME)
                    end
                end

                -- Apply effect column data
                if #parts >= 4 then
                    if #line.effect_columns > 0 then
                        local fx_col = line.effect_columns[1]
                        local effect_str = parts[4]
                        if effect_str ~= "...." then
                            fx_col.number_value = parse_hex_value(effect_str:sub(1, 2),
                                renoise.PatternLine.EMPTY_EFFECT_NUMBER)
                            fx_col.amount_value = parse_hex_value(effect_str:sub(3, 4),
                                renoise.PatternLine.EMPTY_EFFECT_AMOUNT)
                        else
                            fx_col.number_value = renoise.PatternLine.EMPTY_EFFECT_NUMBER
                            fx_col.amount_value = renoise.PatternLine.EMPTY_EFFECT_AMOUNT
                        end
                    end
                end

                track_idx = track_idx + 1
            end
        end

        paste_line = paste_line + 1
    end

    log("Pattern data pasted successfully")
    renoise.app():show_status("Pattern data pasted successfully")
    return true
end

function show_copy_dialog(text_data)
    if copy_dialog and copy_dialog.visible then
        copy_dialog:close()
    end

    local vb = renoise.ViewBuilder()

    local dialog_content = vb:column {
        margin = 10,
        spacing = 10,

        vb:text {
            text = "Pattern Data Copied",
            font = "big",
            style = "strong"
        },

        vb:text {
            text = "Copy this text to share your pattern data:"
        },

        vb:multiline_textfield {
            text = text_data,
            width = 600,
            height = 300,
            edit_mode = false
        },

        vb:horizontal_aligner {
            mode = "center",
            vb:button {
                text = "Close",
                width = 100,
                notifier = function()
                    if copy_dialog then copy_dialog:close() end
                end
            }
        }
    }

    copy_dialog = renoise.app():show_custom_dialog("Copy Pattern Data", dialog_content, keyhandler_func)
end

function show_paste_dialog()
    if paste_dialog and paste_dialog.visible then
        paste_dialog:close()
    end

    local vb = renoise.ViewBuilder()

    local text_field = vb:multiline_textfield {
        text = copied_data or "",
        width = 600,
        height = 300,
        edit_mode = true
    }

    local dialog_content = vb:column {
        margin = 10,
    --    spacing = 10,
--[[
        vb:text {
            text = "Paste Pattern Data",
            font = "big",
            style = "strong"
        },
]]--
        vb:text {
            text = "Paste pattern data text here and click Apply:"
        },

        text_field,

        vb:horizontal_aligner {
            mode = "center",
            spacing = 10,

            vb:button {
                text = "Apply",
                width = 100,
                notifier = function()
                    local success = apply_text_data(text_field.text)
                    if success and paste_dialog then
                        paste_dialog:close()
                    end
                end
            },

            vb:button {
                text = "Cancel",
                width = 100,
                notifier = function()
                    if paste_dialog then paste_dialog:close() end
                end
            }
        }
    }

    paste_dialog = renoise.app():show_custom_dialog("Paste Pattern Data", dialog_content)
end

local function show_main_dialog()
    local vb = renoise.ViewBuilder()

    local dialog_content = vb:column {
        margin = 10,
        --spacing = 15,
--[[
        vb:text {
            text = APP_NAME .. " v" .. APP_VERSION,
            font = "big",
            style = "strong"
        },
]]--
        vb:text {
            text = "Clipboard-free pattern copy & paste tool"
        },

        vb:horizontal_aligner {
            mode = "center",

            vb:column {
           --     spacing = 10,

                vb:button {
                    text = "Copy Selection",
                    width = 200,
                    height = 30,
                    notifier = copy_selection_to_text
                },

                vb:button {
                    text = "Paste Data",
                    width = 200,
                    height = 30,
                    notifier = show_paste_dialog
                }
            }
        },

        vb:text {
            text = "Instructions:\n" ..
                "1. Select pattern area\n" ..
                "2. Click 'Copy Selection'\n" ..
                "3. Copy text from dialog\n" ..
                "4. Share or save the text\n" ..
                "5. Select destination area\n" ..
                "6. Click 'Paste Data' and paste text"
        }
    }

    renoise.app():show_custom_dialog(APP_NAME .. " v" .. APP_VERSION, dialog_content, keyhandler_func)
    renoise.app().window.active_middle_frame=renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
end

renoise.tool():add_menu_entry{name="Main Menu:Tools:" .. APP_NAME .. "...",invoke=show_main_dialog}
renoise.tool():add_menu_entry{name="Pattern Editor:Tools:Copy Selection to Text",invoke=copy_selection_to_text}
renoise.tool():add_menu_entry{name="Pattern Editor:Tools:Paste Text Data",invoke=show_paste_dialog}
renoise.tool():add_keybinding{name="Pattern Editor:Tools:Copy Selection to Text",invoke=copy_selection_to_text}
renoise.tool():add_keybinding{name="Pattern Editor:Tools:Paste Text Data",invoke=show_paste_dialog}

log(APP_NAME .. " v" .. APP_VERSION .. " loaded successfully (clipboard-independent)")
