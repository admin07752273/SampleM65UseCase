# Writing Effective Instructions for Declarative Agents

> **Source**: [Microsoft Learn — Write effective instructions for declarative agents](https://learn.microsoft.com/en-us/microsoft-365-copilot/extensibility/declarative-agent-instructions)

---

## What Are Instructions?

Instructions are the **system prompt** that guide how your declarative agent behaves. They tell the agent its role, how to respond, which tools to use, and how to interact with users. Users never see the instructions — only the LLM reads them.

---

## Instruction Components

A well-structured set of instructions includes these **primary components**:

| Component | Description |
|---|---|
| **Purpose** | What the agent is designed to do |
| **General Guidelines** | Tone, restrictions, general directions |
| **Skills** | What capabilities/actions the agent can use |

**Additional components** (when relevant):

- Step-by-step instructions
- Error handling and limitations
- Feedback and iteration
- Interaction examples
- Nonstandard terms / domain vocabulary
- Follow-up and closing

---

## Best Practices

### 1. Use Clear Actionable Language

- Focus on what Copilot **should do**, not what to avoid.
- Use precise verbs: `ask`, `search`, `send`, `check`, `use`.
- Supplement with examples to minimize ambiguity.
- Define nonstandard or organization-specific terms.

### 2. Build Step-by-Step Workflows with Transitions

Break workflows into modular steps. Each step should include:

- **Goal**: The purpose of the step.
- **Action**: What the agent should do and which tools to use.
- **Transition**: Clear criteria for moving to the next step or ending.

### 3. Use Strict Structure

Structure is one of the strongest signals for intent:

- Use **sections** to group related tasks (without implying sequence).
- Use **bullets** for parallel tasks that can be completed independently.
- Use **numbered steps** only for actions that must occur in a required sequence.

### 4. Make Tasks Atomic

Break multi-action instructions into clearly separated units.

- ❌ Instead of: *"Extract metrics and summarize findings."*
- ✅ Use separate steps:
  1. Extract metrics.
  2. Summarize findings.

### 5. Always Specify Tone, Verbosity, and Output Format

If you don't specify tone and detail level, the LLM infers them, leading to inconsistent behavior.

```
Tone: professional and concise.
Output: Three bullet points per section.
Return only the requested format; no explanations.
```

### 6. Structure Instructions in Markdown

- Use `#`, `##`, `###` for section headers.
- Use `-` for unordered lists and `1.` for numbered lists.
- Highlight tool names with backticks (e.g., `Jira`, `ServiceNow`).
- Make critical instructions **bold**.

### 7. Provide Domain Vocabulary

Define specialized terms, formulas, acronyms, and dataset-specific language to prevent incorrect inference.

### 8. Explicitly Reference Capabilities, Knowledge, and Actions

Clearly call out tool names at each step:

- **Actions**: *"Use `Jira` to fetch tickets."*
- **Copilot Connectors**: *"Use `ServiceNow KB` for help articles."*
- **SharePoint/OneDrive**: *"Reference internal documents."*
- **Email**: *"Check user emails for relevant information."*
- **Teams messages**: *"Search Teams chat history."*
- **Code Interpreter**: *"Use code interpreter to generate charts."*
- **People**: *"Use people knowledge to fetch user email."*

### 9. Provide Examples

- For **simple scenarios**: no examples needed.
- For **complex scenarios**: use **few-shot prompting** — provide more than one example to illustrate different aspects or edge cases.

### 10. Avoid Common Prompt Failures

| Problem | Solution |
|---|---|
| **Overeager tool use** — model calls tools without inputs | Add: *"Only call the tool if necessary inputs are available; otherwise, ask the user."* |
| **Repetitive phrasing** — model reuses example text verbatim | Encourage varied responses; use multiple examples (few-shot) |
| **Verbose explanations** — model overexplains | Add constraints and concise examples to limit verbosity |

### 11. Add a Final Self-Evaluation Step

A self-check reinforces completeness:

```
Before finalizing, confirm that all items from Section A appear in the summary.
```

### 12. Iterate on Your Instructions

1. Create instructions and conversation starters.
2. Publish your agent.
3. Test with diverse queries.
4. Compare results against base Microsoft 365 Copilot.
5. Modify instructions to improve output.
6. Repeat.

---

## Control Reasoning Through Phrasing

Your wording signals how much reasoning the model applies.

### Deep Reasoning
```
Use deep reasoning. Break the problem into steps, analyze each step,
evaluate alternatives, and justify the final decision. Reflect before answering.
Task: Determine the optimal 3-year migration strategy given constraints A, B, and C.
```

### Moderate Reasoning (Balanced)
```
Provide a concise but structured explanation. Include a short summary,
3 key drivers, and a final recommendation. No step-by-step reasoning required.
Task: Explain the tradeoffs between solution X and Y.
```

### Fast and Minimal Reasoning
```
Short answer only. No reasoning or explanation. Provide the final result only.
Task: Extract the product name and renewal date from this paragraph.
```

---

## Design Patterns

### Pattern 1: Deterministic Workflows
Convert ambiguous multi-task requests into atomic, numbered steps with explicit formulas and required validation.

### Pattern 2: Parallel vs Sequential Structure
Use **sections with bullets** for parallel tasks. Use **numbered steps** only for sequential workflows.

### Pattern 3: Explicit Decision Rules
Add if/then rules to prevent unintended model interpretation:
```
If performance is stable or improving → write the summary section.
If performance declines or anomalies detected → write the risks/issues section.
```

### Pattern 4: Output Contract
Define shape, format, tone, and allowed content:
```
## Output Contract (Mandatory)
Goal: [one sentence]
Format: [bullet list | table | 2 pages | JSON]
Detail level: [short | medium | detailed]
Tone: [Professional | Friendly | Efficient]
Include: [A, B, C]
Exclude: No extra recommendations, no extra context
```

### Pattern 5: Clean Markdown Structure
Use consistent headers, list formatting, and separation between parallel and sequential sections.

### Pattern 6: Self-Evaluation Gate
Add a final check step:
```
Before finalizing the output, review your response for completeness,
ensure all elements are accurately represented, check for inconsistencies,
and revise if needed.
```

### Pattern 7: Steering Automode Reasoning
Use reasoning cues to control depth — deep reasoning for complex analysis, minimal for simple extraction.

### Pattern 8: Literal-Execution Header (Stabilization)
When the agent shows inference drift after a model update:
```
Always interpret instructions literally.
Never infer intent or fill in missing steps.
Follow step order exactly with no optimization.
Respond concisely and only in the requested format.
```

### Pattern 9: Evaluate and Migrate Existing Instructions
Use a structured audit prompt to identify weaknesses and generate fixes for existing agent instructions.

---

## Full Example: IT Support Agent

```markdown
# OBJECTIVE
Guide users through issue resolution by gathering information, checking outages,
narrowing down solutions, and creating tickets if needed.

# RESPONSE RULES
- Ask one clarifying question at a time, only when needed.
- Present information as concise bullet points or tables.
- Avoid overwhelming users with details or options.
- Always confirm before moving to the next step or ending.
- Use tools only if data is sufficient; otherwise, ask for missing info.

# WORKFLOW

## Step 1: Gather Basic Details
- **Goal:** Identify the user's issue.
- **Action:** Proceed if clear. If unclear, ask a single clarifying question.
- **Transition:** Once clear, proceed to Step 2.

## Step 2: Check for Ongoing Outages
- **Goal:** Rule out known outages.
- **Action:** Query `ServiceNow` for current outages.
  - If outage found → share details and ETA.
  - If none → inform user and go to Step 3.

## Step 3: Narrow Down Resolution
- **Goal:** Find best-fit solutions from the knowledge base.
- **Action:** Search `ServiceNow KB` for related articles.
  - Ask clarifying questions to narrow results.
  - Provide step-by-step fix instructions.
  - If unresolved → offer to create a ticket (Step 4).

## Step 4: Create Support Ticket
- **Goal:** Log unresolved issues.
- **Action:**
  1. Map category/subcategory from the SharePoint file.
  2. Fetch user's email with the people capability.
  3. Fill ticket with caller ID, category, description, and metadata.
- **Transition:** Confirm ticket creation and next steps.

# EXAMPLES

## Valid Example
**User:** "I can't connect to VPN."
**Assistant:**
- "Are you seeing a specific error?"
  (User: "DNS server not responding.")
- "Let me check for outages." (No outage.)
- "Searching knowledge base..."
  (Asks: "Are you on office Wi-Fi or home?")
- "Try resetting your DNS settings. Here's how..."
- "Did this help? If not, I can create a support ticket."

## Invalid Example
- "Here are 15 articles I found..." (Overwhelms the user)
- "I'm raising a ticket" (Without confirming details)
```

---

## Key Takeaways

1. **Be specific** — vague instructions produce inconsistent behavior.
2. **Use structure** — Markdown headers, bullets, and numbered steps are your best tools.
3. **Reference tools explicitly** — name the actions, capabilities, and knowledge sources.
4. **Provide examples** — few-shot prompting dramatically improves complex scenarios.
5. **Iterate** — test, compare, refine. Instructions are never done on the first try.
6. **Control reasoning depth** — use phrasing to signal how much thinking you need.
7. **Add self-checks** — a final validation step catches errors before the user sees them.

---

*Reference: [Write effective instructions for declarative agents — Microsoft Learn](https://learn.microsoft.com/en-us/microsoft-365-copilot/extensibility/declarative-agent-instructions)*
