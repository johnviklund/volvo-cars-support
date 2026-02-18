# Volvo Support Content Service — GraphQL Schema Reference

**Endpoint:** `https://support-content-service.weu-prod.ecpaz.volvocars.biz/api/graphql`

No authentication required. All queries use HTTP POST with `Content-Type: application/json`.

---

## Query Root

| Field | Arguments | Returns | Description |
|-------|-----------|---------|-------------|
| `market` | `id: ID!` | `Market` | Get a specific market by ID (e.g., `"se"`, `"us"`, `"gb"`, `"de"`) |
| `markets` | — | `[Market!]!` | List all available markets |
| `carByVin` | `vin: String!` | `CarRelease` | Look up a car release by VIN |
| `carNetworkStatusByVin` | `vin: String!` | `SoftwareUpdateInformation` | Get software update status by VIN |

---

## Key Types

### Market

| Field | Arguments | Returns |
|-------|-----------|---------|
| `id` | — | `ID!` |
| `caption` | — | `String!` |
| `marketCode` | — | `String!` |
| `countryCodes` | — | `[String!]!` |
| `availableLanguages` | — | `MarketAvailableLanguages!` |
| `car` | `projectCode, structureWeek, softwareVersion` | `CarRelease` |
| `carByModelSlug` | `modelSlug, structureWeek, softwareVersion` | `CarRelease` |
| `carByRegistrationNumber` | `registrationNumber` | `CarRelease` |
| `cars` | `softwareVersion` | `[CarRelease!]!` |
| `carsByDisplayName` | `softwareVersion` | `[CarsByDisplayName!]!` |
| `contactInformation` | — | `MarketContactChannels` |
| `contextualKnowledge` | `language` | `ContextualKnowledge` |
| `document` | `documentId, language` | `Document` |
| `documents` | `documentIds, language, attributes, documentTypes` | `[Document!]!` |
| `knowledge` | `language` | `Knowledge` |
| `search` | `q: String!, include: [CarSearchType]!, language: String!, from: Int, maxResults: Int!` | `SearchResponse!` |

### CarRelease

| Field | Arguments | Returns |
|-------|-----------|---------|
| `id` | — | `ID!` |
| `displayName` | — | `String!` |
| `modelSlug` | — | `String!` |
| `modelCode` | — | `String` |
| `modelYear` | — | `Int!` |
| `projectCode` | — | `String!` |
| `structureWeek` | — | `String!` |
| `registrationNumber` | — | `String` |
| `isLatestRelease` | — | `Boolean!` |
| `market` | — | `Market!` |
| `availableLanguages` | — | `CarAvailableLanguages!` |
| `carNetworkStatusInformation` | — | `SoftwareUpdateInformation` |
| `contextualKnowledge` | `language` | `ContextualKnowledge` |
| `document` | `documentId: String!, language` | `Document` |
| `documents` | `documentIds, language, attributes, documentTypes` | `[Document!]!` |
| `knowledge` | `language` | `Knowledge` |
| `pdfs` | `language` | `CarPdfs!` |
| `quickGuide` | `language` | `QuickGuide` |
| `releaseNotes` | `language` | `ReleaseNotes` |
| `search` | `q: String!, include: [CarSearchType]!, language: String!, from: Int, maxResults: Int!` | `SearchResponse!` |
| `serviceAndWarranty` | `language` | `ServiceAndWarranty` |
| `userManual` | `language` | `UserManual` |

### Document

| Field | Returns |
|-------|---------|
| `documentId` | `String!` |
| `fullDocumentId` | `String!` |
| `externalId` | `String!` |
| `language` | `String!` |
| `documentType` | `DocumentType!` |
| `source` | `DocumentSource!` |
| `stringContent` | `DocumentStringContent!` |
| `jsonContent` | `DocumentJsonContent!` |
| `metaData` | `DocumentMetaData` |
| `attributes` | `[DocumentAttribute!]!` |
| `applicableTo` | `[ApplicableTo!]!` |
| `keywords` | `[String!]!` |
| `tags` | `[String!]` |
| `image` | `Image` |
| `images` | `[Image!]!` |
| `leadingImage` | `Image` |
| `video` | `Video` |
| `videos` | `[Video!]!` |
| `children` | `[Document!]!` |
| `parent` | `Document` |
| `ancestors` | `[Document!]!` |
| `relatedDocuments` | `[Document!]!` |
| `availableLanguages` | `[String!]!` |
| `lastUpdate` | `LocalDateTime!` |
| `version` | `Version!` |
| `position` | `String` |
| `contextId` | `String` |
| `functionId` | `String` |
| `informationTypeId` | `String` |
| `qbNumber` | `String` |

### SearchResponse

| Field | Returns |
|-------|---------|
| `results` | `[DocumentSearchResult!]!` |
| `pageInfo` | `PageInfo!` |
| `car` | `CarRelease` |

### DocumentSearchResult

| Field | Returns |
|-------|---------|
| `document` | `Document!` |
| `matchingParagraph` | `[String!]!` |
| `score` | `Float` |

### PageInfo

| Field | Returns |
|-------|---------|
| `resultCount` | `Int!` |
| `next` | `Int` |

---

## Enums

### CarSearchType / MarketSearchType
`LATEST_INFO` · `SUPPORT_ARTICLE` · `USER_MANUAL` · `SOFTWARE_RELEASE_NOTES` · `QUALITY_BULLETIN` · `KNOWLEDGE`

### DocumentType
`QUICK_GUIDE` · `HOTSPOT_ARTICLE` · `LEGAL_DOCUMENT` · `USER_MANUAL` · `QUALITY_BULLETIN` · `SUPPORT_ARTICLE` · `SOFTWARE_RELEASE_NOTES` · `SOFTWARE_RELEASE_NOTES_DIFF` · `SERVICE_AND_WARRANTY` · `LATEST_INFO` · `SUPPORT_CONTENT` · `KNOWLEDGE` · `CONTEXTUAL_KNOWLEDGE`

### DocumentAttribute
`ARTICLE` · `CATEGORY` · `SITUATION` · `GRACENOTE_DOWNLOADS` · `SOFTWARE_UPDATES` · `VOICE_CONTROL_DOWNLOADS` · `MAP_DOWNLOADS_SPA` · `MAP_DOWNLOADS_MCA` · `MAP_DOWNLOADS_IAM21` · `MAP_DOWNLOADS` · `USER_MANUALS` · `LEGAL_LINK` · `CAR_SELECTOR` · `CAR_MODELS` · `DOCUMENT_SHORTCUT` · `SUNSET_LINK`

### DocumentSource
`VO` · `SP` · `CS` · `VC`

---

## Example Queries

### 1. List all markets

```graphql
{
  markets {
    id
    caption
    marketCode
    countryCodes
  }
}
```

### 2. Search for articles by keyword (car-scoped — recommended)

Search returns best results when scoped to a specific car model. `SearchResult` is an interface — use `... on DocumentSearchResult` to access document fields.

```graphql
{
  market(id: "us") {
    carByModelSlug(modelSlug: "xc60") {
      displayName
      modelYear
      search(q: "tyre pressure", include: [USER_MANUAL, SUPPORT_ARTICLE], language: "en", maxResults: 5) {
        pageInfo { resultCount next }
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
}
```

Market-level search is also available via `market(id: "...") { search(...) { ... } }` but may return fewer results.

### 3. Get a specific document by ID

```graphql
{
  market(id: "se") {
    document(documentId: "some-document-id", language: ["en"]) {
      documentId
      stringContent { title description }
      jsonContent { body }
      children {
        documentId
        stringContent { title }
      }
    }
  }
}
```

### 4. List available cars and their PDFs

```graphql
{
  market(id: "se") {
    carsByDisplayName {
      displayName
      modelSlug
      cars {
        modelYear
        projectCode
        pdfs(language: ["en"]) {
          list {
            title
            url
            language
          }
        }
      }
    }
  }
}
```

### 5. Browse knowledge articles

```graphql
{
  market(id: "se") {
    knowledge(language: ["en"]) {
      exists
      topLevelDocuments {
        documentId
        stringContent { title }
        children {
          documentId
          stringContent { title }
        }
      }
    }
  }
}
```

### 6. Look up a car by VIN

```graphql
{
  carByVin(vin: "YV1XZ12345678") {
    displayName
    modelYear
    modelSlug
    availableLanguages {
      userManual
      knowledge
    }
  }
}
```

### 7. Car-specific search

```graphql
{
  market(id: "se") {
    carByModelSlug(modelSlug: "xc60") {
      displayName
      modelYear
      search(q: "child seat", include: [USER_MANUAL], language: "en", maxResults: 3) {
        results {
          document {
            documentId
            stringContent { title description }
          }
        }
      }
    }
  }
}
```

---

## Additional Types

### Knowledge / ContextualKnowledge / UserManual / QuickGuide / ServiceAndWarranty / SupportContent

All follow a similar pattern:
- `exists: Boolean!` — whether content is available
- `topLevelDocuments: [Document!]!` — root-level documents for browsing
- `document(documentId): Document` — fetch a specific document
- `documents(attributes, documentIds): [Document!]!` — fetch multiple documents

### CarAvailableLanguages

Lists available language codes per content type: `knowledge`, `qualityBulletins`, `quickGuide`, `releaseNotes`, `userManual`.

### SoftwareUpdateInformation

| Field | Returns |
|-------|---------|
| `id` | `String!` |
| `message` | `String!` |
| `vehicleName` | `String` |
| `vehicleCode` | `String` |
| `carModelYear` | `String` |
| `structureWeek` | `String` |
| `registrationNumber` | `String` |
