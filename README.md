# Simple Copy Paste Tool for Renoise - Usage Guide

## Overview

This is an early draft of a copy-paste tool for Renoise that allows you to copy pattern selections as text and paste them back. It focuses on core functionality without complex features, ensuring reliability and ease of use.
The final goal is to support full format specified in FORMAT_SPECIFICATION.md (under review, matter of change).

## Installation

1. Copy the entire `com.psychedel.CopyPaste.xrnx` folder to your Renoise Tools directory:
   - **Windows**: `%APPDATA%\Renoise\V3.x.x\Scripts\Tools\`
   - **macOS**: `~/Library/Preferences/Renoise/V3.x.x/Scripts/Tools/`
   - **Linux**: `~/.renoise/V3.x.x/Scripts/Tools/`

2. Restart Renoise or use "Tools > Reload All Tools"

## Features

### Core Functions
- **Copy Selection to Text**: Converts your pattern selection to a human-readable text format
- **Paste Text to Selection**: Applies text data back to your current selection
- **Clipboard Integration**: Automatically copies to system clipboard
- **Simple Format**: Easy to read and edit text representation

### What Gets Copied
- Note data (note, instrument, volume)
- Effect commands
- Track names and selection info
- Pattern line numbers

## How to Use

### Basic Workflow

1. **Select Pattern Area**
   - In the Pattern Editor, select the area you want to copy
   - Can be single or multiple tracks
   - Can be any number of lines

2. **Copy to Text**
   - Use menu: `Pattern Editor > Copy Selection as Text`
   - Or: `Main Menu > Tools > Simple Copy Paste...` then click "Copy Selection to Text"
   - Text is automatically copied to your clipboard

3. **Paste from Text**
   - Select destination area in Pattern Editor
   - Use menu: `Pattern Editor > Paste Text to Selection`
   - Or: `Main Menu > Tools > Simple Copy Paste...` then click "Paste Text to Selection"

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
- `Main Menu > Tools > Simple Copy Paste...` - Opens main dialog
- `Main Menu > Tools > Simple Copy Paste > Copy Selection to Text`
- `Main Menu > Tools > Simple Copy Paste > Paste Text to Selection`

### Pattern Editor
- `Pattern Editor > Copy Selection as Text`
- `Pattern Editor > Paste Text to Selection`

## Keyboard Shortcuts

You can assign keyboard shortcuts through:
1. `Edit > Preferences > Keys`
2. Look for:
   - `Pattern Editor > Tools > Copy Selection as Text`
   - `Pattern Editor > Tools > Paste Text to Selection`

## Tips and Best Practices

### For Music Production
- Copy drum patterns to share with collaborators
- Save pattern variations as text files
- Copy complex effect chains for reuse
- Share musical ideas via text (Discord, forums, etc.)

### For AI Collaboration
- The text format is perfect for sharing with AI assistants
- You can describe changes in plain text
- AI can help analyze and modify patterns
- Easy to version control with Git

### Editing Text Manually
- Use any text editor to modify the pattern data
- Maintain the exact format structure
- Be careful with spacing and separators (`|`)
- Test small changes first

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
- Limited to visible note/effect columns
- No advanced formatting options
