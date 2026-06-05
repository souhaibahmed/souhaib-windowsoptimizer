# Graph Report - .  (2026-06-05)

## Corpus Check
- 69 files · ~89,061 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 158 nodes · 183 edges · 19 communities (11 shown, 8 thin omitted)
- Extraction: 87% EXTRACTED · 13% INFERRED · 1% AMBIGUOUS · INFERRED: 23 edges (avg confidence: 0.84)
- Token cost: 148,715 input · 17,593 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Claude API Core Concepts|Claude API Core Concepts]]
- [[_COMMUNITY_API Reference|API Reference]]
- [[_COMMUNITY_Project Config & Conventions|Project Config & Conventions]]
- [[_COMMUNITY_Windows Optimizer Product|Windows Optimizer Product]]
- [[_COMMUNITY_Skill Lock Configuration|Skill Lock Configuration]]
- [[_COMMUNITY_Managed Agents SDK|Managed Agents SDK]]
- [[_COMMUNITY_PowerShell Scripts|PowerShell Scripts]]
- [[_COMMUNITY_Adaptive Thinking & Migration|Adaptive Thinking & Migration]]
- [[_COMMUNITY_Claude Settings Hooks|Claude Settings Hooks]]
- [[_COMMUNITY_OpenCode Config|OpenCode Config]]
- [[_COMMUNITY_Plugin Dependencies|Plugin Dependencies]]
- [[_COMMUNITY_Memory System|Memory System]]
- [[_COMMUNITY_Environment & Sandbox|Environment & Sandbox]]
- [[_COMMUNITY_License|License]]
- [[_COMMUNITY_Claude Haiku 4.5|Claude Haiku 4.5]]
- [[_COMMUNITY_Structured Output|Structured Output]]
- [[_COMMUNITY_Web Search Tool|Web Search Tool]]

## God Nodes (most connected - your core abstractions)
1. `Claude API Skill` - 21 edges
2. `graphify Knowledge Graph Tool` - 18 edges
3. `Windows Optimizer v1.0` - 12 edges
4. `Agent Design Patterns` - 10 edges
5. `Agent` - 10 edges
6. `optimize.ps1 — Gaming Branch` - 10 edges
7. `Session` - 9 edges
8. `Managed Agents TypeScript SDK` - 7 edges
9. `setup.ps1 — Entry Point` - 6 edges
10. `Install Apps (Interactive Picker)` - 6 edges

## Surprising Connections (you probably didn't know these)
- `graphify Knowledge Graph Tool` --semantically_similar_to--> `Product Requirements Document`  [AMBIGUOUS] [semantically similar]
  .claude/skills/graphify/SKILL.md → docs/PRD.md
- `Managed Agents TypeScript SDK` --semantically_similar_to--> `Subagent Dispatch`  [INFERRED] [semantically similar]
  .agents/skills/claude-api/typescript/managed-agents/README.md → .claude/skills/graphify/SKILL.md
- `Conventional Commits` --semantically_similar_to--> `graphify Knowledge Graph Tool`  [INFERRED] [semantically similar]
  .agents/skills/everything-claude-code-conventions/SKILL.md → .claude/skills/graphify/SKILL.md
- `MCP Server Integration` --semantically_similar_to--> `Export Formats`  [INFERRED] [semantically similar]
  .agents/skills/claude-api/typescript/managed-agents/README.md → .claude/skills/graphify/references/exports.md
- `Release Notes v1.0` --conceptually_related_to--> `Windows Optimizer v1.0`  [INFERRED]
  docs/RELEASE_NOTES.md → Summary.md

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Context Management Features** — claude_api_skill_prompt_caching, claude_api_skill_compaction, claude_api_skill_context_editing, claude_api_skill_adaptive_thinking [INFERRED 0.85]
- **Managed Agents Core Resources** — shared_managed_agents_core_agent, shared_managed_agents_core_session, shared_managed_agents_environments_environment, shared_managed_agents_core_container [EXTRACTED 1.00]
- **Managed Agents Tool Types** — shared_managed_agents_tools_agent_toolset, shared_managed_agents_tools_mcp_server, shared_managed_agents_tools_custom_tool, shared_managed_agents_tools_skill [EXTRACTED 1.00]
- **Windows Optimizer Features** — summary_privacy_telemetry, summary_debloat_windows, summary_install_apps, summary_update_drivers, summary_optimize_system [EXTRACTED 1.00]
- **graphify Pipeline Components** — graphify_skill_ast_extraction, graphify_skill_semantic_extraction, graphify_skill_subagent_dispatch, graphify_skill_community_detection, graphify_skill_graphrag [EXTRACTED 1.00]
- **Windows Optimizer Core Files** — summary_setup_ps1, summary_library_ps1, summary_optimize_ps1 [EXTRACTED 1.00]

## Communities (19 total, 8 thin omitted)

### Community 0 - "Claude API Core Concepts"
Cohesion: 0.11
Nodes (28): Adaptive Thinking, Anthropic SDK, Message Batches, Claude API, Claude Opus 4.7, Claude Sonnet 4.6, Code Execution, Compaction (+20 more)

### Community 1 - "API Reference"
Cohesion: 0.09
Nodes (27): Message Batches, Files API, Tool Runner, API Reference, Client Pattern, Agent, Container, Session (+19 more)

### Community 2 - "Project Config & Conventions"
Cohesion: 0.11
Nodes (23): /graphify Trigger, Project Graphify Config, Conventional Commits, everything-claude-code Conventions, JavaScript Project Conventions, AST Extraction, Community Detection, Gemini LLM Backend (+15 more)

### Community 3 - "Windows Optimizer Product"
Cohesion: 0.16
Nodes (21): OS Version Detection, Product Requirements Document, Routing Logic, Release Notes v1.0, Milestones, Debloat Windows, Dependency Check, GPU App Injection (+13 more)

### Community 4 - "Skill Lock Configuration"
Cohesion: 0.15
Nodes (12): computedHash, skillPath, source, sourceType, computedHash, skillPath, source, sourceType (+4 more)

### Community 5 - "Managed Agents SDK"
Cohesion: 0.22
Nodes (10): Agent Creation, Custom Tools, File Upload and Download, Managed Agents TypeScript SDK, MCP Server Integration, Session Management, Streaming Events (SSE), Export Formats (+2 more)

### Community 6 - "PowerShell Scripts"
Cohesion: 0.25
Nodes (3): Invoke-DependencyCheck(), Invoke-AppInstaller(), Invoke-UpdateDrivers()

### Community 7 - "Adaptive Thinking & Migration"
Cohesion: 0.40
Nodes (6): Adaptive Thinking, Effort Parameter, Model Migration, Task Budget, Claude Opus 4.7, Claude Sonnet 4.6

### Community 11 - "Memory System"
Cohesion: 0.67
Nodes (3): Memory, Memory Store, Memory Version

## Ambiguous Edges - Review These
- `graphify Knowledge Graph Tool` → `Product Requirements Document`  [AMBIGUOUS]
  .claude/skills/graphify/SKILL.md · relation: semantically_similar_to

## Knowledge Gaps
- **66 isolated node(s):** `PreToolUse`, `$schema`, `plugin`, `@opencode-ai/plugin`, `version` (+61 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **8 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **What is the exact relationship between `graphify Knowledge Graph Tool` and `Product Requirements Document`?**
  _Edge tagged AMBIGUOUS (relation: semantically_similar_to) - confidence is low._
- **Why does `graphify Knowledge Graph Tool` connect `Project Config & Conventions` to `Windows Optimizer Product`, `Managed Agents SDK`?**
  _High betweenness centrality (0.087) - this node is a cross-community bridge._
- **Why does `Product Requirements Document` connect `Windows Optimizer Product` to `Project Config & Conventions`?**
  _High betweenness centrality (0.057) - this node is a cross-community bridge._
- **Are the 3 inferred relationships involving `Claude API Skill` (e.g. with `Agent Design Patterns` and `HTTP Error Codes Reference`) actually correct?**
  _`Claude API Skill` has 3 INFERRED edges - model-reasoned connections that need verification._
- **Are the 3 inferred relationships involving `Windows Optimizer v1.0` (e.g. with `Product Requirements Document` and `Release Notes v1.0`) actually correct?**
  _`Windows Optimizer v1.0` has 3 INFERRED edges - model-reasoned connections that need verification._
- **What connects `PreToolUse`, `$schema`, `plugin` to the rest of the system?**
  _68 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Claude API Core Concepts` be split into smaller, more focused modules?**
  _Cohesion score 0.1111111111111111 - nodes in this community are weakly interconnected._