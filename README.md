# Volvo Cars Support — OpenClaw Skill

An AI-powered assistant for Volvo car owners. Search manuals, troubleshoot warnings, and find answers — all through natural language.

## What it does

- **Search support content** — Find articles in Volvo's owner manuals, knowledge base, quick guides, and quality bulletins

## Prerequisites

- [OpenClaw](https://docs.openclaw.ai) CLI installed
- `curl` and `jq` available on your system

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

### Optional: Set your VIN

Add your Vehicle Identification Number to a `.env` file for personalized, car-specific results:

```
VOLVO_VIN=YV1XZ12345F123456
```

## Usage

```
> /volvo-cars-support
> How do I check tyre pressure on my XC60?
> What does the "engine coolant level" warning mean?
```

## Helper Scripts

| Script | Purpose |
|--------|---------|
| `scripts/graphql-query.sh` | Run GraphQL queries against the support content API |
| `scripts/graphql-introspect.sh` | Explore the full GraphQL schema |

## Reference Documentation

| File | Contents |
|------|----------|
| `references/graphql-schema.md` | GraphQL types, fields, and example queries |

## License

MIT
