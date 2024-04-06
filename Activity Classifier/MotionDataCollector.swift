import Foundation
import CoreMotion

class MotionDataCollector {
    private let motion = CMMotionManager()
    private var timer: Timer? = nil

    let predict: ([Double]) -> Void

    init(predict: @escaping ([Double]) -> Void) {
        self.predict = predict
        // Make sure the accelerometer hardware is available.
        if self.motion.isAccelerometerAvailable {
            self.motion.accelerometerUpdateInterval = 1.0 / 25.0  // 25 Hz
            self.motion.startAccelerometerUpdates()

            // Configure a timer to fetch the data.
            self.timer = Timer(fire: Date(), interval: (1.0/25.0),
                               repeats: true, block: { (timer) in
                // Get the accelerometer data.
                if let data = self.motion.accelerometerData {
                    let x = data.acceleration.x
                    let y = data.acceleration.y
                    let z = data.acceleration.z

                    let timeSeriesElement = [x,y,z]
                    predict(timeSeriesElement)
                }
            })

            // Add the timer to the current run loop.
            RunLoop.current.add(self.timer!, forMode: .default)
        }
    }

    deinit {
        timer?.invalidate()
    }
}
