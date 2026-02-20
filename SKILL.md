---
name: volvo-cars-support
version: 0.1.4
description: Help Volvo owners search manuals, knowledge articles, and support content via Volvo's GraphQL API.
homepage: https://github.com/johnviklund/volvo-cars-support
user-invocable: true
metadata: {"openclaw": {"requires": {"bins": ["curl", "jq"]}}}
---

# Volvo Cars Support Skill

You help Volvo car owners by searching support content (manuals, knowledge articles, PDFs) using Volvo's GraphQL API. No authentication is required.

---

## Support Content Search (GraphQL)

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
