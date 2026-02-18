# Volvo Connected Vehicle API v2 — Reference

**Base URL:** `https://api.volvocars.com/connected-vehicle/v2`

**Required Headers:**
- `vcc-api-key: <your-api-key>` — from [developer.volvocars.com](https://developer.volvocars.com)
- `Authorization: Bearer <access-token>` — OAuth2 token from Volvo ID
- `Content-Type: application/json`

---

## Vehicle

### List vehicles
```
GET /vehicles
```
Returns all VINs linked to the authenticated Volvo ID.

**Required Scope:** `conve:vehicle_relation`

**Response:**
```json
{ "vin": "YV1XZ12345678" }
```

---

### Get vehicle details
```
GET /vehicles/{vin}
```
Returns model, model year, fuel type, colour, battery capacity, and images.

**Required Scope:** `conve:vehicle_relation`

**Response:**
```json
{
  "vin": "string",
  "modelYear": 2024,
  "gearbox": "string",
  "fuelType": "string",
  "externalColour": "string",
  "batteryCapacityKWH": 0.0,
  "images": {
    "exteriorImageUrl": "string",
    "internalImageUrl": "string"
  },
  "descriptions": {
    "model": "string",
    "upholstery": "string",
    "steering": "string"
  }
}
```

---

## Doors, Windows & Locks

### Get door and lock status
```
GET /vehicles/{vin}/doors
```
**Response fields:** `centralLock`, `frontLeftDoor`, `frontRightDoor`, `rearLeftDoor`, `rearRightDoor`, `hood`, `tailgate`, `tankLid`

Each field: `{ "value": "string", "unit": "string", "timestamp": "ISO-8601" }`

---

### Get window status
```
GET /vehicles/{vin}/windows
```
**Response fields:** `frontLeftWindow`, `frontRightWindow`, `rearLeftWindow`, `rearRightWindow`, `sunroof`

Each field: `{ "value": "string", "unit": "string", "timestamp": "ISO-8601" }`

---

## Engine

### Get engine status
```
GET /vehicles/{vin}/engine-status
```
**Response:**
```json
{
  "engineStatus": { "value": "RUNNING", "unit": "string", "timestamp": "ISO-8601" }
}
```

---

### Get engine diagnostics
```
GET /vehicles/{vin}/engine
```
**Response fields:** `oilLevelWarning`, `engineCoolantLevelWarning`

---

## Fuel & Odometer

### Get fuel amount
```
GET /vehicles/{vin}/fuel
```
**Response:**
```json
{
  "fuelAmount": { "value": 45.5, "unit": "liters", "timestamp": "ISO-8601" }
}
```

---

### Get odometer value
```
GET /vehicles/{vin}/odometer
```
**Response:**
```json
{
  "odometer": { "value": 54321, "unit": "kilometers", "timestamp": "ISO-8601" }
}
```

---

## Diagnostics

### Get diagnostic values
```
GET /vehicles/{vin}/diagnostics
```
**Response fields:** `serviceWarning`, `serviceTrigger`, `engineHoursToService`, `distanceToService`, `washerFluidLevelWarning`, `timeToService`

---

### Get brake fluid level
```
GET /vehicles/{vin}/brakes
```
**Response:**
```json
{
  "brakeFluidLevelWarning": { "value": "string", "unit": "string", "timestamp": "ISO-8601" }
}
```

---

## Tyres

### Get tyre status
```
GET /vehicles/{vin}/tyres
```
**Response:**
```json
{
  "status": 0,
  "operationId": "string",
  "data": {
    "frontLeft": { "value": "string", "timestamp": "ISO-8601" },
    "frontRight": { "value": "string", "timestamp": "ISO-8601" },
    "rearLeft": { "value": "string", "timestamp": "ISO-8601" },
    "rearRight": { "value": "string", "timestamp": "ISO-8601" }
  }
}
```

---

## Warnings

### Get warnings
```
GET /vehicles/{vin}/warnings
```
Returns bulb/light failure warnings. Fields include: `brakeLightCenterWarning`, `brakeLightLeftWarning`, `brakeLightRightWarning`, `fogLightFrontWarning`, `fogLightRearWarning`, `positionLightFrontLeftWarning`, `positionLightFrontRightWarning`, `positionLightRearLeftWarning`, `positionLightRearRightWarning`, `highBeamLeftWarning`, `highBeamRightWarning`, `lowBeamLeftWarning`, `lowBeamRightWarning`, `daytimeRunningLightLeftWarning`, `daytimeRunningLightRightWarning`, `turnIndicationFrontLeftWarning`, `turnIndicationFrontRightWarning`, `turnIndicationRearLeftWarning`, `turnIndicationRearRightWarning`, `registrationPlateLightWarning`, `sideMarkLightsWarning`, `hazardLightsWarning`, `reverseLightsWarning`

Each field: `{ "value": "string", "unit": "string", "timestamp": "ISO-8601" }`

---

## Statistics

### Get statistics
```
GET /vehicles/{vin}/statistics
```
**Response:**
```json
{
  "status": 0,
  "operationId": "string",
  "data": {
    "averageSpeed": { "value": "string", "timestamp": "ISO-8601", "unit": "string" },
    "distanceToEmpty": { "value": "string", "timestamp": "ISO-8601", "unit": "string" },
    "tripMeter1": { "value": "string", "timestamp": "ISO-8601", "unit": "string" },
    "tripMeter2": { "value": "string", "timestamp": "ISO-8601", "unit": "string" },
    "averageFuelConsumption": { "value": "string", "timestamp": "ISO-8601", "unit": "string" }
  }
}
```

---

## Commands

### List available commands
```
GET /vehicles/{vin}/commands
```
**Response:**
```json
{
  "status": 0,
  "operationId": "string",
  "data": [
    { "command": "HONK_AND_FLASH", "href": "string" }
  ]
}
```

Available commands: `HONK_AND_FLASH`, `HONK`, `FLASH`, `LOCK`, `LOCK_REDUCED_GUARD`, `UNLOCK`, `ENGINE_START`, `ENGINE_STOP`, `CLIMATIZATION_START`, `CLIMATIZATION_STOP`, `SEND_NAVI_POI`

---

### Get command accessibility
```
GET /vehicles/{vin}/command-accessibility
```
Check if the vehicle can receive commands.

**Response:**
```json
{
  "availabilityStatus": { "value": "AVAILABLE", "unit": "string", "timestamp": "ISO-8601" },
  "unavailableReason": { "value": "string", "unit": "string", "timestamp": "ISO-8601" }
}
```

---

## Command Invocations (POST)

All POST commands return the same base response:
```json
{
  "vin": "string",
  "invokeStatus": "WAITING",
  "message": "string"
}
```

See [command-statuses.md](command-statuses.md) for all possible `invokeStatus` values.

---

### Lock doors
```
POST /vehicles/{vin}/commands/lock
```
No request body required.

---

### Unlock doors
```
POST /vehicles/{vin}/commands/unlock
```
No request body required.

Additional response fields: `readyToUnlock` (boolean), `readyToUnlockUntil` (integer — seconds).

---

### Lock with reduced guard
```
POST /vehicles/{vin}/commands/lock-reduced-guard
```
No request body required. Locks with alarm in reduced sensitivity mode.

---

### Honk horn
```
POST /vehicles/{vin}/commands/honk
```
No request body required.

---

### Flash exterior lights
```
POST /vehicles/{vin}/commands/flash
```
No request body required.

---

### Honk and flash
```
POST /vehicles/{vin}/commands/honk-flash
```
No request body required.

---

### Start engine
```
POST /vehicles/{vin}/commands/engine-start
```
**Request body:**
```json
{
  "runtimeMinutes": 5
}
```
`runtimeMinutes` — integer, 1–15. How long the engine will run.

Check supported vehicles with `GET /vehicles/{vin}/commands` first.

---

### Stop engine
```
POST /vehicles/{vin}/commands/engine-stop
```
No request body required.

---

### Start climatisation
```
POST /vehicles/{vin}/commands/climatization-start
```
No request body required.

---

### Stop climatisation
```
POST /vehicles/{vin}/commands/climatization-stop
```
No request body required.

---

## Error Responses

All endpoints may return:

| Status | Description |
|--------|-------------|
| `400` | Bad request — invalid input |
| `401` | Unauthorized — token expired or invalid |
| `403` | Forbidden — insufficient permissions or scopes |
| `404` | Not found — VIN not linked to account or endpoint does not exist |
| `422` | Unprocessable — valid request but cannot be executed (e.g., command not supported) |
| `429` | Rate limited — too many requests |
| `500` | Internal server error |

**Error response format:**
```json
{
  "error": {
    "message": "string",
    "description": "string"
  }
}
```
