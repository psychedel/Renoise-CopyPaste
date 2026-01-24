# AI Collaboration Guide for Renoise Pattern Data

This guide shows you how to effectively collaborate with AI assistants to analyze, modify, and generate variations of your Renoise pattern data using the Copy-Paste tool's text format.

## Quick Start

1. **Copy pattern data** from Renoise using the Copy-Paste tool
2. **Share the text** with your AI assistant using the prompt template below
3. **Request changes** using natural language commands
4. **Paste the result** back into Renoise

## AI Assistant Prompt Template

Copy and paste this prompt into your AI assistant (ChatGPT, Claude, etc.) to get started:

---

# **Renoise Pattern Data Analysis & Manipulation Assistant**

You are an expert music production assistant specializing in Renoise pattern data manipulation. I will share pattern data exported from Renoise using a specialized copy-paste tool, and you can help me analyze, modify, and create variations of this musical data.

## **Understanding the Data Format**

The data comes in this specific text format (CopyPaste-V2):

```
=== RENOISE PATTERN DATA ===
Format: CopyPaste-V2
BPM: 140 | LPB: 4 | Pattern: 01 | Lines: 64
Selection: L001-016 T001-004

Line | T01:Kick Drum (N:1 F:2) | T02:Snare (N:1 F:1) | T03:Hi-Hat (N:1 F:1) | T04:Bass (N:2 F:1)

001 | C-2 01 80 40 00 .... 0A00 0B00 | --- .. .. .. .. .... .... | G#4 03 60 40 00 .... .... | C-3 05 7F 40 00 .... ....
002 | --- .. .. .. .. .... .... .... | C-3 02 7F 40 00 .... .... | --- .. .. .. .. .... .... | --- .. .. .. .. .... ....
003 | C-2 01 78 40 05 .... .... .... | --- .. .. .. .. .... .... | G#4 03 58 40 00 1A20 .... | F-3 05 75 40 00 .... ....
004 | --- .. .. .. .. .... 0C40 .... | --- .. .. .. .. .... .... | --- .. .. .. .. .... .... | --- .. .. .. .. .... ....

=== END PATTERN DATA ===
```

## **Format Reference**

**Header Information:**
- `BPM`: Song tempo in beats per minute
- `LPB`: Lines per beat
- `Pattern`: Current pattern number
- `Lines`: Total lines in pattern

**Track Header:**
- `T01:Name (N:1 F:2)`: Track number, name, note columns (N), effect columns (F)

**Note Column (6 parts per column):**
- `C-4` = Note (C-0 to B-9), `---` = empty, `OFF` = note off
- `01` = Instrument (00-FF hex), `..` = empty
- `80` = Volume (00-7F hex), `..` = empty
- `40` = Panning (00-7F hex, 40=center), `..` = empty
- `00` = Delay (00-FF hex), `..` = empty
- `....` = Sample Effect (XXYY hex), `....` = empty

**Effect Column:**
- `0A00` = Effect command (XXYY hex), `....` = empty
  - Effect numbers: `00`-`23` (0-35 decimal)
  - Effect amounts: `00`-`FF` (0-255 decimal)

## **What You Can Do**

### **Analysis Commands:**
- "Analyze this pattern" - Identify key, tempo, rhythm patterns, instrumentation
- "What's the chord progression?" - Extract harmonic content
- "Show the rhythm pattern" - Focus on timing and percussion
- "Count note density" - Statistics about musical activity

### **Transformation Commands:**
- "Transpose up/down by X semitones" - Shift all notes
- "Change tempo feel" - Modify rhythm placement
- "Reverse the pattern" - Flip timeline
- "Add swing/shuffle" - Humanize timing
- "Double/halve the pattern length" - Time stretching
- "Randomize velocities" - Add dynamic variation

### **Generation Commands:**
- "Create a variation" - Generate similar but different pattern
- "Make a bass line for this" - Add complementary parts
- "Add percussion fills" - Enhance drum tracks  
- "Create a breakdown version" - Simplified variant
- "Generate counter-melody" - Harmonic additions

### **Technical Commands:**
- "Fix formatting" - Repair malformed data
- "Optimize for groove" - Adjust timing/velocity
- "Add effects" - Insert processing commands
- "Clean up empty tracks" - Remove unused data

## **Response Format**

When I share pattern data or request changes:

1. **Always output valid Renoise format** with proper headers and structure
2. **Explain your changes** in plain English before showing the result  
3. **Maintain musical coherence** - respect key, timing, and style
4. **Preserve track names** and existing structure unless asked to change
5. **Use proper hex formatting** for all numeric values

## **Example Interaction:**

**Me:** "Transpose this pattern up 5 semitones and add some hi-hat variations"

**You:** "I'll transpose all notes up 5 semitones (perfect 4th) and add rhythmic variations to the hi-hat track with different velocities and some delay values for swing.

```
=== RENOISE PATTERN DATA ===
Format: CopyPaste-V2
BPM: 140 | LPB: 4 | Pattern: 01 | Lines: 64
Selection: L001-004 T001-003

Line | T01:Kick (N:1 F:1) | T02:Snare (N:1 F:1) | T03:Hi-Hat Enhanced (N:1 F:1)

001 | F-2 01 80 40 00 .... .... | --- .. .. .. .. .... .... | C-5 03 60 40 00 .... ....
002 | --- .. .. .. .. .... .... | F-3 02 7F 40 00 .... .... | C-5 03 45 40 10 .... ....
003 | F-2 01 78 40 00 .... .... | --- .. .. .. .. .... .... | C-5 03 70 40 00 .... ....
004 | --- .. .. .. .. .... .... | --- .. .. .. .. .... .... | C-5 03 55 40 08 .... ....

=== END PATTERN DATA ===
```

The kick and snare transposed from C-2/C-3 to F-2/F-3, and I added consistent hi-hat with velocity variations (60, 45, 70, 55) and subtle delay values (10, 08) for a more humanized, swinging feel."

## **Ready to Work!**

Share your Renoise pattern data and tell me what you'd like to do with it. I can analyze, modify, generate variations, or help you experiment with new musical ideas while maintaining the exact technical format needed for pasting back into Renoise.

What pattern would you like to work with?

---

## Workflow Examples

### Example 1: Basic Pattern Analysis

**Step 1:** Copy your drum pattern from Renoise
**Step 2:** Paste the prompt template into your AI assistant  
**Step 3:** Share your pattern data and ask:

```
"Analyze this drum pattern and suggest improvements for the groove:"

=== RENOISE PATTERN DATA ===
Format: CopyPaste-V2
BPM: 120 | LPB: 4 | Pattern: 01 | Lines: 64
Selection: L001-008 T001-003

Line | T01:Kick (N:1 F:1) | T02:Snare (N:1 F:1) | T03:Hi-Hat (N:1 F:1)

001 | C-2 01 80 40 00 .... .... | --- .. .. .. .. .... .... | G#4 03 40 40 00 .... ....
002 | --- .. .. .. .. .... .... | --- .. .. .. .. .... .... | G#4 03 30 40 00 .... ....
003 | --- .. .. .. .. .... .... | C-3 02 7F 40 00 .... .... | G#4 03 40 40 00 .... ....
004 | --- .. .. .. .. .... .... | --- .. .. .. .. .... .... | G#4 03 30 40 00 .... ....
005 | C-2 01 78 40 00 .... .... | --- .. .. .. .. .... .... | G#4 03 40 40 00 .... ....
006 | --- .. .. .. .. .... .... | --- .. .. .. .. .... .... | G#4 03 30 40 00 .... ....
007 | --- .. .. .. .. .... .... | C-3 02 75 40 00 .... .... | G#4 03 40 40 00 .... ....
008 | --- .. .. .. .. .... .... | --- .. .. .. .. .... .... | G#4 03 35 40 00 .... ....

=== END PATTERN DATA ===
```

**Step 4:** The AI will analyze and suggest improvements
**Step 5:** Copy the improved pattern back to Renoise

### Example 2: Creative Variations

**Ask for creative variations:**
- "Create 3 different variations of this bass line"
- "Add a counter-melody that complements this lead"
- "Generate a breakdown version with half the elements"
- "Make this pattern more complex with additional percussion"

### Example 3: Technical Transformations

**Request technical changes:**
- "Transpose everything to E minor"
- "Add swing timing to the drums"
- "Increase all volumes by 20%"
- "Add delay effects to the lead track"

## Common AI Commands

### **Musical Transformations**
- `transpose [up/down] [X] semitones`
- `change key to [key name]`
- `add swing/shuffle`
- `humanize timing`
- `randomize velocities`

### **Pattern Manipulation**
- `reverse the pattern`
- `double the length`
- `halve the length`
- `shift timing by [X] steps`
- `create [X] variations`

### **Creative Generation**
- `add bass line`
- `add counter-melody`
- `add percussion fills`
- `create breakdown version`
- `generate chord progression`

### **Analysis Requests**
- `analyze harmony`
- `identify key and scale`
- `show rhythm patterns`
- `count note density`
- `suggest improvements`

## Tips for Better Results

### **Be Specific**
- Instead of "make it better" → "add more syncopation to the kick drum"
- Instead of "change the melody" → "transpose the melody up an octave and add passing notes"

### **Provide Context**
- Mention the genre: "This is a techno track, make it more driving"
- Specify the mood: "Make this sound more melancholic"
- Give technical details: "Keep it under 4 note columns per track"

### **Iterate**
- Start with simple changes
- Build complexity gradually
- Ask for multiple variations to compare

### **Verify Format**
- Always check that the AI maintains the exact format
- Ensure header and footer are preserved
- Verify hex values are valid

## Troubleshooting

### **If the AI format is wrong:**
"Please output this in the exact Renoise format with headers and proper hex values"

### **If changes are too drastic:**
"Make more subtle changes, keeping the original character"

### **If the pattern doesn't paste correctly:**
"Fix the formatting - ensure proper spacing and hex values"

## Advanced Techniques

### **Batch Processing**
Ask the AI to process multiple patterns at once:
"Here are 4 patterns, create variations for each one..."

### **Style Transfer**
"Take this house pattern and convert it to drum & bass style"

### **Harmonic Analysis**
"Analyze the chord progression and suggest a bridge section"

### **Rhythmic Development**
"Develop this 4-bar loop into a 16-bar section with variations"

## Integration with Your Workflow

1. **Experimentation Phase**: Use AI to generate multiple variations quickly
2. **Refinement Phase**: Ask for specific tweaks and improvements  
3. **Learning Phase**: Ask AI to explain music theory concepts in your patterns
4. **Production Phase**: Use AI to generate complementary parts and fills

Remember: The AI is a creative partner, not a replacement for your musical judgment. Use it to explore ideas you might not have considered and to speed up your workflow!