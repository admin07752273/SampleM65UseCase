# Microsoft 365 Agents SDK — Architecture Overview

This document explains the layered architecture of agents built using the **Microsoft 365 Agents SDK** and how each layer contributes to the overall system.

---

## Architecture Diagram

```
┌──────────────────────────────────────────────────────────────┐
│                     YOUR AGENT CODE                          │
│              Business Logic, AI Orchestration                │
│     (or Declarative Config — no code needed)                 │
└──────────────┬───────────────────────────────────────────────┘
               │
┌──────────────▼───────────────────────────────────────────────┐
│               MICROSOFT 365 AGENTS SDK                       │
│  ┌────────────┐ ┌────────────┐ ┌──────────────────────────┐ │
│  │ Activity    │ │ State Mgmt │ │ Teams AI Library         │ │
│  │ Handler     │ │            │ │ (Planner, Actions,       │ │
│  │             │ │            │ │  Prompt Mgmt, LLM)       │ │
│  └────────────┘ └────────────┘ └──────────────────────────┘ │
│  ┌────────────────────────────────────────────────────────┐  │
│  │ Adaptive Card Builder  │  Auth (MSAL / Entra ID)       │  │
│  └────────────────────────────────────────────────────────┘  │
└──────────────┬───────────────────────────────────────────────┘
               │
┌──────────────▼───────────────────────────────────────────────┐
│              BOT FRAMEWORK PROTOCOL                          │
└──────────────┬───────────────────────────────────────────────┘
               │
┌──────────────▼───────────────────────────────────────────────┐
│  AZURE BOT SERVICE    │    MICROSOFT ENTRA ID (Identity)     │
└──────────────┬────────┴──────────────────────────────────────┘
               │
┌──────────────▼───────────────────────────────────────────────┐
│              M365 COPILOT ORCHESTRATOR                        │
│           (LLM + Planner + Plugin Invocation)                │
└──────────────┬───────────────────────────────────────────────┘
               │
┌──────────────▼───────────────────────────────────────────────┐
│  M365 SURFACES: Copilot │ Teams │ Outlook │ M365.com │ Web  │
│                 (Adaptive Card rendering happens here)       │
└──────────────────────────────────────────────────────────────┘
               │
┌──────────────▼───────────────────────────────────────────────┐
│  DATA SOURCES: Microsoft Graph │ External APIs │ SharePoint  │
│                Dataverse │ Graph Connectors │ Knowledge Bases │
└──────────────────────────────────────────────────────────────┘
```

---

## Layer-by-Layer Breakdown

### 1. Your Agent Code (Top Layer)

The topmost layer is where your custom logic lives. There are two paths:

- **Code-based (Custom Engine Agents):** You write business logic, AI orchestration, custom RAG pipelines, or multi-turn conversation flows using C#, JavaScript, or Python.
- **Declarative (Declarative Agents):** You define the agent's behavior, instructions, capabilities, and actions entirely through configuration (TypeSpec `.tsp` files or JSON). No server code is needed — the M365 Copilot orchestrator handles everything at runtime.

### 2. Microsoft 365 Agents SDK

The SDK provides the foundational building blocks for custom engine agents:

| Component | Purpose |
|---|---|
| **Activity Handler** | Processes incoming activities (messages, events, invocations) from the Bot Framework Protocol. Routes each activity type to the appropriate handler method. |
| **State Management** | Manages conversation state, user state, and turn state across interactions. Handles serialization and storage of state data. |
| **Teams AI Library** | The modern AI layer that replaces legacy dialog systems. Includes a **Planner** (maps user intent to actions via LLM), **Action Handlers** (execute specific tasks), and **Prompt Management** (template-based prompt engineering with LLM integration). |
| **Adaptive Card Builder** | Helpers to construct Adaptive Cards — the rich, interactive UI elements rendered by M365 surfaces. Cards are *built* in this layer but *rendered* by the client surfaces at the bottom. |
| **Auth (MSAL / Entra ID)** | Handles Single Sign-On (SSO), OAuth token acquisition, consent flows, and token caching. Uses Microsoft Authentication Library (MSAL) and integrates with Microsoft Entra ID. |

> **Note for Declarative Agents:** This layer is skipped entirely. Declarative agents go straight from configuration to the Copilot Orchestrator.

### 3. Bot Framework Protocol

The **Bot Framework Protocol** is the wire protocol that standardizes communication between your agent and the hosting infrastructure. It defines:

- **Activity schema** — the JSON format for messages, events, and invocations
- **Connector API** — how your agent sends replies back to the user
- **Authentication** — how messages are verified between your agent and Azure Bot Service

This is a transport layer — it carries activities between your code and Azure Bot Service regardless of which surface (Teams, Outlook, Copilot) originated the request.

### 4. Azure Bot Service + Microsoft Entra ID

| Component | Purpose |
|---|---|
| **Azure Bot Service** | A cloud service that acts as a message router. It receives activities from M365 surfaces, authenticates them, and forwards them to your agent's endpoint. It also handles channel registration, scaling, and multi-channel support. |
| **Microsoft Entra ID** | The identity platform (formerly Azure Active Directory) that provides authentication and authorization across the entire stack. It manages user identity, app registrations, OAuth 2.0 flows, permissions/consent, and Conditional Access policies. |

> **Important:** Azure Bot Service is required for custom engine agents and bots but is **not** required for declarative agents or API-based message extensions.

### 5. M365 Copilot Orchestrator

This is the AI brain of **Microsoft 365 Copilot**. When a user interacts with Copilot:

1. The **Planner** interprets user intent using a large language model (LLM)
2. The orchestrator decides which **plugins/actions** to invoke based on the agent's metadata and OpenAPI specs
3. It executes the actions, gathers results, and composes a response
4. The response is sent back to the user surface

For **declarative agents**, this orchestrator is the runtime — it reads your `declarativeAgent.json`, follows your instructions, and calls your defined actions and capabilities directly.

For **custom engine agents**, this layer may or may not be involved depending on whether the agent is surfaced through Copilot or directly through Teams.

### 6. M365 Surfaces (Client Layer)

These are the end-user applications where the agent appears:

| Surface | Description |
|---|---|
| **Microsoft 365 Copilot** | The AI assistant experience — agents appear as selectable Copilot extensions |
| **Microsoft Teams** | Chat, channels, meetings — agents can be bots, tabs, or message extensions |
| **Outlook** | Message extensions, add-ins, and Copilot agents surface in email/calendar |
| **M365.com** | The web portal for Microsoft 365 — agents can appear in the Copilot sidebar |
| **Web Chat** | Embeddable chat widget for external websites |

Adaptive Cards are **rendered** at this layer by the native client, providing rich interactive UI without custom frontend code.

### 7. Data Sources (Bottom Layer)

Agents derive their value from the data they can access:

| Source | Description |
|---|---|
| **Microsoft Graph** | Unified API for M365 data — users, mail, calendar, files, Teams, org structure |
| **External APIs** | Third-party REST APIs (e.g., GitHub, Salesforce, Jira) accessed via OpenAPI specs |
| **SharePoint / OneDrive** | Document libraries and file storage — accessible as a Copilot capability or via Graph |
| **Dataverse** | Business data platform (CRM, ERP data) used by Power Platform and Dynamics 365 |
| **Graph Connectors** | Ingest external data into the M365 index so Copilot can search it natively |
| **Knowledge Bases** | Custom document collections, FAQs, or structured data the agent can reference |

---

## Two Paths Through the Architecture

### Path A: Declarative Agent (No Code)

```
TypeSpec Config → tsp compile → declarativeAgent.json + OpenAPI specs
                                        │
                                        ▼
                              M365 Copilot Orchestrator
                              (reads instructions, invokes actions & capabilities)
                                        │
                                        ▼
                              M365 Surfaces (Copilot, Teams, Outlook)
```

- Skips the SDK, Bot Framework Protocol, and Azure Bot Service entirely
- Config-driven: instructions, capabilities, and actions defined in `.tsp` files
- Runtime is fully managed by the Copilot Orchestrator

### Path B: Custom Engine Agent (Code-Based)

```
Your Code (C#/JS/Python) + Agents SDK
        │
        ▼
Bot Framework Protocol
        │
        ▼
Azure Bot Service + Entra ID
        │
        ▼
M365 Surfaces (Teams, Copilot, Outlook, Web)
```

- Full control over AI orchestration, conversation flow, and data access
- You host and manage the server infrastructure
- Can bring your own LLM (Azure OpenAI, custom models, etc.)

---

## Key Takeaways

1. **The Copilot Orchestrator is a distinct layer** — it sits between Azure Bot Service and the user surfaces, providing LLM-powered planning and plugin invocation.
2. **Identity (Entra ID) is foundational** — it's not just an SDK feature but a cross-cutting concern spanning the entire stack.
3. **Declarative agents skip most of the stack** — they go from config to Copilot Orchestrator with no server code, no SDK, and no Azure Bot Service.
4. **Adaptive Cards are rendered by surfaces, not the SDK** — the SDK provides builders, but the actual rendering happens in Teams/Outlook/Copilot clients.
5. **Data sources are essential** — an agent's usefulness depends on the data it can access via Microsoft Graph, external APIs, or Graph Connectors.
6. **Azure Bot Service is not always required** — declarative agents and API-based message extensions bypass it entirely.
