import SwiftUI

/// A reusable SwiftUI button that manages loading, success, error,
/// and double-tap prevention for asynchronous actions.
public struct AsyncButton<Label: View>: View {
    private let action: () async throws -> Void
    private let label: () -> Label
    private let minimumLoadingDuration: TimeInterval
    private let showsSuccessState: Bool
    private let successSystemImage: String
    private let successDisplayDuration: TimeInterval
    private let onError: ((Error) -> Void)?

    @State private var isLoading = false
    @State private var didSucceed = false
    @State private var actionTask: Task<Void, Never>?

    public init(
        minimumLoadingDuration: TimeInterval = 0.35,
        showsSuccessState: Bool = true,
        successSystemImage: String = "checkmark",
        successDisplayDuration: TimeInterval = 0.7,
        onError: ((Error) -> Void)? = nil,
        action: @escaping () async throws -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.minimumLoadingDuration = AsyncButtonConfiguration.normalizedDuration(
            minimumLoadingDuration,
            minimum: 0,
            fallback: 0.35
        )
        self.showsSuccessState = showsSuccessState
        self.successSystemImage = successSystemImage
        self.successDisplayDuration = AsyncButtonConfiguration.normalizedDuration(
            successDisplayDuration,
            minimum: 0,
            fallback: 0.7
        )
        self.onError = onError
        self.action = action
        self.label = label
    }

    public var body: some View {
        Button {
            startAction()
        } label: {
            ZStack {
                label()
                    .opacity(isLoading || didSucceed ? 0 : 1)

                if isLoading {
                    ProgressView()
                        .controlSize(.small)
                        .accessibilityHidden(true)
                } else if didSucceed {
                    Image(systemName: successSystemImage)
                        .accessibilityHidden(true)
                }
            }
        }
        .disabled(isLoading)
        .accessibilityValue(accessibilityState)
        .onDisappear {
            actionTask?.cancel()
            actionTask = nil
        }
    }

    private var accessibilityState: String {
        if isLoading {
            return "Loading"
        }

        if didSucceed {
            return "Completed"
        }

        return ""
    }

    private func startAction() {
        guard !isLoading else { return }

        actionTask?.cancel()

        actionTask = Task { @MainActor in
            await performAction()
        }
    }

    @MainActor
    private func performAction() async {
        isLoading = true
        didSucceed = false

        let startedAt = Date()

        do {
            try await action()
            await enforceMinimumLoadingDuration(since: startedAt)

            guard !Task.isCancelled else {
                isLoading = false
                return
            }

            isLoading = false

            guard showsSuccessState else { return }

            didSucceed = true
            await sleep(for: successDisplayDuration)

            guard !Task.isCancelled else { return }
            didSucceed = false
        } catch is CancellationError {
            isLoading = false
            didSucceed = false
        } catch {
            await enforceMinimumLoadingDuration(since: startedAt)

            guard !Task.isCancelled else {
                isLoading = false
                return
            }

            isLoading = false
            didSucceed = false
            onError?(error)
        }
    }

    @MainActor
    private func enforceMinimumLoadingDuration(since startDate: Date) async {
        let elapsed = Date().timeIntervalSince(startDate)
        let remaining = minimumLoadingDuration - elapsed

        guard remaining > 0 else { return }
        await sleep(for: remaining)
    }

    @MainActor
    private func sleep(for duration: TimeInterval) async {
        guard duration > 0 else { return }

        do {
            try await Task.sleep(
                nanoseconds: UInt64(duration * 1_000_000_000)
            )
        } catch {
            return
        }
    }
}

public extension AsyncButton where Label == Text {
    init(
        _ title: String,
        minimumLoadingDuration: TimeInterval = 0.35,
        showsSuccessState: Bool = true,
        successSystemImage: String = "checkmark",
        successDisplayDuration: TimeInterval = 0.7,
        onError: ((Error) -> Void)? = nil,
        action: @escaping () async throws -> Void
    ) {
        self.init(
            minimumLoadingDuration: minimumLoadingDuration,
            showsSuccessState: showsSuccessState,
            successSystemImage: successSystemImage,
            successDisplayDuration: successDisplayDuration,
            onError: onError,
            action: action
        ) {
            Text(title)
        }
    }
}

enum AsyncButtonConfiguration {
    static func normalizedDuration(
        _ value: TimeInterval,
        minimum: TimeInterval,
        fallback: TimeInterval
    ) -> TimeInterval {
        guard value.isFinite else {
            return fallback
        }

        return max(value, minimum)
    }
}

#Preview {
    VStack(spacing: 20) {
        AsyncButton("Save") {
            try await Task.sleep(nanoseconds: 1_000_000_000)
        }
        .buttonStyle(.borderedProminent)

        AsyncButton(
            showsSuccessState: false,
            action: {
                try await Task.sleep(nanoseconds: 700_000_000)
            }
        ) {
            Label("Upload", systemImage: "arrow.up.circle")
        }
        .buttonStyle(.bordered)
    }
    .padding()
}
