# Renoise Pattern Data Exchange Format - Specification

## Overview

The Renoise Pattern Data Exchange format is a comprehensive, human-readable text format designed for exchanging complete Renoise pattern data with AI systems. It supports all major Renoise features including native effects, meta devices, routing, automation, and sample modulation while remaining easy to read, edit, and understand by humans.

### Design Goals

- **Complete Feature Coverage**: Supports all Renoise pattern editor and mixing capabilities
- **Human Readable**: Easy to read and manually edit in any text editor
- **AI Optimized**: Structured for efficient processing by language models
- **Native Device Support**: Full access to Renoise's built-in effects and meta devices
- **Lossless**: Preserves all relevant musical and technical information
- **Extensible**: Designed to accommodate future Renoise features
- **Portable**: Platform and Renoise version independent

### Version Information

- **Format Version**: Renoise Pattern Data Exchange
- **Specification Version**: 1.0
- **Target Renoise API**: 6+
- **Encoding**: UTF-8

## Format Structure

The enhanced format consists of distinct sections separated by clear headers:

```
=== RENOISE PATTERN DATA ===
[Header Information]

--- TRACKS ---
[Enhanced Track Definitions]

--- INSTRUMENTS ---
[Enhanced Instrument Definitions]

--- DEVICE CHAINS ---
[Track Device Chain Information]

--- NATIVE EFFECTS ---
[Native Renoise Effects with Parameters]

--- META DEVICES ---
[Meta Devices and Doofers]

--- ROUTING ---
[Send/Group Track Routing]

--- SAMPLE MODULATION ---
[Sample Modulation Sets and Devices]

--- INSTRUMENT PLUGINS ---
[Instrument Plugin Information]

--- PATTERN DATA ---
[Note and Effect Data]

--- AUTOMATION ---
[Enhanced Automation Data]

--- COMMENTS ---
[User Comments and Metadata]

=== END PATTERN DATA ===
```

## Section Specifications

### Header Section

Enhanced header with complete version and capability information:

```
=== RENOISE PATTERN DATA ===
Format: Renoise-Exchange
Renoise: 3.4.2 | API: 6
BPM: 140 | LPB: 4 | TPL: 1
Pattern: 01 | Lines: 64
Selection: L001-064 | T001-008
```

**Enhanced Fields:**
- `Renoise`: Renoise version and API version
- All existing fields from V1 specification

### Enhanced Tracks Section

Complete track information including device counts and column configuration:

```
--- TRACKS ---
T001: "Kick Drum" | Type: SEQUENCER | Color: #FF4444 | Route: Master | Vol: 1.00 | NoteCols: 1 | FXCols: 2 | Visible: Vol,Pan
T002: "Snare" | Color: #44FF44 | Route: Send01 | Vol: 0.85 | Mute: MUTED | Delay: -2.50
T003: "Bass" | Type: GROUP | Route: Master | Vol: 0.90 | Solo: true
```

**Enhanced Properties:**
- `Type`: Track type (SEQUENCER, MASTER, SEND, GROUP)
- `NoteCols`: Number of visible note columns
- `FXCols`: Number of visible effect columns
- `Visible`: Column visibility flags (Vol,Pan,Dly,SmpFX)
- `Delay`: Output delay in milliseconds
- All existing V1 properties

### Enhanced Instruments Section

Complete instrument information including sample and device counts:

```
--- INSTRUMENTS ---
I01: "TR-808 Kick" | Plugin: "Impulse Tracker" | Volume: 1.00 | Samples: 3 | ModSets: 2 | DevChains: 1
I02: "Analog Bass" | Plugin: "Zebra2" | Volume: 0.95 | Transpose: -12 | Samples: 1
I03: "Drum Kit" | Plugin: None | Volume: 1.00 | Samples: 16 | ModSets: 1
```

**Enhanced Properties:**
- `Samples`: Number of sample slots
- `ModSets`: Number of modulation sets
- `DevChains`: Number of device chains
- All existing V1 properties

### Device Chains Section

Visual representation of track effect chains:

```
--- DEVICE CHAINS ---
T001.Chain: ["Compressor" -> "EQ 5" -> "Chorus"]
T002.Chain: ["Gate"(OFF) -> "Delay" -> "Reverb"]
T003.Chain: ["Meta Device" -> "Send"]
```

**Format:**
- Shows complete signal flow
- Inactive devices marked with `(OFF)`
- Mixer device automatically excluded

### Native Effects Section

Detailed native Renoise effects with parameters:

```
--- NATIVE EFFECTS ---
T001.FX2: "Compressor" | Path: Audio/Effects/Native/Compressor | Ratio=4.000 | Attack=0.100 | Release=0.500
T001.FX3: "EQ 5" | Path: Audio/Effects/Native/EQ5 | Low=0.800 | Mid=1.200 | High=0.900 | Preset: "Vocal Enhance"
T002.FX1: "Gate" | Status: BYPASSED | Threshold=0.250 | Release=0.050
```

**Properties:**
- `Path`: Device path for recreation
- `Status`: BYPASSED if inactive
- `Preset`: Active preset name
- Key parameter values
- Optional: All parameters if detailed export enabled

### Meta Devices Section

Meta devices, Doofers, and their internal structure:

```
--- META DEVICES ---
T003.META1: "Custom Doofer" | Type: Doofer | Macros: 8
    -> "Distortion" | Drive=0.750 | Mix=0.800
    -> "Filter" | Cutoff=0.600 | Resonance=0.400
    -> "Delay" | Time=0.250 | Feedback=0.300
    Macro1: "Drive" = 0.750
    Macro2: "Filter Cutoff" = 0.600
    Macro3: "Delay Mix" = 0.150

T004.META1: "Multi-Effect" | Type: Meta Device | Macros: 4
    -> "Chorus" | Rate=0.500 | Depth=0.300
    -> "Reverb" | Size=0.800 | Damping=0.600
```

**Features:**
- Sub-device listing with parameters
- Macro assignments and values
- Support for both Meta Device and Doofer types

### Routing Section

Send tracks, group tracks, and routing assignments:

```
--- ROUTING ---
Send01: "Reverb Send" | Volume: 1.00 | Mute: ACTIVE
Send02: "Delay Send" | Volume: 0.85 | Mute: OFF
Group01: "Drums" | Members: 1,2,3,4
Group02: "Synths" | Members: 5,6,7
T001 -> Master
T002 -> Send01
T003 -> Group01
```

**Components:**
- Send track definitions with volume/mute
- Group track definitions with member lists
- Non-default routing assignments

### Sample Modulation Section

Instrument sample modulation sets and devices:

```
--- SAMPLE MODULATION ---
I01.ModSet1: "Filter Modulation" | Filter: LP Clean | PitchRange: 24
    Inputs: Volume=0.800 | Cutoff=0.600 | Resonance=0.400
    LFO -> Cutoff | Op: MUL | Bipolar: true | Rate=0.250 | Amount=0.600
    Envelope -> Resonance | Op: ADD | Attack=0.100 | Decay=0.300 | Sustain=0.600 | Release=0.800
    Key Tracking -> Volume | Op: MUL | Min=0.000 | Max=1.000

I02.ModSet1: "Pitch Modulation" | Filter: HP Clean
    Velocity Tracking -> Volume | Op: MUL | Mode: SCALE | Min=0.500 | Max=1.000
```

**Features:**
- Filter type specification
- Input parameter values
- Complete modulation device chains
- Device-specific parameters

### Instrument Plugins Section

Loaded instrument plugins with parameters:

```
--- INSTRUMENT PLUGINS ---
I01.Plugin: "Zebra2" | Path: VST/u-he/Zebra2 | Preset: "Lead Pluck" | GUI: Available | Channel: 1
    Osc1 Wave = 0.750000
    Filter Cutoff = 0.600000
    Filter Resonance = 0.400000
    Env1 Attack = 0.100000

I02.Plugin: "Native FM" | Path: Audio/Generator/Native/FM | Channel: 1 | Transpose: -12
    Algorithm = 0.250000
    Modulation = 0.800000
```

**Properties:**
- Complete plugin identification
- Preset information
- GUI availability
- Key parameter values

### Enhanced Pattern Data Section

Multi-column note data with complete effect support:

```
--- PATTERN DATA ---
Line | T001: Kick               | T002: Snare             | T003: Hi-Hat
001  | C-4 01 80 40 00 --- 0B40 | --- -- -- -- -- ---    | --- -- -- -- -- ---
002  | --- -- -- -- -- ---     | --- -- -- -- -- ---    | G#4 03 60 -- -- ---
003  | C-4 01 78 40 00 ---      | C-4 02 7F 40 00 ---    | --- -- -- -- -- ---
004  | --- -- -- -- -- 0C40    | --- -- -- -- -- ---    | G#4 03 58 -- -- 1A20
```

**Enhanced Features:**
- Multiple note columns per track
- Multiple effect columns per track
- Sample effects column support
- Complete volume/panning/delay data

### Enhanced Automation Section

Device-specific automation with play modes:

```
--- AUTOMATION ---
T001.Volume: 001=0.800000 016=1.000000 032=0.600000 048=0.900000
T001.Compressor.Ratio: 001=2.000000 032=8.000000 | Mode: LINES
T002.EQ5.Mid: 001=1.000000 016=1.500000 024=0.800000 032=1.200000 | Mode: CURVES
T003.MetaDevice.Macro1: 001=0.000000 064=1.000000 | Mode: POINTS
```

**Enhanced Features:**
- Device-specific parameter automation
- Automation play modes (POINTS, LINES, CURVES)
- High-precision parameter values
- Meta device macro automation

## Value Encoding

### Enhanced Note Values
Standard musical notation with extended range:
- Note names: C, C#, D, D#, E, F, F#, G, G#, A, A#, B
- Octaves: 0-9 (C-4 = middle C)
- Special values: `OFF` (note off), `---` (empty)

### Parameter Values
High-precision parameter encoding:
- Format: 6-decimal precision (0.000000-1.000000)
- Range mapping: Device-specific min/max values
- Empty values: Device defaults

### Device Paths
Standardized device identification:
- Native effects: `Audio/Effects/Native/[DeviceName]`
- VST plugins: `VST/[Vendor]/[PluginName]`
- Instrument plugins: `Audio/Generator/[Type]/[Name]`

### Color Values
RGB hex notation with alpha support:
- Format: #RRGGBB or #RRGGBBAA
- Range: #000000-#FFFFFF
- Case insensitive

## Native Device Categories

### Core Effects
- **EQ/Filters:** EQ 5, EQ 10, Filter, Comb Filter, DC Offset
- **Dynamics:** Compressor, Gate, Limiter, Multitap, Maximizer
- **Distortion:** Distortion, LoFi, BitCrusher, Exciter, Saturator
- **Time-based:** Delay, Chorus, Flanger, Phaser, Reverb
- **Modulation:** Tremolo, Vibrato, Panbrello, Ring Modulator
- **Utility:** Gainer, Stereo Expander, Send Device, Splitter

### Meta Devices
- **Meta Device:** Container with macro control
- **Doofer:** Advanced meta device with custom interface
- **Multiband Send:** Frequency-split routing
- **Bus Compressor:** Mix bus processing

### Routing Devices
- **Send Device:** Aux send creation
- **Sidechain:** External sidechain input
- **Multiband Send:** Frequency-specific routing

## Implementation Guidelines

### Parsing Rules

1. **Section Processing:** Process sections in order, skip unknown sections
2. **Line Parsing:** Trim whitespace, ignore empty lines
3. **Parameter Extraction:** Use pipe `|` delimiters for properties
4. **Value Parsing:** Support both numeric and string representations
5. **Error Handling:** Graceful degradation for malformed data

### Generation Rules

1. **Consistent Formatting:** Maintain exact spacing and alignment
2. **Zero Padding:** Use leading zeros for indices (T001, I02, etc.)
3. **Section Ordering:** Follow specification order for predictability
4. **Parameter Precision:** Use appropriate precision for parameter types
5. **Optional Sections:** Omit sections with no data

### Validation Rules

1. **Device Paths:** Verify against available devices
2. **Parameter Ranges:** Validate against device specifications
3. **Track References:** Ensure track indices exist
4. **Routing Validity:** Validate send/group assignments
5. **Version Compatibility:** Check API version requirements

## Example Complete Document

```
=== RENOISE PATTERN DATA ===
Format: Renoise-Exchange
Renoise: 3.4.2 | API: 6
BPM: 174 | LPB: 4 | TPL: 1
Pattern: 01 | Lines: 16
Selection: L001-016 | T001-004

--- TRACKS ---
T001: "Kick" | Color: #FF0000 | Route: Master | Vol: 1.00 | NoteCols: 1 | FXCols: 1
T002: "Snare" | Color: #00FF00 | Route: Send01 | Vol: 0.90 | NoteCols: 1 | FXCols: 1
T003: "Bass" | Color: #0000FF | Route: Master | Vol: 0.85 | NoteCols: 1 | FXCols: 2
T004: "Lead" | Route: Send02 | Vol: 0.75 | NoteCols: 2 | FXCols: 1

--- INSTRUMENTS ---
I01: "909 Kick" | Plugin: None | Volume: 1.00 | Samples: 1
I02: "909 Snare" | Plugin: None | Volume: 0.95 | Samples: 1
I03: "Reese Bass" | Plugin: "Operator" | Volume: 0.90 | Transpose: -12
I04: "Acid Lead" | Plugin: "Zebra2" | Volume: 0.80 | Samples: 0

--- DEVICE CHAINS ---
T001.Chain: ["Compressor" -> "EQ 5"]
T002.Chain: ["Gate" -> "Reverb"]
T003.Chain: ["Distortion" -> "Filter" -> "Chorus"]
T004.Chain: ["Delay" -> "Doofer"]

--- NATIVE EFFECTS ---
T001.FX2: "Compressor" | Path: Audio/Effects/Native/Compressor | Ratio=4.000 | Attack=0.100 | Release=0.500
T001.FX3: "EQ 5" | Path: Audio/Effects/Native/EQ5 | Low=0.800 | Mid=1.200 | High=0.900
T002.FX2: "Gate" | Path: Audio/Effects/Native/Gate | Threshold=0.250 | Release=0.050
T003.FX2: "Distortion" | Path: Audio/Effects/Native/Distortion | Drive=0.750 | Mix=0.800
T003.FX3: "Filter" | Path: Audio/Effects/Native/Filter | Cutoff=0.600 | Resonance=0.400

--- META DEVICES ---
T004.META2: "Echo Doofer" | Type: Doofer | Macros: 4
    -> "Delay" | Time=0.250 | Feedback=0.300 | Mix=0.400
    -> "Filter" | Cutoff=0.700 | Resonance=0.200
    Macro1: "Delay Time" = 0.250
    Macro2: "Feedback" = 0.300
    Macro3: "Filter Cutoff" = 0.700

--- ROUTING ---
Send01: "Reverb Send" | Volume: 1.00 | Mute: ACTIVE
Send02: "Delay Send" | Volume: 0.85 | Mute: ACTIVE
T002 -> Send01
T004 -> Send02

--- SAMPLE MODULATION ---
I03.ModSet1: "Bass Filter" | Filter: LP Clean | PitchRange: 24
    Inputs: Volume=0.800 | Cutoff=0.600
    LFO -> Cutoff | Op: MUL | Rate=0.125 | Amount=0.400

--- INSTRUMENT PLUGINS ---
I03.Plugin: "Operator" | Path: VST/Ableton/Operator | Preset: "Reese Bass" | Channel: 1
    Osc A Level = 0.800000
    Filter Freq = 0.600000
    Filter Res = 0.400000

--- PATTERN DATA ---
Line | T001: Kick               | T002: Snare             | T003: Bass              | T004: Lead
001  | C-2 01 80 40 00 ---      | --- -- -- -- -- ---    | C-3 03 7F 40 00 ---    | --- -- -- -- -- ---
002  | --- -- -- -- -- ---      | --- -- -- -- -- ---    | --- -- -- -- -- ---    | C-5 04 70 40 00 ---
003  | --- -- -- -- -- ---      | --- -- -- -- -- ---    | --- -- -- -- -- ---    | --- -- -- -- -- ---
004  | --- -- -- -- -- ---      | --- -- -- -- -- ---    | F-3 03 78 40 00 ---    | --- -- -- -- -- ---
005  | C-2 01 78 40 00 ---      | --- -- -- -- -- ---    | --- -- -- -- -- ---    | --- -- -- -- -- ---
006  | --- -- -- -- -- ---      | C-3 02 7F 40 00 ---    | --- -- -- -- -- ---    | G-5 04 68 40 00 ---
007  | --- -- -- -- -- ---      | --- -- -- -- -- ---    | --- -- -- -- -- ---    | --- -- -- -- -- ---
008  | --- -- -- -- -- ---      | --- -- -- -- -- ---    | C-3 03 75 40 00 ---    | --- -- -- -- -- ---
009  | C-2 01 80 40 00 ---      | --- -- -- -- -- ---    | --- -- -- -- -- ---    | --- -- -- -- -- ---
010  | --- -- -- -- -- ---      | --- -- -- -- -- ---    | --- -- -- -- -- ---    | C-6 04 65 40 00 ---
011  | --- -- -- -- -- ---      | --- -- -- -- -- ---    | --- -- -- -- -- ---    | --- -- -- -- -- ---
012  | --- -- -- -- -- ---      | --- -- -- -- -- ---    | F-3 03 72 40 00 ---    | --- -- -- -- -- ---
013  | C-2 01 7C 40 00 ---      | --- -- -- -- -- ---    | --- -- -- -- -- ---    | --- -- -- -- -- ---
014  | --- -- -- -- -- ---      | C-3 02 7D 40 00 ---    | --- -- -- -- -- ---    | D-6 04 62 40 00 ---
015  | --- -- -- -- -- ---      | --- -- -- -- -- ---    | --- -- -- -- -- ---    | --- -- -- -- -- ---
016  | --- -- -- -- -- ---      | --- -- -- -- -- ---    | C-3 03 70 40 00 ---    | --- -- -- -- -- ---

--- AUTOMATION ---
T003.Filter.Cutoff: 001=0.600000 008=0.900000 016=0.300000 | Mode: LINES
T004.Doofer.Macro1: 001=0.000000 016=1.000000 | Mode: CURVES

--- COMMENTS ---
-- Drum & Bass pattern with filtered bass and delayed lead
-- BPM: 174 (classic D&B tempo)
-- Bass filter automation creates movement
-- Lead delay creates space and width
=== END PATTERN DATA ===
```

## Future Extensions

### Planned Features
- **Phrase Data Support:** Pattern phrase integration
- **Advanced Routing:** Complex signal flow
- **Sample Data:** Embedded sample information
- **MIDI Data:** MIDI controller mappings
- **OSC Integration:** OSC parameter control

### Compatibility Notes
- **Minimum Renoise Version**: 3.0
- **API Version**: 6+
- **Character Encoding**: UTF-8
- **Line Endings**: Platform independent
- **Maximum File Size**: 50MB recommended
