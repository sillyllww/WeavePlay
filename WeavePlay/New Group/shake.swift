import SwiftUI
import CoreMotion

class ShakeDetector: ObservableObject {
    private var motionManager = CMMotionManager()
    @Published var isShaken = false // 用于记录是否摇动

    init() {
        startMonitoring()
    }
    
    private func startMonitoring() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.1
            motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
                guard let data = data else { return }
                self?.detectShake(acceleration: data.acceleration)
            }
        }
    }
    
    private func detectShake(acceleration: CMAcceleration) {
        let threshold: Double = 2.5
        if abs(acceleration.x) > threshold || abs(acceleration.y) > threshold || abs(acceleration.z) > threshold {
            isShaken = true // 标记为摇动
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.isShaken = false // 一秒后重置
            }
        }
    }
}
