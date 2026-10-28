---
name: "idea-capture"
description: "Capture, clarify, and develop creative ideas systematically. Structure ideas for revisiting later with enough context to decide whether to explore, develop, or abandon them."
confidence: "medium"
---

# Idea Capture

A workflow and format for preserving creative ideas—mechanics, concepts, story, visuals, technology, or anything else worth thinking about again. The purpose is external memory, not a knowledge base. An idea is worth capturing only if future-you will want to revisit it.

## Core Philosophy

**Ideas are not knowledge articles.** They're thoughts worth preserving because:
- They solve a problem or create an opportunity
- They trigger an interesting feeling or experience
- They're unusual enough to forget but valuable enough to remember
- They could evolve into something bigger later

**The real filter:** "Would future-me want to know about this six months from now?"

If the answer is no, it's a useful brainstorm but not an idea worth capturing. The AI agent's job includes being honest about this: "This is a good brainstorm session, but there's not enough substance here to preserve as an idea yet."

## When to Capture an Idea

| Signal | Capture? | Why |
|--------|----------|-----|
| "What if the player had to manage multiple settlements?" | ✅ Yes | Concrete, actionable, creates new design space |
| "That mechanic would be cool" | ❌ No | Too vague — revisit in a later conversation when it's clearer |
| "Settlements could be connected by trade routes" | ✅ Yes | Specific enough to expand on; generates questions |
| "I really liked the atmosphere in that game" | ❌ No | Not yet—capture it if you identify *why* and *what* to steal |
| "What if settlements could rebel or be destroyed?" | ✅ Yes | Opens new narrative/mechanical possibilities |

## Idea Structure

Keep it lightweight. Not every section is required—use the structure as a thinking prompt, not a compliance checklist.

```markdown
---
title: "[Concise idea name]"
type: [game/creative/story/web/technology/content/other]
status: captured
created: YYYY-MM-DD
---

# Idea: [Name]

## Summary

[One or two sentences. What is the idea?]

## Why It Matters

[Why do I want to remember this? What makes it interesting?
What problem, opportunity, or feeling does it create?
Why would future-me care?]

## Concept

[Explain the idea in enough detail that someone unfamiliar with
the original conversation could understand it.
Be specific enough to rebuild the thought later.]

## Possibilities

[Where could this go? What could it become?
What does this unlock?
What's the most interesting version of this idea?]

## Open Questions

[What don't you know yet?
What would you need to decide or explore?
What could break this idea?]

## Related

[Links to other ideas, projects, mechanics, references,
or conversations that informed this.]
```

### Example: Lightweight Idea

```markdown
---
title: "Settlement Networks"
type: game
status: captured
created: 2026-10-28
---

# Idea: Settlement Networks

## Summary

Player builds and maintains multiple interconnected settlements
instead of one main base.

## Why It Matters

Opens more complex resource management and creates interesting
trade-off decisions. Feels closer to managing a world than building.

## Concept

Multiple small settlements connected by trade routes or travel time.
Each has its own production, population, specialization.
Resources flow between them. Player must maintain connections.

## Possibilities

- NPC factions could control some settlements
- Settlements could rebel or be destroyed
- Travel time creates interesting logistics puzzles
- Different settlement types (production, research, military)

## Open Questions

- How does player actually control/visit settlements?
- What happens to a settlement the player neglects?
- Can settlements fail on their own?

## Related

- [Settlement Management](../settlement-management)
- Trade route mechanics (Offworld Trading Company, Port Royale)
```

### Example: More Developed Idea

```markdown
---
title: "Dialogue as Resource"
type: story
status: captured
created: 2026-10-15
---

# Idea: Dialogue as Resource

## Summary

In conversations with NPCs, the player has limited "dialogue points"
per chapter that function like a resource they must allocate.

## Why It Matters

Forces interesting choices about *when* and *with whom* to have
deep conversations. Makes dialogue feel precious rather than free.
Creates natural scarcity of player attention/time.

## Concept

Player gets 3-5 dialogue points per chapter (or per scene).
Each conversation costs 1 point. Must choose:
- Who to talk to
- Whether to have shallow or deep conversations
- Whether to revisit someone or meet someone new

Shallow dialogue: Quick exposition, available anytime.
Deep dialogue: Costs the limited resource but reveals character.

## Possibilities

- Points regenerate slowly (encourages replay/revisit)
- Can trade dialogue points for other resources
- Different characters unlock different conversation types
- Could gate story information behind dialogue choices
- Emergency/critical conversations might override the limit

## Open Questions

- Is this frustrating or engaging? (Feels like it could go either way)
- How does this interact with side quests?
- Do all NPCs have multiple conversation depths, or only some?
- Does skipping dialogue cost points?

## Related

- Conversation trees in Disco Elysium (limited resource feel)
- AP system in tactical games (inspiration for resource scarcity)
- Idle thoughts about meaningful dialogue in games
```

## Workflow: Capture → Clarify → Develop → Preserve

### 1. Capture

You present a rough idea:

> "What if you could tag important items and they'd stay highlighted throughout the game?"

The agent asks:
- **Is there substance here?** (Yes—concrete enough)
- **Should this be captured?** (Yes—solves a UX problem with design implications)

Then creates an initial document with what you've said, leaving other sections empty.

### 2. Clarify

The agent asks strategic questions to fill gaps:

- What player problem does this solve?
- Is this a comfort feature or a core mechanic?
- How would players discover they could tag items?
- Could this create interesting constraints (tag limit, tag cost)?
- Where did this idea come from? (Inspiration, pain point, curiosity?)

You answer only the questions that matter. The goal is **substance**, not completeness.

### 3. Develop

Once there's enough to work with, explore:

- "What if there were costs to tagging?" → Opens new design space
- "How would this feel in practice?" → Surface potential issues
- "What's the most interesting version?" → Push toward depth
- "What breaks this idea?" → Identify real constraints

The agent adds these to **Possibilities** and **Open Questions**.

### 4. Preserve

The final document distinguishes:

```markdown
## Why It Matters

[Your original thinking]

## Concept

[Your idea]

## Possibilities

- [Direction you identified]
- **AI Suggestion:** [Something the agent proposed; explicitly marked]

## Open Questions

- [Unknown you identified]
- **Unresolved:** [Thing that needs exploring]
```

**Critical:** Mark AI contributions explicitly. This is your memory, not a wiki. Future-you needs to know what you originally thought vs. what was generated.

## Hierarchy: When to Graduate an Idea

```
Idea
  ↓
Exploration (research, analysis, deeper thinking)
  ↓
Decision (commit to a direction)
  ↓
Artifact (actual design, implementation, documentation)
```

### Ideas Stay in This Repo

**Example:**
```
Idea: Settlement Networks
```

Status: `captured` or `developing`

This lives in the ideas folder and evolves as you think about it.

### Explorations Go Somewhere Else

When you decide to seriously explore an idea:

```
Exploration: What would settlement management actually look like?
```

Move or link to: Design docs, research notes, mechanics exploration.
Update the idea's **Related** section to link to the exploration.
Change status to `exploring`.

### Decisions Become Official

When you commit to something:

```
Decision: The game will use interconnected settlements as the core loop.
```

This becomes part of your GDD or project documentation.
The idea's status becomes `decided`.
The decision links back to the idea for context.

### Artifacts Are Implementation

When you actually build/design it:

```
Implementation: Settlement management UI and resource flow systems
```

This is your actual game design doc, code, or deliverable.

## Anti-Patterns

### ❌ Don't: Capture Every Conversation

Not every thought is an idea. Some are:
- Quick fixes
- Brainstorm tangents
- Preliminary explorations
- Social thoughts

**Right question:** "Will I want to return to this specific thought later?"

If it's a useful brainstorm but you'd be happy to lose it, don't capture it.

### ❌ Don't: Let AI Fill in Missing Sections

The agent should help you *think*, not turn brainstorms into ideas.

**Wrong:** Agent adds speculative content to every section.
**Right:** Agent asks clarifying questions, you decide what matters.

### ❌ Don't: Let Ideas Become Decisions Without Thinking

An idea like "multiple settlements" is different from "the game will use settlements."

One is "this might be interesting."
The other is "we've committed."

Don't slip from captured idea → decision without the exploration step.

### ❌ Don't: Lose the Original Thought

If an idea evolved, preserve what you originally thought.

```markdown
## Original Concept

[What you first said]

## How We've Thought About It Since

[Evolution as you've explored it]
```

## Using This Skill with an AI Agent

### Capture Mode

**You:** "What if players could mark important items to keep them highlighted?"

**Agent response pattern:**
1. Reflect back what you said (make sure it understood)
2. Ask: "Should I capture this?" + Quick substance check
3. If yes: Create initial doc with your idea, leave other sections for later
4. If no: "This sounds like a good brainstorm, but there's not enough here yet to preserve as an idea. What specifically would make this valuable to return to?"

### Clarify Mode

**Agent:** "You mentioned tagging for highlighting. A few clarifying questions:

- Is this solving a player pain point (hard to find important items?) or adding a feature?
- Is tagging a core mechanic or a convenience feature?
- Could there be interesting limits (max tags, tag cost)?"

**Key:** Ask only useful questions. Skip sections that don't matter.

### Develop Mode

**Agent:** "Now that we have the concept, let's explore implications:

- What if tags persisted across playthroughs?
- What if you could share tags with other players?
- What could make this feel more core to the game?"

Add possibilities to the document.

### Preserve Mode

**Agent:** "Here's the final idea with contributions marked:

- Your original thought (unmarked)
- Questions you identified (unmarked)
- **AI Suggestions** (explicitly marked)
- **Unresolved** items (marked as open)

Does this capture the idea well enough for future-you?"

## Quick Reference: When to Use This Skill

| Situation | Use This Skill |
|-----------|---|
| You have a half-formed creative thought | ✅ Capture |
| You want to explore an idea more deeply | ✅ Develop |
| You need to remember why an idea mattered | ✅ Review existing idea |
| You're turning an idea into actual work | ⚠️ Graduate to Exploration/Decision |
| You're doing general brainstorming | ❌ Do that first, then capture if substance emerges |
| You want to evaluate competing ideas | ✅ Capture each, then compare |

## The Real Question

Before capturing, ask:

**"Six months from now, would I want to know about this?"**

If yes: Capture it.
If maybe: Ask clarifying questions until you know.
If no: Let it go.

That's the filter. Everything else is process.

## Checklist: Is This Idea Ready?

- [ ] There's a reason to remember this (Why It Matters isn't empty)
- [ ] I can explain it to someone unfamiliar with the conversation (Concept is concrete)
- [ ] I know what I don't know (Open Questions exist)
- [ ] It's different/interesting enough to preserve (Not a generic thought)
- [ ] Future-me would recognize why I saved this

If most of these are true, capture it.
If only one or two, it might need more development first.

## Summary

This skill helps you:
- ✅ Preserve creative thoughts before they fade
- ✅ Think through ideas with structure, not bureaucracy
- ✅ Distinguish between brainstorm, idea, exploration, and decision
- ✅ Keep your external memory clean (only ideas worth remembering)
- ✅ Evolve ideas systematically over time
- ✅ Connect ideas to each other and to decisions
- ✅ Remember *why* an idea mattered, not just what it was

The goal is a curated collection of creative possibilities that you'll actually return to—not a growing mountain of half-thoughts.
