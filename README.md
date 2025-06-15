# Simple Copy Paste Tool for Renoise - Usage Guide

## Overview

This is a copy-paste tool for Renoise that allows you to copy pattern selections as text and paste them back.
The final goal is to support full format specified in FORMAT_SPECIFICATION.md (under review, matter of change).

## Installation

1. Copy the entire `com.psychedel.CopyPaste.xrnx` folder to your Renoise Tools directory:
   - **Windows**: `%APPDATA%\Renoise\V3.x.x\Scripts\Tools\`
   - **macOS**: `~/Library/Preferences/Renoise/V3.x.x/Scripts/Tools/`
   - **Linux**: `~/.renoise/V3.x.x/Scripts/Tools/`

2. Restart Renoise or use "Tools > Reload All Tools"

## Features

### Core Functions
- **Dialog-based Copy/Paste**: Text handling for manual editing and sharing
- **Multi-Column Support**: Handles multiple note and effect columns per track
- **Undo Integration**: All paste operations integrate with Renoise's undo system
- **Simple Format**: Easy to read and edit text representation

### What Gets Copied
- Note data (note, instrument, volume) - all visible note columns
- Effect commands - all visible effect columns
- Track names and selection info
- Pattern line numbers
- Full multi-column pattern structure

## How to Use

### Basic Workflow

1. **Select Pattern Area**
   - In the Pattern Editor, select the area you want to copy
   - Use Ctrl+A to select entire pattern, or mouse selection for specific areas
   - Can be single or multiple tracks with multiple columns

2. **Copy with Dialog**
   - Use menu: `Pattern Editor > Copy Selection as Text`
   - View/edit text in dialog and manually copy to clipboard

3. **Paste with Dialog**
   - Select destination area in Pattern Editor
   - Use menu: `Pattern Editor > Paste Text Data`
   - Paste and edit text before applying to pattern
   - Automatically creates undo point

### Text Format Example

```
=== RENOISE PATTERN DATA ===
Format: Simple-V1
Selection: L001-004 T001-002

Line | T01:Track 01 | T02:Track 02

001 | C-5 01 40 0A00 | --- .. .. ....
002 | --- .. .. .... | D-5 02 30 0B10
003 | E-5 01 50 .... | --- .. .. ....
004 | OFF .. .. .... | F-5 03 60 0C20

=== END PATTERN DATA ===
```

### Format Explanation

- **Line numbers**: `001`, `002`, etc.
- **Note format**: `C-5` (note + octave), `---` (empty), `OFF` (note off)
- **Instrument**: `01` (hex), `..` (empty)
- **Volume**: `40` (hex), `..` (empty)
- **Effect**: `0A00` (effect + value), `....` (empty)

## Menu Locations

### Main Menu
- `Main Menu > Tools > Copy Paste...` - Opens main dialog with all options

### Pattern Editor
- `Pattern Editor > Copy Selection as Text` - Copy with dialog
- `Pattern Editor > Paste Text Data` - Paste with dialog

## Keyboard Shortcuts

You can assign keyboard shortcuts through:
1. `Edit > Preferences > Keys`
2. Look for:
   - `Pattern Editor > Tools > Copy Selection as Text`
   - `Pattern Editor > Tools > Paste Text Data`

**Recommended shortcuts:**
- Copy Selection: `Ctrl+Shift+C`
- Paste Data: `Ctrl+Shift+V`

## Tips and Best Practices

### For Music Production
- **Multi-column support**: Copy complex patterns with multiple note/effect columns
- **Undo safety**: All paste operations can be undone with Ctrl+Z
- Copy drum patterns to share with collaborators
- Share musical ideas via text (Discord, forums, etc.)

### For AI Collaboration
- The text format is perfect for sharing with AI assistants
- You can describe changes in plain text and paste results back
- AI can help analyze and modify patterns
- Easy to version control with Git

### Editing Text Manually
- Use any text editor to modify the pattern data
- **Dialog editing**: Use "Paste Text Data" for in-app text editing
- Maintain the exact format structure
- Be careful with spacing and separators (`|`)
- Multi-column data is properly aligned and parsed

## Troubleshooting

### Common Issues

**"No selection to copy"**
- Make sure you have selected an area in the Pattern Editor
- Even a single cell counts as a selection

**"No data to paste"**
- Copy some pattern data first
- Check that clipboard contains valid pattern data

**"No valid pattern data found"**
- Ensure the text format is correct
- Check for proper headers and line numbers
- Verify the `=== RENOISE PATTERN DATA ===` header exists

**Pasted data looks wrong**
- Check that destination selection is appropriate size
- Verify track count matches source data
- Ensure you're pasting to the correct pattern/location

### Debug Information
- Check Renoise's console for error messages
- The tool outputs status messages during operation
- File path: `[Tool Directory]/debug.log` (if available)

## Current Limitations

- Only copies basic pattern data (notes, instruments, volume, effects)
- Does not copy track settings, device chains, or automation
- Copies all visible note/effect columns (no longer limited to first column)
- No advanced formatting options
- Does not preserve column visibility settings on paste
