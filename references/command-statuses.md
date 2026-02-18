# Connected Vehicle API — Command Invoke Statuses

When you send a POST command to the Connected Vehicle API, the response includes an `invokeStatus` field. Here are all 22 possible values and what they mean:

| Status | Meaning |
|--------|---------|
| `WAITING` | Command received and queued — waiting to be sent to the vehicle. |
| `SENT` | Command has been sent to the vehicle but no acknowledgement yet. |
| `DELIVERED` | Command was delivered to the vehicle successfully. |
| `RUNNING` | Command is currently being executed by the vehicle. |
| `COMPLETED` | Command executed successfully. |
| `SUCCESS` | Command completed with a confirmed success status. |
| `REJECTED` | Vehicle rejected the command (e.g., preconditions not met). |
| `UNKNOWN` | Status could not be determined. |
| `TIMEOUT` | Command timed out waiting for a response from the vehicle. |
| `CAR_TIMEOUT` | Vehicle did not respond within the expected time window. |
| `DELIVERY_TIMEOUT` | Command could not be delivered to the vehicle in time. |
| `EXPIRED` | Command expired before it could be executed. |
| `CONNECTION_FAILURE` | Failed to establish a connection with the vehicle. |
| `VEHICLE_IN_SLEEP` | Vehicle is in deep sleep mode and cannot receive commands. Wake the vehicle (open a door, use the Volvo Cars app) and retry. |
| `CAR_IN_SLEEP_MODE` | Same as `VEHICLE_IN_SLEEP` — vehicle is in deep sleep. |
| `CAR_ERROR` | Vehicle reported an error while executing the command. |
| `NOT_SUPPORTED` | This command is not supported by the vehicle model or configuration. |
| `NOT_ALLOWED_PRIVACY_ENABLED` | Command blocked because the vehicle has privacy mode enabled. Disable privacy mode in the vehicle settings to allow remote commands. |
| `NOT_ALLOWED_WRONG_USAGE_MODE` | Command cannot be executed in the vehicle's current usage mode (e.g., valet mode). |
| `UNLOCK_TIME_FRAME_PASSED` | The time window for unlocking has expired. Resend the unlock command. |
| `UNABLE_TO_LOCK_DOOR_OPEN` | Cannot lock because one or more doors are open. Close all doors and retry. |
| `INVOCATION_SPECIFIC_ERROR` | A command-specific error occurred. Check the `message` field for details. |

## Status Flow

A typical successful command goes through:
```
WAITING → SENT → DELIVERED → RUNNING → COMPLETED/SUCCESS
```

## Actionable Statuses

**Retriable (after fixing the condition):**
- `VEHICLE_IN_SLEEP` / `CAR_IN_SLEEP_MODE` — wake the vehicle first
- `UNABLE_TO_LOCK_DOOR_OPEN` — close doors first
- `UNLOCK_TIME_FRAME_PASSED` — resend the unlock command
- `TIMEOUT` / `CAR_TIMEOUT` / `DELIVERY_TIMEOUT` — try again later
- `CONNECTION_FAILURE` — check vehicle connectivity

**Not retriable (requires configuration change):**
- `NOT_SUPPORTED` — vehicle doesn't support this command
- `NOT_ALLOWED_PRIVACY_ENABLED` — disable privacy mode on vehicle
- `NOT_ALLOWED_WRONG_USAGE_MODE` — change vehicle usage mode
- `REJECTED` — check preconditions
