-- Copy-Paste Tool for Renoise
-- Enhanced with patterns from Paketti

local APP_NAME = "Copy Paste"
local APP_VERSION = "0.4"

--------------------------------------------------------------------------------
-- Global state for storing copied data
--------------------------------------------------------------------------------
local copied_data = nil
local last_selection = nil
local copy_dialog = nil
local paste_dialog = nil
local load_confirm_dialog = nil
local main_dialog = nil
local save_dialog = nil

--------------------------------------------------------------------------------
-- Keyhandler function (Paketti pattern)
-- Handles Escape key to close dialogs properly
--------------------------------------------------------------------------------
local function create_keyhandler(dialog_getter, dialog_setter)
    return function(dialog, key)
        -- Close on Escape key
        if key.modifiers == "" and key.name == "esc" then
            dialog:close()
            if dialog_setter then
                dialog_setter(nil)
            end
            return nil
        end
        return key
    end
end

-- Default keyhandler for dialogs without specific setters
local function default_keyhandler(dialog, key)
    if key.modifiers == "" and key.name == "esc" then
        dialog:close()
        return nil
    end
    return key
end

--------------------------------------------------------------------------------
-- Utility functions
--------------------------------------------------------------------------------
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

--------------------------------------------------------------------------------
-- Formatting functions
--------------------------------------------------------------------------------
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

local function format_panning(pan_value)
    if pan_value == renoise.PatternLine.EMPTY_PANNING then
        return ".."
    else
        return string.format("%02X", pan_value)
    end
end

local function format_delay(delay_value)
    if delay_value == renoise.PatternLine.EMPTY_DELAY then
        return ".."
    else
        return string.format("%02X", delay_value)
    end
end

local function format_sample_effect(effect_number, effect_amount)
    if effect_number == renoise.PatternLine.EMPTY_EFFECT_NUMBER then
        return "...."
    else
        local amount = effect_amount == renoise.PatternLine.EMPTY_EFFECT_AMOUNT and 0 or effect_amount
        return string.format("%02X%02X", effect_number, amount)
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

--------------------------------------------------------------------------------
-- Parsing functions
--------------------------------------------------------------------------------
local function parse_note(note_str)
    if note_str == "---" then
        return 120 -- Empty note
    elseif note_str == "OFF" then
        return 121 -- Note off
    else
        local note_names = {
            ["C-"] = 0, ["C#"] = 1, ["D-"] = 2, ["D#"] = 3,
            ["E-"] = 4, ["F-"] = 5, ["F#"] = 6, ["G-"] = 7,
            ["G#"] = 8, ["A-"] = 9, ["A#"] = 10, ["B-"] = 11
        }
        local note_name = note_str:sub(1, 2)
        local octave = tonumber(note_str:sub(3, 3))
        if note_names[note_name] and octave then
            return note_names[note_name] + (octave * 12)
        end
    end
    return 120 -- Default to empty
end

local function parse_instrument_value(hex_str)
    if hex_str == ".." then
        return renoise.PatternLine.EMPTY_INSTRUMENT
    else
        local value = tonumber(hex_str, 16)
        if value and value >= 0 and value <= 255 then
            return value
        else
            return renoise.PatternLine.EMPTY_INSTRUMENT
        end
    end
end

local function parse_volume_value(hex_str)
    if hex_str == ".." then
        return renoise.PatternLine.EMPTY_VOLUME
    else
        local value = tonumber(hex_str, 16)
        if value and value >= 0 and value <= 127 then
            return value
        else
            return renoise.PatternLine.EMPTY_VOLUME
        end
    end
end

local function parse_panning_value(hex_str)
    if hex_str == ".." then
        return renoise.PatternLine.EMPTY_PANNING
    else
        local value = tonumber(hex_str, 16)
        if value and value >= 0 and value <= 127 then
            return value
        else
            return renoise.PatternLine.EMPTY_PANNING
        end
    end
end

local function parse_delay_value(hex_str)
    if hex_str == ".." then
        return renoise.PatternLine.EMPTY_DELAY
    else
        local value = tonumber(hex_str, 16)
        if value and value >= 0 and value <= 255 then
            return value
        else
            return renoise.PatternLine.EMPTY_DELAY
        end
    end
end

local function parse_effect_number(hex_str)
    if hex_str == ".." then
        return renoise.PatternLine.EMPTY_EFFECT_NUMBER
    else
        local value = tonumber(hex_str, 16)
        if value and value >= 0 and value <= 35 then
            return value
        else
            return renoise.PatternLine.EMPTY_EFFECT_NUMBER
        end
    end
end

local function parse_effect_amount(hex_str)
    if hex_str == ".." then
        return renoise.PatternLine.EMPTY_EFFECT_AMOUNT
    else
        local value = tonumber(hex_str, 16)
        if value and value >= 0 and value <= 255 then
            return value
        else
            return renoise.PatternLine.EMPTY_EFFECT_AMOUNT
        end
    end
end

-- Parse selection info from pattern data header
local function parse_selection_info(text_data)
    local lines = {}
    for line in text_data:gmatch("[^\n]+") do
        table.insert(lines, line)
    end

    for _, line in ipairs(lines) do
        local start_line, end_line, start_track, end_track = line:match("Selection: L(%d+)%-(%d+) T(%d+)%-(%d+)")
        if start_line then
            return {
                start_line = tonumber(start_line),
                end_line = tonumber(end_line),
                start_track = tonumber(start_track),
                end_track = tonumber(end_track)
            }
        end
    end
    return nil
end

--------------------------------------------------------------------------------
-- Copy Selection to Text
--------------------------------------------------------------------------------
local function copy_selection_to_text(show_dialog)
    local selection = get_current_selection()
    if not selection then
        renoise.app():show_status("No selection to copy")
        return nil
    end

    last_selection = selection

    local song = renoise.song()
    local pattern = song.selected_pattern
    local transport = song.transport
    local output = {}

    -- Header with more context (Paketti-style: include useful song info)
    table.insert(output, "=== RENOISE PATTERN DATA ===")
    table.insert(output, "Format: CopyPaste-V2")
    table.insert(output, string.format("BPM: %d | LPB: %d | Pattern: %02d | Lines: %d",
        transport.bpm, transport.lpb, song.selected_pattern_index, pattern.number_of_lines))
    table.insert(output, string.format("Selection: L%03d-%03d T%03d-%03d",
        selection.start_line, selection.end_line,
        selection.start_track, selection.end_track))
    table.insert(output, "")

    -- Track names with column info
    local track_header = "Line"
    for track_idx = selection.start_track, selection.end_track do
        local track = song.tracks[track_idx]
        local note_cols = track.visible_note_columns
        local fx_cols = track.visible_effect_columns
        track_header = track_header .. string.format(" | T%02d:%s (N:%d F:%d)", 
            track_idx, track.name, note_cols, fx_cols)
    end
    table.insert(output, track_header)
    table.insert(output, "")

    -- Pattern data
    for line_idx = selection.start_line, selection.end_line do
        local line_str = string.format("%03d", line_idx)

        for track_idx = selection.start_track, selection.end_track do
            local track = pattern:track(track_idx)
            local line = track:line(line_idx)
            local song_track = song.tracks[track_idx]

            line_str = line_str .. " |"

            -- Note columns (with all sub-columns)
            local visible_note_cols = song_track.visible_note_columns
            for col_idx = 1, math.max(1, visible_note_cols) do
                if col_idx <= #line.note_columns then
                    local note_col = line.note_columns[col_idx]
                    local note = format_note(note_col.note_value)
                    local instr = format_instrument(note_col.instrument_value)
                    local vol = format_volume(note_col.volume_value)
                    local pan = format_panning(note_col.panning_value)
                    local dly = format_delay(note_col.delay_value)
                    local sfx = format_sample_effect(note_col.effect_number_value, note_col.effect_amount_value)
                    line_str = line_str .. string.format(" %s %s %s %s %s %s", note, instr, vol, pan, dly, sfx)
                else
                    line_str = line_str .. " --- .. .. .. .. ...."
                end
            end

            -- Effect columns
            local visible_fx_cols = song_track.visible_effect_columns
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

    local lines_count = selection.end_line - selection.start_line + 1
    local tracks_count = selection.end_track - selection.start_track + 1
    log("Selection copied (" .. lines_count .. " lines, " .. tracks_count .. " tracks)")
    renoise.app():show_status(string.format("Pattern data copied: %d lines, %d tracks", lines_count, tracks_count))

    -- Show copy dialog only if requested
    if show_dialog ~= false then
        show_copy_dialog(copied_data)
    end
    
    return copied_data
end

--------------------------------------------------------------------------------
-- Apply Text Data (Paste)
-- mix_paste_mode: if true, only paste into empty cells (Impulse Tracker style)
--------------------------------------------------------------------------------
local function apply_text_data(text_data, use_file_dimensions, mix_paste_mode)
    if not text_data or text_data == "" then
        renoise.app():show_status("No data to paste")
        return false
    end
    
    mix_paste_mode = mix_paste_mode or false

    local selection
    if use_file_dimensions then
        -- Parse selection from file data and use it directly
        selection = parse_selection_info(text_data)
        if not selection then
            renoise.app():show_status("Could not parse selection info from file")
            return false
        end
        log("Loading pattern with file dimensions: L" .. selection.start_line .. "-" .. selection.end_line ..
            " T" .. selection.start_track .. "-" .. selection.end_track)
    else
        -- Use current selection
        selection = get_current_selection()
        if not selection then
            renoise.app():show_status("No selection for pasting")
            return false
        end
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

    -- Add undo point (Paketti pattern)
    song:describe_undo("Paste Pattern Data")

    local pattern = song.selected_pattern
    local paste_line = selection.start_line
    local lines_processed = 0
    local errors_encountered = 0

    log("Starting paste operation: " .. (data_end - data_start + 1) .. " lines to process")

    -- Paste data
    for i = data_start, data_end do
        if paste_line > selection.end_line then break end
        if paste_line > pattern.number_of_lines then break end

        local line_data = lines[i]
        local line_num = tonumber(line_data:sub(1, 3))

        if line_num then
            local track_idx = selection.start_track

            -- Parse track data
            for track_data in line_data:gmatch("|([^|]*)") do
                if track_idx > selection.end_track then break end
                if track_idx > #song.tracks then break end

                local success, error_msg = pcall(function()
                    local track = pattern:track(track_idx)
                    local line = track:line(paste_line)
                    local song_track = song.tracks[track_idx]

                    -- Parse note columns and effects from track_data
                    local parts = {}
                    for part in track_data:gmatch("%S+") do
                        table.insert(parts, part)
                    end

                    -- Apply multi-column note data
                    -- New format: Note Instr Vol Pan Delay SampleFX (6 parts per note column)
                    local visible_note_cols = song_track.visible_note_columns
                    local note_col_idx = 1
                    local part_idx = 1

                    -- Process note columns (groups of 6: note, instrument, volume, panning, delay, sample_fx)
                    while note_col_idx <= visible_note_cols and part_idx + 5 <= #parts do
                        if note_col_idx <= #line.note_columns then
                            local note_col = line.note_columns[note_col_idx]
                            
                            -- Mix-paste mode: only paste into empty cells (Impulse Tracker Alt-M style)
                            local should_paste = true
                            if mix_paste_mode and not note_col.is_empty then
                                should_paste = false
                            end
                            
                            if should_paste then
                                note_col.note_value = parse_note(parts[part_idx])
                                note_col.instrument_value = parse_instrument_value(parts[part_idx + 1])
                                note_col.volume_value = parse_volume_value(parts[part_idx + 2])
                                note_col.panning_value = parse_panning_value(parts[part_idx + 3])
                                note_col.delay_value = parse_delay_value(parts[part_idx + 4])
                                -- Sample effect (parts[part_idx + 5])
                                local sfx_str = parts[part_idx + 5]
                                if sfx_str and sfx_str ~= "...." and #sfx_str >= 4 then
                                    note_col.effect_number_value = parse_effect_number(sfx_str:sub(1, 2))
                                    note_col.effect_amount_value = parse_effect_amount(sfx_str:sub(3, 4))
                                else
                                    note_col.effect_number_value = renoise.PatternLine.EMPTY_EFFECT_NUMBER
                                    note_col.effect_amount_value = renoise.PatternLine.EMPTY_EFFECT_AMOUNT
                                end
                            end
                        end
                        note_col_idx = note_col_idx + 1
                        part_idx = part_idx + 6
                    end

                    -- Apply multi-column effect data
                    local visible_fx_cols = song_track.visible_effect_columns
                    local fx_col_idx = 1

                    -- Process effect columns (starting after note columns)
                    while fx_col_idx <= visible_fx_cols and part_idx <= #parts do
                        if fx_col_idx <= #line.effect_columns then
                            local fx_col = line.effect_columns[fx_col_idx]
                            
                            -- Mix-paste mode: only paste into empty cells
                            local should_paste_fx = true
                            if mix_paste_mode and not fx_col.is_empty then
                                should_paste_fx = false
                            end
                            
                            if should_paste_fx then
                                local effect_str = parts[part_idx]
                                if effect_str and effect_str ~= "...." and #effect_str >= 4 then
                                    fx_col.number_value = parse_effect_number(effect_str:sub(1, 2))
                                    fx_col.amount_value = parse_effect_amount(effect_str:sub(3, 4))
                                else
                                    fx_col.number_value = renoise.PatternLine.EMPTY_EFFECT_NUMBER
                                    fx_col.amount_value = renoise.PatternLine.EMPTY_EFFECT_AMOUNT
                                end
                            end
                        end
                        fx_col_idx = fx_col_idx + 1
                        part_idx = part_idx + 1
                    end
                end)

                if not success then
                    errors_encountered = errors_encountered + 1
                    log("Error processing track " .. track_idx .. " at line " .. paste_line .. ": " .. tostring(error_msg))
                end

                track_idx = track_idx + 1
            end
            lines_processed = lines_processed + 1
        end

        paste_line = paste_line + 1
    end

    local mode_str = mix_paste_mode and " (mix-paste: empty cells only)" or ""
    if errors_encountered > 0 then
        log("Pattern data pasted with " .. errors_encountered .. " errors (" .. lines_processed .. " lines processed)" .. mode_str)
        renoise.app():show_status("Pattern data pasted with " .. errors_encountered .. " errors" .. mode_str)
    else
        log("Pattern data pasted successfully (" .. lines_processed .. " lines processed)" .. mode_str)
        renoise.app():show_status("Pattern data pasted successfully (" .. lines_processed .. " lines)" .. mode_str)
    end
    return true
end

--------------------------------------------------------------------------------
-- Mix-Paste from clipboard buffer (Impulse Tracker Alt-M style)
-- Only pastes into empty cells
--------------------------------------------------------------------------------
local function mix_paste_from_buffer()
    if not copied_data then
        renoise.app():show_status("No pattern data in buffer. Copy a selection first.")
        return
    end
    
    local success = apply_text_data(copied_data, false, true)
    if not success then
        renoise.app():show_status("Mix-paste failed")
    end
end

--------------------------------------------------------------------------------
-- Dialog Functions
--------------------------------------------------------------------------------
function show_copy_dialog(text_data)
    -- Close existing dialog if open (Paketti pattern)
    if copy_dialog and copy_dialog.visible then
        copy_dialog:close()
        copy_dialog = nil
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
            text = "Copy this text to share with AI assistants (ChatGPT, Claude, etc.):"
        },

        vb:multiline_textfield {
            text = text_data,
            width = 700,
            height = 400,
            edit_mode = false,
            font = "mono"
        },

        vb:horizontal_aligner {
            mode = "center",
            spacing = 10,
            
            vb:button {
                text = "Copy Again",
                width = 100,
                notifier = function()
                    copy_selection_to_text(false)
                    if copy_dialog and copy_dialog.visible then
                        copy_dialog:close()
                        copy_dialog = nil
                    end
                    show_copy_dialog(copied_data)
                end
            },
            
            vb:button {
                text = "Close",
                width = 100,
                notifier = function()
                    if copy_dialog then 
                        copy_dialog:close() 
                        copy_dialog = nil
                    end
                end
            }
        }
    }

    -- Create keyhandler that sets copy_dialog to nil on close
    local keyhandler = function(dialog, key)
        if key.modifiers == "" and key.name == "esc" then
            dialog:close()
            copy_dialog = nil
            return nil
        end
        return key
    end

    copy_dialog = renoise.app():show_custom_dialog("Copy Pattern Data", dialog_content, keyhandler)
    
    -- Paketti pattern: Reset middle frame to ensure keyboard focus returns to Renoise
    renoise.app().window.active_middle_frame = renoise.app().window.active_middle_frame
end

function show_paste_dialog()
    -- Close existing dialog if open
    if paste_dialog and paste_dialog.visible then
        paste_dialog:close()
        paste_dialog = nil
    end

    local vb = renoise.ViewBuilder()

    local text_field = vb:multiline_textfield {
        text = copied_data or "",
        width = 700,
        height = 400,
        edit_mode = true,
        font = "mono"
    }

    local dialog_content = vb:column {
        margin = 10,
        spacing = 10,

        vb:text {
            text = "Paste Pattern Data",
            font = "big",
            style = "strong"
        },

        vb:text {
            text = "Paste pattern data text here (from AI assistant or file) and click Apply:"
        },

        text_field,

        vb:horizontal_aligner {
            mode = "center",
            spacing = 10,

            vb:button {
                text = "Paste (Overwrite)",
                width = 120,
                notifier = function()
                    local success = apply_text_data(text_field.text, false, false)
                    if success and paste_dialog then
                        paste_dialog:close()
                        paste_dialog = nil
                    end
                end
            },

            vb:button {
                text = "Mix-Paste (Empty Only)",
                width = 140,
                notifier = function()
                    local success = apply_text_data(text_field.text, false, true)
                    if success and paste_dialog then
                        paste_dialog:close()
                        paste_dialog = nil
                    end
                end
            },

            vb:button {
                text = "Cancel",
                width = 80,
                notifier = function()
                    if paste_dialog then 
                        paste_dialog:close() 
                        paste_dialog = nil
                    end
                end
            }
        },
        
        vb:text {
            text = "Mix-Paste: Only fills empty cells, preserves existing data (Impulse Tracker Alt-M style)"
        }
    }

    local keyhandler = function(dialog, key)
        if key.modifiers == "" and key.name == "esc" then
            dialog:close()
            paste_dialog = nil
            return nil
        end
        return key
    end

    paste_dialog = renoise.app():show_custom_dialog("Paste Pattern Data", dialog_content, keyhandler)
    
    -- Paketti pattern: Reset middle frame
    renoise.app().window.active_middle_frame = renoise.app().window.active_middle_frame
end

--------------------------------------------------------------------------------
-- File I/O functions
--------------------------------------------------------------------------------
local function save_pattern_to_file(filename, pattern_data)
    local file, err = io.open(filename, "w")
    if not file then
        renoise.app():show_error("Failed to save file: " .. tostring(err))
        return false
    end

    file:write(pattern_data)
    file:close()
    return true
end

local function load_pattern_from_file(filename)
    local file, err = io.open(filename, "r")
    if not file then
        renoise.app():show_error("Failed to load file: " .. tostring(err))
        return nil
    end

    local content = file:read("*all")
    file:close()
    return content
end

local function show_save_dialog()
    if not copied_data then
        renoise.app():show_status("No pattern data to save. Copy a selection first.")
        return
    end

    -- Close existing if open
    if save_dialog and save_dialog.visible then
        save_dialog:close()
        save_dialog = nil
    end

    -- Parse current data to show info
    local file_selection = parse_selection_info(copied_data)
    local data_size = string.len(copied_data)

    if not file_selection then
        renoise.app():show_error("Invalid pattern data format")
        return
    end

    local lines_count = file_selection.end_line - file_selection.start_line + 1
    local tracks_count = file_selection.end_track - file_selection.start_track + 1

    local vb = renoise.ViewBuilder()

    local info_text = string.format(
        "Pattern Info:\n" ..
        "• Lines: %d-%d (%d lines)\n" ..
        "• Tracks: %d-%d (%d tracks)\n" ..
        "• Data size: %d bytes",
        file_selection.start_line, file_selection.end_line, lines_count,
        file_selection.start_track, file_selection.end_track, tracks_count,
        data_size
    )

    local dialog_content = vb:column {
        margin = 10,
        spacing = 10,

        vb:text {
            text = "Save Pattern to File",
            font = "big",
            style = "strong"
        },

        vb:text {
            text = info_text
        },

        vb:horizontal_aligner {
            mode = "center",
            spacing = 10,

            vb:button {
                text = "Save As...",
                width = 100,
                notifier = function()
                    local filename = renoise.app():prompt_for_filename_to_write({ "regpat", "txt" }, "Save Pattern Data")
                    if filename then
                        -- Add .regpat extension if no extension provided
                        if not filename:match("%.%w+$") then
                            filename = filename .. ".regpat"
                        end

                        if save_pattern_to_file(filename, copied_data) then
                            renoise.app():show_status("Pattern saved to: " .. filename)
                            log("Pattern data saved to file: " .. filename)
                            if save_dialog then
                                save_dialog:close()
                                save_dialog = nil
                            end
                        else
                            renoise.app():show_error("Failed to save pattern to: " .. filename)
                        end
                    end
                end
            },

            vb:button {
                text = "Cancel",
                width = 100,
                notifier = function()
                    if save_dialog then
                        save_dialog:close()
                        save_dialog = nil
                    end
                end
            }
        }
    }

    local keyhandler = function(dialog, key)
        if key.modifiers == "" and key.name == "esc" then
            dialog:close()
            save_dialog = nil
            return nil
        end
        return key
    end

    save_dialog = renoise.app():show_custom_dialog("Save Pattern", dialog_content, keyhandler)
    renoise.app().window.active_middle_frame = renoise.app().window.active_middle_frame
end

local function show_load_confirmation_dialog(pattern_data, filename)
    -- Close existing if open
    if load_confirm_dialog and load_confirm_dialog.visible then
        load_confirm_dialog:close()
        load_confirm_dialog = nil
    end

    local file_selection = parse_selection_info(pattern_data)
    if not file_selection then
        renoise.app():show_error("Could not parse pattern dimensions from file")
        return
    end

    local vb = renoise.ViewBuilder()

    local lines_count = file_selection.end_line - file_selection.start_line + 1
    local tracks_count = file_selection.end_track - file_selection.start_track + 1

    -- Extract just the filename for display
    local display_filename = filename:match("([^/\\]+)$") or filename

    local dialog_content = vb:column {
        margin = 10,
        spacing = 10,

        vb:text {
            text = "Load Pattern Confirmation",
            font = "big",
            style = "strong"
        },

        vb:text {
            text = "File: " .. display_filename
        },

        vb:text {
            text = "Pattern Dimensions:"
        },

        vb:text {
            text = "• Lines: " .. file_selection.start_line .. "-" .. file_selection.end_line .. " (" .. lines_count .. " lines)"
        },

        vb:text {
            text = "• Tracks: " .. file_selection.start_track .. "-" .. file_selection.end_track .. " (" .. tracks_count .. " tracks)"
        },

        vb:text {
            text = "\nThis will overwrite the current pattern data in the specified range.",
            style = "strong"
        },

        vb:horizontal_aligner {
            mode = "center",
            spacing = 10,

            vb:button {
                text = "Load Pattern",
                width = 100,
                notifier = function()
                    local success = apply_text_data(pattern_data, true)
                    if success then
                        renoise.app():show_status("Pattern loaded and applied from: " .. display_filename)
                        log("Pattern data loaded and applied from file: " .. filename)
                    else
                        renoise.app():show_status("Failed to load pattern from: " .. display_filename)
                        log("Failed to apply pattern from file: " .. filename)
                    end
                    if load_confirm_dialog then
                        load_confirm_dialog:close()
                        load_confirm_dialog = nil
                    end
                end
            },

            vb:button {
                text = "Cancel",
                width = 100,
                notifier = function()
                    if load_confirm_dialog then
                        load_confirm_dialog:close()
                        load_confirm_dialog = nil
                    end
                end
            }
        }
    }

    local keyhandler = function(dialog, key)
        if key.modifiers == "" and key.name == "esc" then
            dialog:close()
            load_confirm_dialog = nil
            return nil
        end
        return key
    end

    load_confirm_dialog = renoise.app():show_custom_dialog("Load Pattern", dialog_content, keyhandler)
    renoise.app().window.active_middle_frame = renoise.app().window.active_middle_frame
end

local function show_load_dialog()
    local filename = renoise.app():prompt_for_filename_to_read({ "regpat", "txt" }, "Load Pattern Data")
    if filename then
        local pattern_data = load_pattern_from_file(filename)
        if pattern_data then
            copied_data = pattern_data
            show_load_confirmation_dialog(pattern_data, filename)
        end
    end
end

--------------------------------------------------------------------------------
-- Main Dialog
--------------------------------------------------------------------------------
local function show_main_dialog()
    -- Close existing if open
    if main_dialog and main_dialog.visible then
        main_dialog:close()
        main_dialog = nil
    end

    local vb = renoise.ViewBuilder()

    local dialog_content = vb:column {
        margin = 10,
        spacing = 8,

        vb:text {
            text = APP_NAME .. " v" .. APP_VERSION,
            font = "big",
            style = "strong"
        },

        vb:text {
            text = "Pattern copy & paste tool for AI collaboration"
        },

        vb:space { height = 5 },

        vb:horizontal_aligner {
            mode = "center",

            vb:column {
                spacing = 5,

                vb:row {
                    spacing = 5,
                    vb:button {
                        text = "Copy Selection",
                        width = 100,
                        height = 30,
                        notifier = function() 
                            copy_selection_to_text(true) 
                        end
                    },

                    vb:button {
                        text = "Paste Data",
                        width = 100,
                        height = 30,
                        notifier = show_paste_dialog
                    }
                },

                vb:row {
                    spacing = 5,
                    vb:button {
                        text = "Save to File",
                        width = 100,
                        height = 30,
                        notifier = show_save_dialog
                    },

                    vb:button {
                        text = "Load from File",
                        width = 100,
                        height = 30,
                        notifier = show_load_dialog
                    }
                }
            }
        },

        vb:space { height = 5 },

        vb:text {
            text = "Instructions:\n" ..
                "1. Select pattern data in Pattern Editor (Ctrl+A for all)\n" ..
                "2. Click 'Copy Selection' to generate shareable text\n" ..
                "3. Share text with AI (ChatGPT, Claude, etc.)\n" ..
                "4. Paste AI's modified text back using 'Paste Data'\n" ..
                "\n" ..
                "Features:\n" ..
                "• Full note columns: Note, Instr, Vol, Pan, Delay, SampleFX\n" ..
                "• Mix-Paste: Only fills empty cells (Impulse Tracker Alt-M)\n" ..
                "• Save/Load .regpat files for offline storage\n" ..
                "• Undo integration (Ctrl+Z to revert)"
        }
    }

    local keyhandler = function(dialog, key)
        if key.modifiers == "" and key.name == "esc" then
            dialog:close()
            main_dialog = nil
            return nil
        end
        return key
    end

    main_dialog = renoise.app():show_custom_dialog(APP_NAME, dialog_content, keyhandler)
    
    -- Paketti pattern: Reset middle frame to ensure keyboard focus
    renoise.app().window.active_middle_frame = renoise.app().window.active_middle_frame
end

--------------------------------------------------------------------------------
-- Quick copy without dialog (for fast workflow)
--------------------------------------------------------------------------------
local function quick_copy_selection()
    local data = copy_selection_to_text(false)
    if data then
        renoise.app():show_status("Pattern data copied to clipboard buffer")
    end
end

--------------------------------------------------------------------------------
-- Menu entries
--------------------------------------------------------------------------------
renoise.tool():add_menu_entry { 
    name = "Main Menu:Tools:" .. APP_NAME .. "...", 
    invoke = show_main_dialog 
}

renoise.tool():add_menu_entry { 
    name = "Pattern Editor:" .. APP_NAME .. ":Copy Selection to Text...", 
    invoke = function() copy_selection_to_text(true) end 
}

renoise.tool():add_menu_entry { 
    name = "Pattern Editor:" .. APP_NAME .. ":Quick Copy (No Dialog)", 
    invoke = quick_copy_selection 
}

renoise.tool():add_menu_entry { 
    name = "Pattern Editor:" .. APP_NAME .. ":Paste Text Data...", 
    invoke = show_paste_dialog 
}

renoise.tool():add_menu_entry { 
    name = "Pattern Editor:" .. APP_NAME .. ":Save Pattern to File...", 
    invoke = show_save_dialog 
}

renoise.tool():add_menu_entry { 
    name = "Pattern Editor:" .. APP_NAME .. ":Load Pattern from File...", 
    invoke = show_load_dialog 
}

renoise.tool():add_menu_entry { 
    name = "Pattern Editor:" .. APP_NAME .. ":Mix-Paste (Empty Cells Only)", 
    invoke = mix_paste_from_buffer 
}

--------------------------------------------------------------------------------
-- Keybindings
--------------------------------------------------------------------------------
renoise.tool():add_keybinding { 
    name = "Pattern Editor:" .. APP_NAME .. ":Show Main Dialog", 
    invoke = show_main_dialog 
}

renoise.tool():add_keybinding { 
    name = "Pattern Editor:" .. APP_NAME .. ":Copy Selection to Text", 
    invoke = function() copy_selection_to_text(true) end 
}

renoise.tool():add_keybinding { 
    name = "Pattern Editor:" .. APP_NAME .. ":Quick Copy (No Dialog)", 
    invoke = quick_copy_selection 
}

renoise.tool():add_keybinding { 
    name = "Pattern Editor:" .. APP_NAME .. ":Paste Text Data", 
    invoke = show_paste_dialog 
}

renoise.tool():add_keybinding { 
    name = "Pattern Editor:" .. APP_NAME .. ":Save Pattern to File", 
    invoke = show_save_dialog 
}

renoise.tool():add_keybinding { 
    name = "Pattern Editor:" .. APP_NAME .. ":Load Pattern from File", 
    invoke = show_load_dialog 
}

renoise.tool():add_keybinding { 
    name = "Pattern Editor:" .. APP_NAME .. ":Mix-Paste (Empty Cells Only)", 
    invoke = mix_paste_from_buffer 
}

--------------------------------------------------------------------------------
-- MIDI Mappings (Paketti pattern)
--------------------------------------------------------------------------------
renoise.tool():add_midi_mapping {
    name = APP_NAME .. ":Copy Selection to Text",
    invoke = function(message)
        if message:is_trigger() then
            copy_selection_to_text(true)
        end
    end
}

renoise.tool():add_midi_mapping {
    name = APP_NAME .. ":Quick Copy (No Dialog)",
    invoke = function(message)
        if message:is_trigger() then
            quick_copy_selection()
        end
    end
}

renoise.tool():add_midi_mapping {
    name = APP_NAME .. ":Paste Text Data",
    invoke = function(message)
        if message:is_trigger() then
            show_paste_dialog()
        end
    end
}

renoise.tool():add_midi_mapping {
    name = APP_NAME .. ":Show Main Dialog",
    invoke = function(message)
        if message:is_trigger() then
            show_main_dialog()
        end
    end
}

renoise.tool():add_midi_mapping {
    name = APP_NAME .. ":Mix-Paste (Empty Cells Only)",
    invoke = function(message)
        if message:is_trigger() then
            mix_paste_from_buffer()
        end
    end
}

--------------------------------------------------------------------------------
-- Startup
--------------------------------------------------------------------------------
log(APP_NAME .. " v" .. APP_VERSION .. " loaded successfully")
log("Features: Full note columns, multi-track, mix-paste, file I/O, MIDI mappings")
