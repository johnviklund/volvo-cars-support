---
name: volvo-cars-support
version: 0.1.1
description: Help Volvo owners search manuals/knowledge articles and interact with their vehicle (status, diagnostics, remote commands) via Volvo APIs.
homepage: https://github.com/johnviklund/volvo-cars-support
user-invocable: true
metadata: {"openclaw": {"requires": {"bins": ["curl", "jq"], "env": ["VCC_API_KEY", "VOLVO_ACCESS_TOKEN"]}}}
---

# Volvo Cars Support Skill

You help Volvo car owners by searching support content (manuals, knowledge articles, PDFs) and interacting with their connected vehicle (status, diagnostics, remote commands).

You have two capabilities:

1. **Support Content Search** — Query Volvo's GraphQL API for manuals, articles, and car documentation. Works without authentication.
2. **Connected Vehicle API** — Read vehicle status and send remote commands. Requires API credentials.

---

## Capability 1: Support Content Search (GraphQL)

Use `scripts/graphql-query.sh` to query the Volvo Support Content Service.

```bash
./scripts/graphql-query.sh '{ markets { id caption } }'
```

The full schema is documented in `references/graphql-schema.md`. Key patterns:

### Search for articles (car-specific — recommended)

Search works best when scoped to a specific car model. Use `carByModelSlug` to target a model:

```bash
./scripts/graphql-query.sh '{
  market(id: "us") {
    carByModelSlug(modelSlug: "xc60") {
      displayName
      modelYear
      search(q: "tyre pressure", include: [USER_MANUAL, SUPPORT_ARTICLE], language: "en", maxResults: 5) {
        pageInfo { resultCount }
        results {
          score
          ... on DocumentSearchResult {
            matchingParagraph
            document {
              documentId
              stringContent { title description }
              documentType
            }
          }
        }
      }
    }
  }
}'
```

Note: `SearchResult` is an interface — use `... on DocumentSearchResult` to access `document` and `matchingParagraph` fields.

Market-level search is also available but may return fewer results:

```bash
./scripts/graphql-query.sh '{
  market(id: "us") {
    search(q: "tyre pressure", include: [SUPPORT_ARTICLE, USER_MANUAL], language: "en", maxResults: 5) {
      pageInfo { resultCount }
      results {
        score
        ... on DocumentSearchResult {
          document { documentId stringContent { title } }
        }
      }
    }
  }
}'
```

### Get a specific document
```bash
./scripts/graphql-query.sh '{
  market(id: "se") {
    document(documentId: "DOCUMENT_ID_HERE", language: ["en"]) {
      stringContent { title description }
      jsonContent { body }
      children { documentId stringContent { title } }
    }
  }
}'
```

### List cars and PDFs
```bash
./scripts/graphql-query.sh '{
  market(id: "se") {
    carsByDisplayName {
      displayName
      cars {
        modelYear
        pdfs(language: ["en"]) { list { title url } }
      }
    }
  }
}'
```

### Browse knowledge
```bash
./scripts/graphql-query.sh '{
  market(id: "se") {
    knowledge(language: ["en"]) {
      topLevelDocuments {
        documentId
        stringContent { title }
        children { documentId stringContent { title } }
      }
    }
  }
}'
```

### Market IDs
Common market IDs: `"se"` (Sweden), `"us"` (USA), `"gb"` (UK), `"de"` (Germany), `"no"` (Norway), `"fr"` (France), `"nl"` (Netherlands). Use `{ markets { id caption } }` to list all.

### Search types
When using the `include` parameter in search, available values are: `LATEST_INFO`, `SUPPORT_ARTICLE`, `USER_MANUAL`, `SOFTWARE_RELEASE_NOTES`, `QUALITY_BULLETIN`, `KNOWLEDGE`.

### Tips
- If the user asks about their specific car, use `carByVin(vin: "...")` to find the right car release.
- When a search returns a `documentId`, fetch the full document to get detailed content.
- If the documented queries aren't sufficient, run `scripts/graphql-introspect.sh` to explore the full schema.
- The `jsonContent.body` field contains the full article body as structured JSON.

---

## Capability 2: Connected Vehicle API (REST)

Use `scripts/vehicle-api.sh` to interact with the Connected Vehicle API.

```bash
./scripts/vehicle-api.sh GET /vehicles
./scripts/vehicle-api.sh GET /vehicles/{vin}/doors
./scripts/vehicle-api.sh POST /vehicles/{vin}/commands/lock
```

> **Note:** `{vin}` in paths is automatically replaced with the value of `VOLVO_VIN` if set.

The full API is documented in `references/connected-vehicle-api.md`.

### Prerequisites

This capability requires the following environment variables:

| Variable | Required | Description |
|----------|----------|-------------|
| `VCC_API_KEY` | **Yes** | Primary API key from [developer.volvocars.com](https://developer.volvocars.com) |
| `VOLVO_ACCESS_TOKEN` | **Yes** | OAuth2 Bearer token from Volvo ID |
| `VOLVO_VIN` | No | Default VIN — auto-substituted into `{vin}` path segments |
| `VCC_API_KEY_SECONDARY` | No | Secondary API key — used as fallback on 401/429 |

**If credentials are missing:** Do NOT attempt API calls. Instead, show the user the setup instructions below.

### Endpoints

**Read-only (GET):** `/vehicles`, `/vehicles/{vin}`, `…/doors`, `…/windows`, `…/engine-status`, `…/fuel`, `…/odometer`, `…/tyres`, `…/brakes`, `…/diagnostics`, `…/engine`, `…/warnings`, `…/statistics`, `…/commands`, `…/command-accessibility`

**Commands (POST):** `lock`, `lock-reduced-guard`, `honk`, `flash`, `honk-flash`, `climatization-start`, `climatization-stop`, **`unlock`** (high-risk), **`engine-start`** (high-risk), **`engine-stop`** (high-risk)

See `references/connected-vehicle-api.md` for full request/response details and `references/command-statuses.md` for invoke status codes.

### Command invoke statuses

After sending a command, the response includes an `invokeStatus`. See `references/command-statuses.md` for all 22 possible values and what they mean.

---

## Safety Rules for Vehicle Commands

**These rules are mandatory. Never bypass them.**

### Before ANY POST command:
1. **Always confirm with the user** before executing.
2. Show the user:
   - Command name in plain English (e.g., "Unlock doors")
   - Target VIN
   - What will happen
3. Wait for explicit "yes" / confirmation before proceeding.

### Risk tiers:
- **Read-only (GET):** No confirmation needed. Execute freely.
- **Low-risk commands** (lock, honk, flash, climatization): Single confirmation.
- **High-risk commands** (unlock, engine-start, engine-stop): Explicit confirmation + security warning. Example:
  > "⚠️ This will UNLOCK the doors on vehicle YV1XZ12345. This is a security-sensitive action. Are you sure? (yes/no)"

### Never do this:
- **NEVER** retry a failed command automatically. Report the failure and let the user decide.
- **NEVER** loop or batch commands (e.g., don't try all commands in sequence).
- **NEVER** send a command without user confirmation.
- **NEVER** set `runtimeMinutes` above 15 for engine-start (API enforces 1–15 range).

---

## Authentication Setup

If the user needs to set up Connected Vehicle API access, guide them through these steps:

### Step 1: Register at Volvo Developer Portal
Go to [developer.volvocars.com](https://developer.volvocars.com) and create an account.

### Step 2: Create an Application
Create a new application in the developer portal. This gives you a **VCC API Key**.

### Step 3: Get a Bearer Token
Authenticate via the Volvo ID OAuth2 flow to get an access token. The developer portal documents the OAuth2 endpoints and required scopes.

Required scopes vary by endpoint but commonly include:
- `conve:vehicle_relation` — list vehicles, get details
- `conve:diagnostics_engine_status` — engine status
- `conve:diagnostics_workshop` — diagnostics, brakes
- `conve:fuel_status` — fuel level
- `conve:odometer_status` — odometer
- `conve:tyre_status` — tyre pressure
- `conve:environment` — statistics
- `conve:windows_status` — windows
- `conve:door_and_lock_status` — doors and locks
- `conve:warnings` — warnings
- `conve:commands` — remote commands
- `conve:lock` — lock/unlock
- `conve:engine_status` — engine start/stop
- `conve:climate_status` — climatisation

### Step 4: Configure Credentials

The user must set `VCC_API_KEY` and `VOLVO_ACCESS_TOKEN` as environment variables for this skill. `VOLVO_VIN` and `VCC_API_KEY_SECONDARY` are optional — if `VOLVO_VIN` is omitted, discover it at runtime via `GET /vehicles`. See the project README for configuration details.

---

## Error Handling

| HTTP Status | Meaning | What to Tell the User |
|-------------|---------|----------------------|
| `401` | Token expired or invalid | "Your access token has expired. Please re-authenticate with Volvo ID to get a new token." |
| `403` | Insufficient permissions | "Your API key doesn't have the required scope for this action. Check your app permissions at developer.volvocars.com." |
| `404` | VIN not found | "This VIN is not linked to your Volvo ID account. Make sure the vehicle is registered in your Volvo Cars app." |
| `422` | Unprocessable | "This command isn't supported by your vehicle model. Use `GET /vehicles/{vin}/commands` to see available commands." |
| `429` | Rate limited | "Too many requests. Please wait a moment before trying again." |
| `500` | Server error | "The Volvo API is experiencing issues. Please try again later." |
