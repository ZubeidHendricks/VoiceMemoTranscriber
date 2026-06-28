import Foundation
import AVFoundation
import Speech
import Combine

enum TranscribeError: Error { case notAuthorized, recognizerUnavailable, notConfigured }

/// Records audio and transcribes it on-device with the Speech framework.
@MainActor
final class Recorder: ObservableObject {
    @Published var isRecording = false
    @Published var isTranscribing = false
    @Published var transcript = ""
    @Published var elapsed: TimeInterval = 0
    @Published var errorText: String?

    private var recorder: AVAudioRecorder?
    private var timer: Timer?
    private var fileURL: URL?
    private let recognizer = SFSpeechRecognizer()

    func requestPermissions() async -> Bool {
        await withCheckedContinuation { cont in
            SFSpeechRecognizer.requestAuthorization { status in
                cont.resume(returning: status == .authorized)
            }
        }
    }

    func toggle() {
        if isRecording { stopAndTranscribe() } else { start() }
    }

    private func start() {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("memo-\(Int(Date().timeIntervalSince1970)).m4a")
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        ]
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
            let rec = try AVAudioRecorder(url: url, settings: settings)
            rec.record()
            recorder = rec
            fileURL = url
            isRecording = true
            transcript = ""
            elapsed = 0
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                Task { @MainActor in self?.elapsed += 1 }
            }
        } catch {
            errorText = "Couldn't start recording."
        }
    }

    private func stopAndTranscribe() {
        recorder?.stop()
        timer?.invalidate(); timer = nil
        isRecording = false
        guard let url = fileURL else { return }
        guard let recognizer, recognizer.isAvailable else { errorText = "Speech recognizer unavailable."; return }
        isTranscribing = true
        let request = SFSpeechURLRecognitionRequest(url: url)
        request.requiresOnDeviceRecognition = recognizer.supportsOnDeviceRecognition
        recognizer.recognitionTask(with: request) { [weak self] result, error in
            Task { @MainActor in
                guard let self else { return }
                if let result, result.isFinal {
                    self.transcript = result.bestTranscription.formattedString
                    self.isTranscribing = false
                } else if let result {
                    self.transcript = result.bestTranscription.formattedString
                } else if error != nil {
                    self.isTranscribing = false
                    if self.transcript.isEmpty { self.errorText = "Couldn't transcribe that recording." }
                }
            }
        }
    }
}

/// Cloud transcription + AI summary seam (Whisper/your endpoint).
struct RemoteTranscriber {
    let apiKey: String
    func summary(of text: String) async throws -> String { throw TranscribeError.notConfigured }
}
