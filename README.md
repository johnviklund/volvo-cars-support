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
mkdir -p ~/.openclaw/skills
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
3. Get a **test access token** from the [test access tokens](https://developer.volvocars.com/apis/docs/test-access-tokens/) page
4. Create a `.env` file in the skill directory:

```
VCC_API_KEY=your-vcc-api-key
VOLVO_ACCESS_TOKEN=your-test-access-token
```

> Test tokens are short-lived (~1 hour). When one expires, generate a new one from the developer portal.

#### Automated token refresh (published apps only)

If you have a [published app](https://developer.volvocars.com/apis/docs/authorisation/) (requires Volvo review, 14–21 days), you can enable automated token refresh by adding your OAuth2 client credentials:

```
VOLVO_CLIENT_ID=your-client-id
VOLVO_CLIENT_SECRET=your-client-secret
VOLVO_REFRESH_TOKEN=your-refresh-token
```

Run `./scripts/auth-init.sh` to complete the initial OAuth2 flow. After that, tokens refresh automatically on 401 responses.

#### Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `VCC_API_KEY` | **Yes** | Primary API key from developer portal |
| `VOLVO_ACCESS_TOKEN` | **Yes** | OAuth2 Bearer token (test token or from `auth-init.sh`) |
| `VOLVO_VIN` | No | Default VIN — auto-substituted into `{vin}` path segments |
| `VCC_API_KEY_SECONDARY` | No | Secondary API key — fallback on rate limiting |
| `VOLVO_CLIENT_ID` | No | OAuth2 client ID — enables auto-refresh (published apps) |
| `VOLVO_CLIENT_SECRET` | No | OAuth2 client secret — enables auto-refresh (published apps) |
| `VOLVO_REFRESH_TOKEN` | No | Refresh token — enables auto-refresh (published apps) |

> Restrict file permissions: `chmod 600 .env`

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
| `scripts/auth-init.sh` | One-time OAuth2 setup (published apps only) |
| `scripts/auth-refresh.sh` | Refresh expired access tokens (published apps only) |

## Reference Documentation

| File | Contents |
|------|----------|
| `references/graphql-schema.md` | GraphQL types, fields, and example queries |
| `references/connected-vehicle-api.md` | REST API endpoints, request/response formats |
| `references/command-statuses.md` | All 22 command invoke status codes explained |

## License

MIT
