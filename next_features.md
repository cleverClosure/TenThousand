# Next Features

## 1. Session History & Manual Logging

Currently, users can't view past sessions or add time retroactively. This is critical because:
- Users need to log forgotten sessions (practiced but didn't track)
- Correct timing errors (accidentally stopped too early/late)
- See what days/times they practiced
- Delete erroneous sessions

Data model already supports sessions, just needs UI.

---

## 2. Statistics Dashboard with Heatmap

The code already tracks `uniqueLoggedDays` but there's no visualization. Add:
- **Activity heatmap** (like GitHub's contribution graph) - shows practice consistency at a glance
- **Weekly/monthly summaries** with charts
- **Streak tracking** (consecutive days practiced)
- **Best week/month** highlights

This leverages existing data and gives users the satisfying "progress porn" that drives engagement.

---

## 3. Practice Reminders

No notification system exists. Users benefit from:
- Daily reminder at a chosen time ("Time to practice!")
- Inactivity alerts ("You haven't practiced in 3 days")
- Goal-based nudges ("2 more hours this week to hit your target")

Reminders are the #1 driver of habit consistency in tracking apps.

---

## Honorable Mentions

- iCloud sync (multi-Mac support)
- Session notes
- Data export/backup
- Intermediate milestones (celebrate 100hr, 500hr, 1000hr achievements)
