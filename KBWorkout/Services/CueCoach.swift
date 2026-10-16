import AVFoundation
import UIKit

/// Spoken cues and haptics. Ducks (rather than stops) any music that is playing.
final class CueCoach: NSObject, AVSpeechSynthesizerDelegate {
    private let synthesizer = AVSpeechSynthesizer()
    private let tapHaptic = UIImpactFeedbackGenerator(style: .rigid)
    private let doneHaptic = UINotificationFeedbackGenerator()
    var voiceEnabled = true

    override init() {
        super.init()
        synthesizer.delegate = self
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .voicePrompt,
                                                         options: [.duckOthers, .mixWithOthers])
    }

    func say(_ text: String) {
        guard voiceEnabled else { return }
        try? AVAudioSession.sharedInstance().setActive(true)
        if synthesizer.isSpeaking { synthesizer.stopSpeaking(at: .word) }
        // Symbols used in the workout text read badly aloud.
        let spoken = text
            .replacingOccurrences(of: "→", with: ", then ")
            .replacingOccurrences(of: "·", with: ", ")
            .replacingOccurrences(of: "/", with: " and ")
        let utterance = AVSpeechUtterance(string: spoken)
        utterance.rate = 0.52
        synthesizer.speak(utterance)
    }

    func silence() {
        synthesizer.stopSpeaking(at: .immediate)
    }

    func countdownTick() { tapHaptic.impactOccurred() }

    func stepChanged() { doneHaptic.notificationOccurred(.success) }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        guard !synthesizer.isSpeaking else { return }
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}
