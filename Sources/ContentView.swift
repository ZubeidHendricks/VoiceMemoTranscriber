import SwiftUI
import AppFactoryKit

// Voice Memo Transcriber — record audio and transcribe it on-device with the
// Speech framework. Pro unlocks unlimited length, export, and AI summaries
// (wired behind RemoteTranscriber).
struct ContentView: View {
    @EnvironmentObject private var factory: AppFactory
    @StateObject private var recorder = Recorder()
    @State private var authorized = false
    @State private var shareItem: ShareItem?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                recordButton
                Text(timeString(recorder.elapsed))
                    .font(.system(size: 34, weight: .semibold, design: .monospaced))
                    .foregroundStyle(recorder.isRecording ? .pink : .secondary)

                if recorder.isTranscribing { ProgressView("Transcribing…") }

                if !recorder.transcript.isEmpty {
                    ScrollView {
                        Text(recorder.transcript)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .textSelection(.enabled)
                            .padding()
                    }
                    .background(RoundedRectangle(cornerRadius: 14).fill(.quaternary.opacity(0.5)))
                    transcriptActions
                }
                if let e = recorder.errorText { Text(e).font(.footnote).foregroundStyle(.red) }
                Spacer()
            }
            .padding(20)
            .navigationTitle("Transcribe")
        }
        .task { authorized = await recorder.requestPermissions() }
        .sheet(item: $shareItem) { ActivityView(items: $0.items) }
    }

    private var recordButton: some View {
        Button { recorder.toggle() } label: {
            ZStack {
                Circle().fill(recorder.isRecording ? Color.pink : Color.pink.opacity(0.18))
                    .frame(width: 120, height: 120)
                Image(systemName: recorder.isRecording ? "stop.fill" : "mic.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(recorder.isRecording ? .white : .pink)
            }
        }
        .buttonStyle(.plain)
        .disabled(!authorized || recorder.isTranscribing)
    }

    private var transcriptActions: some View {
        HStack(spacing: 12) {
            Button {
                UIPasteboard.general.string = recorder.transcript
            } label: { Label("Copy", systemImage: "doc.on.doc").frame(maxWidth: .infinity, minHeight: 46) }
            .buttonStyle(.bordered)

            Button {
                factory.requirePremium(feature: "export_transcript") {
                    let url = FileManager.default.temporaryDirectory.appendingPathComponent("transcript.txt")
                    try? recorder.transcript.write(to: url, atomically: true, encoding: .utf8)
                    shareItem = ShareItem(items: [url])
                }
            } label: { Label("Export", systemImage: "square.and.arrow.up").frame(maxWidth: .infinity, minHeight: 46) }
            .buttonStyle(.borderedProminent).tint(.pink)
        }
    }

    private func timeString(_ t: TimeInterval) -> String {
        String(format: "%02d:%02d", Int(t) / 60, Int(t) % 60)
    }
}

struct ShareItem: Identifiable { let id = UUID(); let items: [Any] }

struct ActivityView: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}
