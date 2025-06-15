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

The data comes in this specific text format:

```
=== RENOISE PATTERN DATA ===
Format: Simple-V1
Selection: L001-016 T001-004

Line | T01:Kick Drum | T02:Snare | T03:Hi-Hat | T04:Bass

001 | C-2 01 80 40 00 0A00 | --- .. .. .. .. .... | G#4 03 60 -- -- ---- | C-3 05 7F 40 00 ----
002 | --- .. .. .. .. ---- | C-3 02 7F 40 00 ---- | --- .. .. .. .. ---- | --- .. .. .. .. ----
003 | C-2 01 78 40 00 ---- | --- .. .. .. .. ---- | G#4 03 58 -- -- 1A20 | F-3 05 75 40 00 ----
004 | --- .. .. .. .. 0C40 | --- .. .. .. .. ---- | --- .. .. .. .. ---- | --- .. .. .. .. ----

=== END PATTERN DATA ===
```

## **Format Reference**

**Structure:**
- `Line`: Pattern line number (001-999)
- `T01:Name`: Track number and name
- Each track contains: `Note Instrument Volume Effect1 Effect2 ...`

**Note Format:**
- `C-4`, `D#5`, etc. = Musical notes (C, C#, D, D#, E, F, F#, G, G#, A, A#, B) + octave (0-9)
- `---` = Empty note slot  
- `OFF` = Note off command

**Values (all in hexadecimal):**
- **Instrument**: `01`-`FF` (instruments 1-255), `..` = empty
- **Volume**: `00`-`7F` (0-127), `..` = empty  
- **Effects**: `0A00` = effect number + amount, `....` = empty
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

**You:** "I'll transpose all notes up 5 semitones (perfect 4th) and add rhythmic variations to the hi-hat track with different velocities and some 16th note patterns.

```
=== RENOISE PATTERN DATA ===
Format: Simple-V1  
Selection: L001-004 T001-003

Line | T01:Kick | T02:Snare | T03:Hi-Hat Enhanced

001 | F-2 01 80 | --- .. .. | C-5 03 60 
002 | --- .. .. | F-3 02 7F | C-5 03 45
003 | F-2 01 78 | --- .. .. | C-5 03 70
004 | --- .. .. | --- .. .. | C-5 03 55

=== END PATTERN DATA ===
```

The kick and snare transposed from C-2/C-3 to F-2/F-3, and I added consistent hi-hat with velocity variations (60, 45, 70, 55) for a more humanized feel."

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
Format: Simple-V1
Selection: L001-008 T001-003

Line | T01:Kick | T02:Snare | T03:Hi-Hat

001 | C-2 01 80 | --- .. .. | G#4 03 40
002 | --- .. .. | --- .. .. | G#4 03 30
003 | --- .. .. | C-3 02 7F | G#4 03 40
004 | --- .. .. | --- .. .. | G#4 03 30
005 | C-2 01 78 | --- .. .. | G#4 03 40
006 | --- .. .. | --- .. .. | G#4 03 30
007 | --- .. .. | C-3 02 75 | G#4 03 40
008 | --- .. .. | --- .. .. | G#4 03 35

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