import XCTest
// TranscribeService.swift compiled into this test target.

final class TranscribeTests: XCTestCase {
    func testRecorderInitialState() async {
        let recorder = await Recorder()
        let isRecording = await recorder.isRecording
        let isTranscribing = await recorder.isTranscribing
        XCTAssertFalse(isRecording)
        XCTAssertFalse(isTranscribing)
    }

    func testRemoteSummaryNotConfigured() async {
        do {
            _ = try await RemoteTranscriber(apiKey: "x").summary(of: "hello world")
            XCTFail("should throw notConfigured")
        } catch TranscribeError.notConfigured {
            // expected
        } catch {
            XCTFail("unexpected error: \(error)")
        }
    }
}
