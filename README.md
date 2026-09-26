# AsyncButton

A lightweight reusable **SwiftUI button for async actions with automatic loading state and double-tap prevention**.

It is useful for operations such as:

- Saving
- Uploading
- Login
- Form submission
- API requests
- Synchronization
- Remote actions

## Features

- Native SwiftUI
- No third-party dependencies
- Automatic loading state
- Prevents repeated taps while running
- Supports `async/await`
- Supports throwing async actions
- Optional success state
- Custom success system image
- Optional error callback
- Configurable minimum loading duration
- Configurable success display duration
- Custom SwiftUI labels
- iOS and macOS support
- Swift Package Manager support

## Requirements

- iOS 16+
- macOS 13+
- Swift 5.9+

## Installation

### Swift Package Manager

In Xcode:

1. Open your project.
2. Go to **File > Add Package Dependencies...**
3. Enter:

```
https://github.com/NiloufarRabiee/swiftui-async-button
```

4. Add the `AsyncButton` package to your app target.

Then import it:

```swift
import AsyncButton
```

## Basic Usage

```swift
AsyncButton("Save") {
    await saveChanges()
}
```

While the action is running, the button automatically shows a progress indicator and disables itself.

## Throwing Actions

```swift
AsyncButton(
    "Upload",
    onError: { error in
        print(error.localizedDescription)
    }
) {
    try await uploadFile()
}
```

## Custom Label

```swift
AsyncButton(
    action: {
        try await syncData()
    }
) {
    Label("Sync", systemImage: "arrow.triangle.2.circlepath")
}
```

## Disable the Success State

```swift
AsyncButton(
    "Refresh",
    showsSuccessState: false
) {
    await refresh()
}
```

## Custom Success Icon

```swift
AsyncButton(
    "Send",
    successSystemImage: "paperplane.fill"
) {
    try await sendMessage()
}
```

## Minimum Loading Duration

Fast operations can make a progress indicator appear and disappear too quickly.

Use `minimumLoadingDuration` to prevent visual flicker:

```swift
AsyncButton(
    "Save",
    minimumLoadingDuration: 0.5
) {
    await save()
}
```

The loading indicator remains visible for at least the configured duration, even if the async work finishes sooner.

## Parameters

| Parameter | Description | Default |
|---|---|---|
| `minimumLoadingDuration` | Minimum time the loading state remains visible | `0.35` |
| `showsSuccessState` | Shows a success symbol after completion | `true` |
| `successSystemImage` | SF Symbol used for the success state | `checkmark` |
| `successDisplayDuration` | Time the success state remains visible | `0.7` |
| `onError` | Optional callback for thrown errors | `nil` |
| `action` | Async or throwing async operation | Required |
| `label` | Custom SwiftUI label | Required for the generic initializer |

## Double-Tap Prevention

As soon as the action begins, the button enters its loading state and becomes disabled.

Repeated taps cannot start duplicate async operations while the current action is running.

## Cancellation

If the button disappears while its task is active, the task is cancelled.

Async work passed to `AsyncButton` should cooperate with Swift task cancellation when appropriate.

## Example

A complete save example is included in:

```
Examples/SaveProfileExample.swift
```

## Testing

Run:

```bash
swift test
```

GitHub Actions CI is included.

## Contributing

Contributions and improvements are welcome.

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

This project is available under the MIT License.

See [LICENSE](LICENSE).

---

Created by **Niloufar Rabiee**
