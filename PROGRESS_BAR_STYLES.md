# Cool Progress Bar UI Styles

This document showcases the various retro-style text-based progress bar designs implemented in TenThousand.

## Overview

We've implemented multiple progress bar styles inspired by classic terminal/console aesthetics, using Unicode block characters for a unique, retro look.

## Progress Bar Variants

### 1. TextProgressBar (Standard)
The basic customizable text-based progress bar.

**Example Output:**
```
[████░░░░░░░░░░░░░░] 1.2%
[████████░░░░░░░░░░] 12.3%
[█████████░░░░░░░░░] 45.6%
[███████████████░░░] 78.9%
[███████████████████] 99.5%
```

**Features:**
- Customizable total blocks (default: 20)
- Custom filled/empty characters
- Optional percentage display
- Optional brackets
- Custom colors and font sizes

**Usage:**
```swift
TextProgressBar(
    progress: 45.6,
    totalBlocks: 20,
    filledChar: "█",
    emptyChar: "░",
    showPercentage: true,
    showBrackets: true,
    color: .blue,
    fontSize: 11
)
```

### 2. AnimatedTextProgressBar
Enhanced version with smooth animations and color-coded progress.

**Example Output:**
```
[██░░░░░░░░░░░░░░░░] 5.0%   (red - just started)
[█████░░░░░░░░░░░░░] 25.0%  (orange - making progress)
[██████████░░░░░░░░] 50.0%  (yellow - halfway)
[█████████████████░] 85.0%  (green - almost there!)
```

**Features:**
- Smooth spring animations on progress changes
- Color matches skill accent color
- Automatic progress interpolation
- Eye-catching visual feedback

**Usage:**
```swift
AnimatedTextProgressBar(
    progress: skill.percentComplete,
    totalBlocks: 20,
    showPercentage: true,
    accentColor: skill.color
)
```

**Currently Used In:**
- `SkillRowView.swift` - Main skill cards

### 3. MiniTextProgressBar
Compact version for tight spaces using alternate block characters.

**Example Output:**
```
[▰▱▱▱▱▱▱▱▱▱] 10%
[▰▰▰▰▱▱▱▱▱▱] 40%
[▰▰▰▰▰▰▰▱▱▱] 75%
```

**Features:**
- Smaller font size (9pt)
- Different block characters (▰/▱)
- Perfect for mini dashboards
- Reduced spacing

**Usage:**
```swift
MiniTextProgressBar(
    progress: 40,
    totalBlocks: 10,
    color: .cyan
)
```

**Currently Used In:**
- `OverallProgressView.swift` - Top skills preview
- `TopSkillsPreview` component

## Alternative Character Sets

You can customize the look by using different Unicode characters:

### Classic Blocks
```
Filled:  █  (U+2588 Full Block)
Empty:   ░  (U+2591 Light Shade)
```

### Geometric
```
Filled:  ●  (U+25CF Black Circle)
Empty:   ○  (U+25CB White Circle)

Filled:  ■  (U+25A0 Black Square)
Empty:   □  (U+25A1 White Square)
```

### Shaded
```
Filled:  ▓  (U+2593 Dark Shade)
Empty:   ░  (U+2591 Light Shade)
```

### Bars
```
Filled:  ▰  (U+25B0 Black Rectangle)
Empty:   ▱  (U+25B1 White Rectangle)
```

### Example Usage:
```swift
// Circles
TextProgressBar(progress: 33.3, filledChar: "●", emptyChar: "○", color: .pink)

// Squares
TextProgressBar(progress: 66.6, filledChar: "■", emptyChar: "□", color: .teal)

// Shaded blocks
TextProgressBar(progress: 50.0, filledChar: "▓", emptyChar: "░", color: .brown)
```

## Composite Views

### OverallProgressView
Shows aggregate progress across all skills with detailed statistics.

**Features:**
- Large 25-block progress bar
- Total hours tracked
- Skills count
- Average progress badge
- Active tracking indicator
- Color-coded background

**Currently Used In:**
- `MenuBarView.swift` - Overall dashboard section

### TopSkillsPreview
Displays top 3 skills with rank badges and mini progress bars.

**Features:**
- Ranking medals (🥇🥈🥉)
- Skill color indicators
- Mini progress bars per skill
- Compact layout

## Visual Examples

### Skill Row (Main View)
```
○ Python Programming          [play] [edit] [delete]
[████░░░░░░░░░░░░░░] 5.0%
🕐 1234h / 10000h
📅 Complete: Dec 25, 2030
```

### Overall Progress Dashboard
```
📊 Overall Progress                    ⚫ 2 tracking
[█████░░░░░░░░░░░░░░] 12.3%
🕐 180h total  |  ⭐ 3 skills        [Avg: 12.3%]
```

### Top Skills Preview
```
🏆 Top Progress
1 ○ Guitar     [████░░░░░░] 45%
2 ○ Python     [███░░░░░░░] 34%
3 ○ Japanese   [██░░░░░░░░] 20%
```

## Color Schemes

Progress bars adapt to your skill colors:
- **Red (#FF6B6B)** - Warm, energetic
- **Teal (#4ECDC4)** - Cool, focused
- **Blue (#45B7D1)** - Professional
- **Orange (#FFA07A)** - Creative
- **Mint (#98D8C8)** - Fresh
- **Yellow (#F7DC6F)** - Bright
- **Purple (#BB8FCE)** - Mystical
- **Light Blue (#85C1E2)** - Calm

## Animation Details

All progress bars use SwiftUI spring animations:
```swift
.animation(.spring(response: 0.3, dampingFraction: 0.7), value: progress)
```

This creates a smooth, bouncy effect when progress updates, especially noticeable during active tracking sessions (updates every 1 second).

## File Locations

- **TextProgressBar.swift** - Core progress bar components
- **OverallProgressView.swift** - Aggregate dashboard views
- **SkillRowView.swift** - Individual skill cards (uses AnimatedTextProgressBar)
- **MenuBarView.swift** - Main app view (includes OverallProgressView)

## Testing

All components include SwiftUI previews for visual testing. To view:
1. Open any view file in Xcode
2. Press ⌥⌘↩ (Option-Command-Return) to show Canvas
3. Click "Resume" if preview is paused

Interactive preview in `TextProgressBar.swift` includes a progress simulator to test animations!

## Future Enhancements

Potential improvements:
- [ ] Circular progress rings (donut charts)
- [ ] Vertical progress bars
- [ ] Multi-segment progress (different colors per time period)
- [ ] Sparkline graphs showing trend
- [ ] Milestone markers on progress bar
- [ ] Gradient fills
- [ ] Particle effects on progress increase

---

**Made with ❤️ for the 10,000 hour journey**
