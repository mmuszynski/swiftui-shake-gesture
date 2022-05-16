import SwiftUI

public extension Notification.Name {
    static let shakeEnded = Notification.Name("ShakeEnded")
    static let shakeBegan = Notification.Name("ShakeBegan")
}

public extension UIWindow {
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: .shakeBegan, object: nil)
        }
        super.motionEnded(motion, with: event)
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: .shakeEnded, object: nil)
        }
        super.motionEnded(motion, with: event)
    }
}

struct ShakeBeganDetector: ViewModifier {
    let onShakeBegan: () -> Void
    
    func body(content: Content) -> some View {
        content
            .onAppear() // this has to be here because of a SwiftUI bug
            .onReceive(NotificationCenter.default.publisher(for: .shakeBegan)) { _ in
                onShakeBegan()
            }
    }
}

struct ShakeEndedDetector: ViewModifier {
    let onShakeEnded: () -> Void
    
    func body(content: Content) -> some View {
        content
            .onAppear() // this has to be here because of a SwiftUI bug
            .onReceive(NotificationCenter.default.publisher(for: .shakeEnded)) { _ in
                onShakeEnded()
            }
    }
}

public extension View {
    func onShakeBegan(perform action: @escaping () -> Void) -> some View {
        self.modifier(ShakeBeganDetector(onShakeBegan: action))
    }
    func onShakeEnded(perform action: @escaping () -> Void) -> some View {
        self.modifier(ShakeEndedDetector(onShakeEnded: action))
    }
}

struct ShakeTest: View {
    @State private var text = "Shake me!"
    
    var body: some View {
        Text(text)
            .onShakeBegan {
                text = "Currently shaking"
            }
            .onShakeEnded {
                text = "Shake ended at \(Date())"
            }
    }
}
