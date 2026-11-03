---
name: user-research
description: Plan interviews, usability tests, surveys, diary studies, recruitment, evidence-based synthesis, affinity mapping, personas, and journey maps. Load when learning from users, validating assumptions, investigating behaviour or drop-off, or turning raw participant notes into insights.
---

# User research

## Purpose
Produce trustworthy evidence about what users do, need, and struggle with, so product decisions rest on observed behaviour instead of assumption.

## Inputs
- Open questions and assumptions to test (from `discovery`).
- Target segment and how to reach them; time and budget.

## Steps
1. Write research questions first ("How do admins currently onboard a new hire?"), then pick the method that answers them. Generative methods (interviews, field observation, diary studies) explore; evaluative methods (usability tests, surveys, A/B tests) check. Qualitative explains why; quantitative measures how many.
2. Recruit people who match the segment, including recent churners and non-users. Screen on behaviour, not demographics alone. Avoid friends, colleagues, and only enthusiasts.
3. Prepare a discussion guide of open questions about past behaviour. Follow the Mom Test (Rob Fitzpatrick): ask about their life, not your idea; ask for specifics from the past, not opinions or future promises; talk less, listen more.
4. Run sessions in pairs when possible (one asks, one notes). Get consent, record if permitted, and protect personal data.
5. Synthesise soon after: extract observations onto individual notes, cluster by affinity, name themes, and separate observation from interpretation.
6. Check each insight against how many participants showed it and how strongly.
7. Share findings with direct quotes and clips, then log decisions they change.

## Output
```
# Research report: <study>
Questions:
Method and participants: <n, segment, how recruited>
Key insights: <insight | evidence (who/how many) | confidence>
Journey or persona (evidence-based): <stages, goals, pain points>
Implications / recommendations:
Limits and bias risks:
Unanswered questions:
```

## Sizing the effort
- Small tweak: three to five short conversations or a quick usability check.
- Medium feature: 6 to 8 interviews or tests in one segment over a week.
- Big bet: multiple segments, mixed methods, and a survey to size what interviews reveal.

## Method selection
| Question type | Method |
| Why do people do this? | Interviews, field observation |
| Can they complete the task? | Usability test |
| How many people are affected? | Survey, analytics |
| What happens over time? | Diary study |
| Which labels or structure work? | Card sort, tree test |

## Recruiting and screeners
Screen on recent behaviour: "When did you last [do the task]? How did you do it?" Include non-users and people who stopped. Plan for no-shows by over-recruiting by about 20 percent. Offer a fair incentive.

## Interview guide template
1. Intro (2 min): purpose, no right answers, consent, recording permission.
2. Context (5 min): "Tell me about your role and a typical week."
3. Past behaviour (20 min): "Walk me through the last time you [task]. What happened next? What did you do about it?"
4. Pains and workarounds: "What was hardest? What did you try instead?"
5. Wrap-up: "Is there anything I should have asked?" Thank them.
Non-leading: not "Wouldn't it be easier if...?" but "How did you handle that?" Not "Do you like this?" but "What do you make of this?"

## Synthesis and evidence strength
Write one observation per note, tagged with participant. Cluster by affinity, name themes, then rate each: strong (most participants, observed behaviour), moderate (several, reported behaviour), weak (one or two, or opinion only). Small samples find patterns, not percentages; do not quote counts as rates.

## Ethics and consent
Obtain informed consent, explain how data is stored and who sees it, allow withdrawal at any time, anonymise quotes, and delete recordings on the agreed schedule.

## Quality checklist
- Questions precede method choice.
- Participants match the real target segment.
- Questions asked about past behaviour, no leading phrasing.
- Insights cite evidence and participant counts.
- Limitations are stated.

## Anti-patterns
- Pitching the idea and asking "would you use this?".
- Treating five interviews as statistically significant.
- Personas made from imagination or demographics only.
- Findings that sit in a deck and change no decision.
- Leading or double-barrelled questions that put answers in participants' mouths.

## Example insight
Insight: Designers delay chasing late payers because they fear souring the relationship. Evidence: 6 of 8 described waiting past two weeks; 4 drafted and deleted a reminder (observed in screen share). Confidence: strong. Implication: reminders must feel polite and personal.

## Ready for ux-design
- [ ] Each research question is answered, or flagged unanswered.
- [ ] Insights carry evidence, counts, and confidence.
- [ ] Pain points are ranked and limits are stated.

## Handoff
Pass insights, journeys, and prioritised pain points to `ux-design`. Feed new assumptions back to `discovery`.
