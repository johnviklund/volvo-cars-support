# Volvo Cars Support — OpenClaw Skill

An AI-powered assistant for Volvo car owners. Search manuals, troubleshoot warnings, check vehicle status, and send remote commands — all through natural language.

## What it does

- **Search support content** — Find articles in Volvo's owner manuals, knowledge base, quick guides, and quality bulletins
- **Check vehicle status** — Doors, windows, fuel, odometer, tyres, diagnostics, warnings
- **Send remote commands** — Lock/unlock, honk, flash, start/stop engine, climatisation

## Prerequisites

- [OpenClaw](https://docs.openclaw.ai) CLI installed
- `curl` and `jq` available on your system
- (Optional) Volvo developer account for Connected Vehicle API access

## Installation

Copy this skill to your OpenClaw skills directory:

```bash
cp -r volvo-cars-support ~/.openclaw/skills/volvo-cars-support
```

The skill will appear as `/volvo-cars-support` in OpenClaw.

## Configuration

### Support Content Search (no setup needed)

The GraphQL API for searching manuals and articles works without authentication. You can start using it immediately.

### Connected Vehicle API (optional)

To check vehicle status and send commands, you need API credentials:

1. Register at [developer.volvocars.com](https://developer.volvocars.com)
2. Create an application to get your **VCC API Key**
3. Authenticate via Volvo ID OAuth2 to get a **Bearer token**
4. Add credentials to `~/.openclaw/openclaw.json`:

```json
{
  "skills": {
    "entries": {
      "volvo-cars-support": {
        "apiKey": "your-vcc-api-key",
        "env": {
          "VOLVO_ACCESS_TOKEN": "your-bearer-token",
          "VOLVO_VIN": "YV1XZ12345678901"
        }
      }
    }
  }
}
```

## Usage

```
> /volvo-cars-support
> How do I check tyre pressure on my XC60?
> What does the "engine coolant level" warning mean?
> Show me the status of my car
> Lock my car
```

## Helper Scripts

| Script | Purpose |
|--------|---------|
| `scripts/graphql-query.sh` | Run GraphQL queries against the support content API |
| `scripts/graphql-introspect.sh` | Explore the full GraphQL schema |
| `scripts/vehicle-api.sh` | Call Connected Vehicle API endpoints |

## Reference Documentation

| File | Contents |
|------|----------|
| `references/graphql-schema.md` | GraphQL types, fields, and example queries |
| `references/connected-vehicle-api.md` | REST API endpoints, request/response formats |
| `references/command-statuses.md` | All 22 command invoke status codes explained |

## License

MIT
