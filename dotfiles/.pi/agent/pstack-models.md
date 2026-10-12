# pstack model configuration

Per-role model overrides for pstack skills. Each pstack SKILL.md names its defaults in a Models section; the values here override those defaults. Delete a line to fall back to the skill default. A value of `inherit-parent` or `auto` runs that role on the parent session's model (the `Agent` call omits `model`); an alias entry in a panel list still counts toward that panel's fan-out. A model may carry a reasoning effort, as in `opus @xhigh` (levels: low, medium, high, xhigh, max); the role then runs through the pstack effort agent of that level, each entry of a panel list on its own. `default effort` sets the level for a value without one; `session` keeps the parent session's effort. `session hook: off` stops the Claude Code or Codex SessionStart hook, or the pstack Pi extension, from injecting the poteto-mode mandate; any other value, or no line, leaves it on.

pi models: opus=openai-codex/gpt-6.1-sol, fable=openai-codex/gpt-6.1-sol, sonnet=openai-codex/gpt-6.1-sol, haiku=openai-codex/gpt-6-luna

feature, refactoring: openai-codex/gpt-6.1-sol
bug-fix: openai-codex/gpt-6.1-sol
perf-issue: sonnet
hillclimb: sonnet
judgment and prose: sonnet
strongest judgment: opus
how explorer: sonnet
how explainer: sonnet
why investigators: sonnet
why synthesizer: sonnet
reflect tooling: sonnet
reflect judgment, divergent, synthesizer: sonnet
arena runners: openai-codex/gpt-6-luna, openai-codex/gpt-6.1-sol
arena cross-judge pool: opus
swarm workers: haiku
architect runners: haiku, sonnet
interrogate reviewers: haiku, sonnet

default effort: session
session hook: on
