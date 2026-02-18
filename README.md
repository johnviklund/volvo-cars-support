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
2. Create an application to get your **VCC API Key** and **OAuth2 client credentials**
3. Add them to a `.env` file in the skill directory:

```
VCC_API_KEY=your-vcc-api-key
VOLVO_CLIENT_ID=your-oauth2-client-id
VOLVO_CLIENT_SECRET=your-oauth2-client-secret
```

4. Run the interactive setup script to authenticate:

```bash
./scripts/auth-init.sh
```

This opens your browser for the Volvo ID OAuth2 flow and saves the access and refresh tokens to `.env`. Tokens are refreshed automatically when they expire.

#### Environment Variables

| Variable | Required | Auto | Description |
|----------|----------|------|-------------|
| `VCC_API_KEY` | **Yes** | | Primary API key from developer portal |
| `VOLVO_CLIENT_ID` | **Yes** | | OAuth2 client ID from your app |
| `VOLVO_CLIENT_SECRET` | **Yes** | | OAuth2 client secret |
| `VOLVO_ACCESS_TOKEN` | | **Yes** | Bearer token — managed by `auth-init.sh` / `auth-refresh.sh` |
| `VOLVO_REFRESH_TOKEN` | | **Yes** | Refresh token — managed by `auth-init.sh` / `auth-refresh.sh` |
| `VOLVO_VIN` | | | Default VIN — auto-substituted into `{vin}` path segments |
| `VCC_API_KEY_SECONDARY` | | | Secondary API key — fallback on rate limiting |

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
| `scripts/auth-init.sh` | One-time OAuth2 setup (Authorization Code flow) |
| `scripts/auth-refresh.sh` | Refresh expired access tokens |

## Reference Documentation

| File | Contents |
|------|----------|
| `references/graphql-schema.md` | GraphQL types, fields, and example queries |
| `references/connected-vehicle-api.md` | REST API endpoints, request/response formats |
| `references/command-statuses.md` | All 22 command invoke status codes explained |

## License

MIT
