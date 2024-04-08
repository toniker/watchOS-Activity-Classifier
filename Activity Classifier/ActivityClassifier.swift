//
//  ActivityClassifier.swift
//  Activity Classifier
//
//  Created by Antonis Keremidis on 5/4/24.
//

import CoreML
import Foundation

class ActivityClassifier: ObservableObject {
    @Published var currentActivity: Activity? = nil
    @Published var detectingActivity = false
    @Published var classifiedActivities: [ClassifiedActivity] = []

    @Published var timeSeries: [[Double]]

    var motionManager: MotionDataCollector? = nil

    let model: ActivityClassificationModel

    init() {
        self.timeSeries = [[Double]]()
        do {
            self.model = try ActivityClassificationModel()
        }
        catch {
            fatalError()
        }
    }

    public func start() {
        self.detectingActivity = true
        self.motionManager = MotionDataCollector(predict: { [self] row in
            timeSeries.append(row)
            if (timeSeries.count != 87 * 3) {
                return
            }

            do {
                guard let multiArray = try? MLMultiArray(shape: [1, 87, 3], dataType: MLMultiArrayDataType.double) else {
                    return
                }

                for i in 0..<87 {
                    for j in 0..<3 {
                        let value = timeSeries[i][j]
                        multiArray[i * 3 + j] = NSNumber(value: value)
                    }
                }

                timeSeries = [[Double]]()
                assert(timeSeries.isEmpty)

                let modelOutput: ActivityClassificationModelOutput = try self.model.prediction(input: .init(gru_input: multiArray))

                if let pointer = try? UnsafeBufferPointer<Float>(modelOutput.Identity) {
                    self.classifiedActivities = []
                    let array = Array(pointer)
                    self.classifiedActivities = array.map({ confidence in
                        let index = array.firstIndex(of: confidence)!
                        let activity = Activity(rawValue: index + 1)!
                        return ClassifiedActivity(type: activity, confidence: confidence)
                    })

                    let max = array.max()!
                    guard let index = array.firstIndex(of: max) else {
                        print("Floating point error")
                        return
                    }

                    self.currentActivity = Activity(rawValue: index + 1)
                }
            }
            catch {
                self.currentActivity = nil
                return
            }
        })
    }

    public func stop() {
        self.detectingActivity = false
        self.motionManager?.stop()
    }

    enum Activity: Int, CustomDebugStringConvertible {
        case BrushingTeeth = 1
        case Cycling = 2
        case Lying = 3
        case Running = 4
        case Sitting = 5
        case StairsDown = 6
        case StairsUp = 7
        case Standing = 8
        case Walking = 9

        var debugDescription: String {
            switch self {
            case .Walking: "Walking"
            case .Standing: "Standing"
            case .BrushingTeeth: "BrushingTeeth"
            case .Cycling: "Cycling"
            case .Lying: "Lying"
            case .Running: "Running"
            case .Sitting: "Sitting"
            case .StairsDown: "StairsDown"
            case .StairsUp: "StairsUp"
            }
        }
    }
    
    struct ClassifiedActivity: Identifiable {
        let type: Activity
        let confidence: Float
        let id = UUID()
    }
}
