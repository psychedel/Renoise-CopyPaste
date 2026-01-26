# Copy Paste Tool for Renoise - AI Collaboration Edition

## Overview

An enhanced copy-paste tool for Renoise that allows you to copy pattern selections as human-readable text, share them with AI assistants (ChatGPT, Claude, etc.), and paste modified patterns back. Includes save/load functionality for `.regpat` files, plus a fast file-based Paketti Clipboard system.

**Version:** 0.5  
**API Version:** 6+  
**Author:** Psychedel (enhanced with Paketti patterns)

## Features

### Core Functions
- **Copy Selection to Text**: Convert pattern data to shareable text format
- **Paste Text Data**: Apply text pattern data back to Renoise
- **Mix-Paste**: Only paste into empty cells (Impulse Tracker Alt-M style)
- **Quick Copy (No Dialog)**: Fast copy without opening dialog
- **Save/Load Pattern Files**: Export and import patterns as `.regpat` files
- **AI Collaboration Workflow**: Designed for sharing with AI assistants

### Paketti Clipboard (NEW)
- **Paketti Copy**: Copies selection to a persistent clipboard file (no dialog)
- **Paketti Cut**: Copies to clipboard and clears the selection
- **Paketti Paste**: Pastes from clipboard to current selection
- **Paketti Mix-Paste**: Pastes from clipboard into empty cells only
- **Persistent**: Works across Renoise sessions (file-based storage)

### Pattern Data Support
- **Full Note Columns**: Note, Instrument, Volume, Panning, Delay, Sample Effects
- **Multiple Note Columns**: All visible note columns per track
- **Effect Columns**: All visible effect columns per track
- **Multiple Tracks**: Copy across any number of tracks
- **Song Context**: BPM, LPB, pattern number included in header

### Technical Features
- **Undo Integration**: All paste operations create undo points
- **MIDI Mappings**: Control via MIDI controllers
- **Keyboard Shortcuts**: Assignable keybindings
- **Dialog Management**: Proper Escape key handling
- **Error Handling**: Graceful error recovery with logging

## Installation

1. Copy the entire folder to your Renoise Tools directory:
   - **Windows**: `%APPDATA%\Renoise\V3.x.x\Scripts\Tools\`
   - **macOS**: `~/Library/Preferences/Renoise/V3.x.x/Scripts/Tools/`
   - **Linux**: `~/.renoise/V3.x.x/Scripts/Tools/`

2. Restart Renoise or use "Tools > Reload All Tools"

## .regpat File Format (V2)

The tool uses an enhanced text format:

```
=== RENOISE PATTERN DATA ===
Format: CopyPaste-V2
BPM: 140 | LPB: 4 | Pattern: 01 | Lines: 64
Selection: L001-016 T001-003

Line | T01:Kick Drum (N:1 F:2) | T02:Snare (N:1 F:1) | T03:Bass (N:2 F:1)

001 | C-4 01 80 40 00 .... 0B40 | --- .. .. .. .. .... .... | C-3 05 7F .. .. .... ....
002 | --- .. .. .. .. .... .... | D-4 02 7F 40 00 .... .... | --- .. .. .. .. .... ....
...
=== END PATTERN DATA ===
```

### Format Elements

**Note Column (6 parts):**
- `C-4` - Note (C-0 to B-9, `---` empty, `OFF` note-off)
- `01` - Instrument (00-FF hex, `..` empty)
- `80` - Volume (00-7F hex, `..` empty)
- `40` - Panning (00-7F hex, `..` empty)
- `00` - Delay (00-FF hex, `..` empty)
- `....` - Sample Effect (XXYY hex, `....` empty)

**Effect Column:**
- `0B40` - Effect command (XXYY hex, `....` empty)

**Note Column (6 parts):**
- `C-4` - Note (C-0 to B-9, `---` empty, `OFF` note-off)
- `01` - Instrument (00-FF hex, `..` empty)
- `80` - Volume (00-7F hex, `..` empty)
- `40` - Panning (00-7F hex, `..` empty)
- `00` - Delay (00-FF hex, `..` empty)
- `....` - Sample Effect (XXYY hex, `....` empty)

### Basic Workflow

1. **Select Pattern Area** in Pattern Editor
   - Use Ctrl+A for entire pattern, or mouse selection

2. **Copy Selection**
   - Menu: `Pattern Editor > Copy Paste > Copy Selection to Text...`
   - Or use assigned keyboard shortcut

3. **Share with AI**
   - Copy the text from the dialog
   - Paste into ChatGPT, Claude, or other AI assistant
   - Ask for modifications (transpose, add variations, etc.)

4. **Paste AI's Response**
   - Select destination area in Pattern Editor
   - Menu: `Pattern Editor > Copy Paste > Paste Text Data...`
   - Paste the AI's modified pattern and click Apply

### Quick Copy Workflow

For faster operation without dialogs:
- Use "Quick Copy (No Dialog)" to copy silently
- Data is stored in memory for pasting

### Mix-Paste Workflow (Impulse Tracker Alt-M Style)

Mix-Paste only fills empty cells, preserving existing data:

1. **Copy your pattern data** (melody, effects, etc.)
2. **Move to destination** with existing content
3. **Use Mix-Paste** instead of regular paste
4. **Result**: New data fills gaps without overwriting existing notes

This is perfect for:
- Layering patterns together
- Adding effects to existing melodies
- Merging multiple pattern clips non-destructively

### File Workflow

**Save Pattern:**
1. Copy a selection first
2. Click "Save to File" or use menu
3. Choose location and filename (`.regpat` extension)

**Load Pattern:**
1. Click "Load from File" or use menu
2. Select `.regpat` or `.txt` file
3. Review confirmation dialog
4. Pattern applies using original file dimensions

### Paketti Clipboard Workflow

The Paketti Clipboard provides fast, no-dialog Cut/Copy/Paste using a persistent file:

**Paketti Copy:**
1. Select pattern area in Pattern Editor
2. Run "Paketti Copy" (via menu, keybinding, or MIDI)
3. Data is saved to `paketti_clipboard.txt` in the tool folder

**Paketti Cut:**
1. Select pattern area in Pattern Editor
2. Run "Paketti Cut"
3. Data is copied to clipboard file, then selection is cleared

**Paketti Paste:**
1. Select destination area in Pattern Editor
2. Run "Paketti Paste"
3. Clipboard data is pasted, overwriting existing content

**Paketti Mix-Paste:**
1. Select destination area with existing content
2. Run "Paketti Mix-Paste"
3. Clipboard data only fills empty cells, preserving existing notes

**Benefits:**
- **No dialogs**: Fast workflow for rapid editing
- **Persistent**: Clipboard survives Renoise restarts
- **Undo support**: All operations create undo points
- **Keybinding friendly**: Assign shortcuts for tracker-style workflow

## Menu Locations

### Main Menu
- `Main Menu > Tools > Copy Paste...` - Opens main dialog

### Pattern Editor Context Menu
- `Pattern Editor > Copy Paste > Copy Selection to Text...`
- `Pattern Editor > Copy Paste > Quick Copy (No Dialog)`
- `Pattern Editor > Copy Paste > Paste Text Data...`
- `Pattern Editor > Copy Paste > Mix-Paste (Empty Cells Only)`
- `Pattern Editor > Copy Paste > Save Pattern to File...`
- `Pattern Editor > Copy Paste > Load Pattern from File...`
- `Pattern Editor > Copy Paste > Paketti Copy`
- `Pattern Editor > Copy Paste > Paketti Cut`
- `Pattern Editor > Copy Paste > Paketti Paste`
- `Pattern Editor > Copy Paste > Paketti Mix-Paste`

## Keyboard Shortcuts

Assign through `Edit > Preferences > Keys`:

- `Pattern Editor:Copy Paste:Show Main Dialog`
- `Pattern Editor:Copy Paste:Copy Selection to Text`
- `Pattern Editor:Copy Paste:Quick Copy (No Dialog)`
- `Pattern Editor:Copy Paste:Paste Text Data`
- `Pattern Editor:Copy Paste:Mix-Paste (Empty Cells Only)`
- `Pattern Editor:Copy Paste:Save Pattern to File`
- `Pattern Editor:Copy Paste:Load Pattern from File`
- `Pattern Editor:Copy Paste:Paketti Copy`
- `Pattern Editor:Copy Paste:Paketti Cut`
- `Pattern Editor:Copy Paste:Paketti Paste`
- `Pattern Editor:Copy Paste:Paketti Mix-Paste`

**Recommended shortcuts:**
- Copy Selection: `Ctrl+Shift+C`
- Quick Copy: `Ctrl+Alt+C`
- Paste Data: `Ctrl+Shift+V`
- Mix-Paste: `Alt+M` (Impulse Tracker style)
- Paketti Copy: `Ctrl+Alt+Shift+C`
- Paketti Cut: `Ctrl+Alt+Shift+X`
- Paketti Paste: `Ctrl+Alt+Shift+V`

## MIDI Mappings

Available in `MIDI Mappings`:

- `Copy Paste:Copy Selection to Text`
- `Copy Paste:Quick Copy (No Dialog)`
- `Copy Paste:Paste Text Data`
- `Copy Paste:Mix-Paste (Empty Cells Only)`
- `Copy Paste:Show Main Dialog`
- `Copy Paste:Paketti Copy`
- `Copy Paste:Paketti Cut`
- `Copy Paste:Paketti Paste`
- `Copy Paste:Paketti Mix-Paste`

## AI Collaboration Tips

### Effective Prompts

```
"Transpose this pattern up 5 semitones"
"Add swing to the hi-hat (vary the delay values)"
"Create a variation with different velocities"
"Double the pattern length with variations"
"Add a bass line that follows this chord progression"
```

### AI Prompt Template

See `AI_COLLABORATION_GUIDE.md` for a complete prompt template to share with AI assistants.

## Troubleshooting

### Common Issues

**"No selection to copy"**
- Make sure you have selected an area in the Pattern Editor

**"No data to paste"**
- Copy some pattern data first, or paste text into the dialog

**"No valid pattern data found"**
- Ensure the text has proper format headers
- Check for `=== RENOISE PATTERN DATA ===` header

**Pasted data looks wrong**
- Verify track column counts match between source and destination
- Check that you're pasting to the correct pattern

### Debug Information

- Check Renoise's console (View > Show Scripting Console) for log messages
- Messages prefixed with `[Copy Paste]`

## Changelog

### v0.5 (Current)
- **Paketti Clipboard**: New file-based Cut/Copy/Paste system
  - `Paketti Copy`: Copies selection to persistent clipboard file
  - `Paketti Cut`: Copies to clipboard and clears selection
  - `Paketti Paste`: Pastes from clipboard to current selection
  - `Paketti Mix-Paste`: Pastes into empty cells only
- Clipboard persists across Renoise sessions (stored in `paketti_clipboard.txt`)
- Updated main dialog with Paketti Clipboard buttons
- Added menu entries, keybindings, and MIDI mappings for all Paketti functions

### v0.4
- **Mix-Paste mode**: Only paste into empty cells (Impulse Tracker Alt-M style)
- Paste dialog now has two buttons: "Paste (Overwrite)" and "Mix-Paste (Empty Only)"
- Dedicated menu entry, keybinding, and MIDI mapping for Mix-Paste
- Status messages indicate when mix-paste mode was used

### v0.3
- Enhanced format with full note column support (Pan, Delay, Sample FX)
- Song context in header (BPM, LPB, Pattern, Lines)
- Track column counts in header (N:x F:y)
- MIDI mappings support
- Quick Copy mode (no dialog)
- Proper Escape key handling in all dialogs
- Keyboard focus restoration after dialogs
- Improved error handling and logging
- Monospace font in text dialogs
- Dialog state management (proper cleanup)

### v0.2
- Multi-column support (note and effect columns)
- File I/O (.regpat format)
- Undo integration

### v0.1
- Initial release
- Basic copy/paste functionality

## License

See LICENSE file.
