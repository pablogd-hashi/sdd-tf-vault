---
name: notify-slack
description: Post workflow updates, ticket query results, and ticket creation confirmations to Slack via Slack MCP. Use when the user asks to notify Slack, post to a channel, query pending tickets for Slack, or confirm a Linear/Jira ticket action in Slack.
disable-model-invocation: true
---

# Notify Slack

Post infrastructure workflow updates and ticket actions to Slack using Slack MCP.

## Prerequisites

- Slack MCP authenticated in Cursor (`slack_post_message`, `slack_list_channels`, `slack_reply_to_thread`)
- Env vars set: `SLACK_BOT_TOKEN`, `SLACK_TEAM_ID`
- Default channel: `SLACK_DEFAULT_CHANNEL` env or `#infra-onboarding`
- Ticket provider MCP authenticated when querying or creating tickets:
  - **jira** → Atlassian MCP
  - **linear** → Linear MCP

## Slack MCP tools

| Action | Tool |
|--------|------|
| Post message | `slack_post_message` |
| Reply in thread | `slack_reply_to_thread` |
| List channels | `slack_list_channels` |
| Read channel history | `slack_get_channel_history` |

## Channel conventions

- Default workflow channel: `#infra-onboarding`
- Use the channel the user names explicitly when provided
- If channel lookup fails, call `slack_list_channels` and pick the closest match
- Prefer replying in-thread when the user triggered the request from a Slack thread (`thread_ts` provided)

## Message template

```
[<ticket-id>] <phase-or-action> — <service-or-summary>
Status: <emoji> <status>
<link-if-available>
```

Status emojis: `:white_check_mark:` done, `:eyes:` ready for review, `:hourglass_flowing_sand:` pending, `:x:` failed

---

## Scenario A — Workflow notification

**Trigger examples:**
- "Pick this ticket from Linear and get the onboarding ready for review"
- "Post to Slack that the spec is ready"
- "Notify #infra-onboarding that validation passed"

**Steps:**

1. Resolve ticket and provider (Linear or Jira) from user message or env `TICKET_PROVIDER`
2. Run the appropriate workflow skill (`create-spec` / `ticket-to-spec` → `implement-change` → `validate-change`, etc.)
3. Determine phase outcome (spec ready, validation PASS, PR opened)
4. Build message from template with ticket ID, service name, phase, and artifact link
5. Post via `slack_post_message` to target channel (default `#infra-onboarding`)
6. If user provided `thread_ts`, also `slack_reply_to_thread` with a short summary

**Example message:**

```
[PE-123] Onboarding ready for review — payments-api
Status: :eyes: Spec + validation complete
Spec: requests/PE-123-payments-api/01-spec/spec.md
```

---

## Scenario B — Ticket query

**Trigger examples:**
- "Can you tell me which tickets are pending in Jira?"
- "List open Linear tickets for onboarding"
- "Post pending Jira tickets to Slack"

**Steps:**

1. Resolve provider (`jira` or `linear`)
2. Query tickets:
   - **jira** → Atlassian MCP `searchJiraIssuesUsingJql` with JQL such as `project = PE AND status != Done ORDER BY created DESC`
   - **linear** → Linear MCP list/search issues with status `Backlog`, `Todo`, or `In Progress` (exclude `Done`/`Canceled`)
3. Format results as a concise Slack list (max 10 items; note if truncated):

```
Pending Jira tickets (3):
• PE-101 — payments-api — In Progress
• PE-102 — auth-service — To Do
• PE-103 — billing-api — To Do
```

4. Post via `slack_post_message` to the requested channel (or reply in thread)
5. If no tickets found, post: `No pending <provider> tickets found for project <key>.`

---

## Scenario C — Ticket creation

**Trigger examples:**
- "Can you add this ticket in Linear as pending with the following description"
- "Create a Jira ticket for onboarding auth-service and confirm in Slack"

**Steps:**

1. Resolve provider and required ticket fields (see `ticket-schema` rule)
2. Create ticket:
   - **linear** → Linear MCP create issue with title, description, team, and pending status (`Backlog` or `Todo`)
   - **jira** → Atlassian MCP `createJiraIssue` with project key, issue type, summary, description
3. Capture ticket ID and URL from MCP response
4. Post confirmation to Slack:

```
Created Linear ticket LIN-456 — auth-service onboarding
Status: :hourglass_flowing_sand: Pending
<ticket-url>
```

5. If creation fails, post the error summary to Slack and stop

---

## Rules

- Never invent ticket field values — use user-provided description and required schema fields only
- Always include ticket ID and provider in Slack messages
- Do not post secrets, tokens, or `.env` values to Slack
- If Slack MCP is not authenticated, tell the user to set `SLACK_BOT_TOKEN` and `SLACK_TEAM_ID` in `.env` and reload MCP
- For workflow notifications, post only after the referenced phase completes successfully (or post failure with `:x:` status)

## Output

Slack message posted to `<channel>` (and thread if applicable). No repo artifact required unless combined with another workflow skill.
