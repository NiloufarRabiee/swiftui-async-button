import SwiftUI
import AsyncButton

struct SaveProfileExample: View {
    @State private var status = "Ready"

    var body: some View {
        VStack(spacing: 16) {
            Text(status)
                .foregroundStyle(.secondary)

            AsyncButton(
                "Save profile",
                minimumLoadingDuration: 0.5,
                onError: { error in
                    status = error.localizedDescription
                }
            ) {
                status = "Saving..."
                try await saveProfile()
                status = "Saved"
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    private func saveProfile() async throws {
        try await Task.sleep(nanoseconds: 900_000_000)
    }
}
