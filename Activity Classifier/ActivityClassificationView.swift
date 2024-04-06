//
//  ContentView.swift
//  Activity Classifier
//
//  Created by Antonis Keremidis on 5/4/24.
//

import CoreML
import SwiftUI

struct ActivityClassificationView: View {
    @StateObject var classifier = ActivityClassifier()

    var body: some View {
        VStack {
            VStack {
                Text("Samples Collected")
                ProgressView(value: Float(classifier.timeSeries.count) / (87 * 3))
            }
            Spacer()
            Text("Current Activity:")
                .font(.headline)
            Text(classifier.currentActivity?.debugDescription ?? "None")
                .font(.title)
                .fontWeight(.bold)
            VStack {
                if (classifier.detectingActivity) {
                    Button(action: {
                        classifier.stop()
                        classifier.timeSeries = []
                        classifier.motionManager = nil
                    }, label: {
                        Text("Stop")
                    })
                } else {
                    Button(action: {
                        classifier.start()
                    }, label: {
                        Text("Start")
                    })
                }
            }
            .padding()
            ChartView(classifier: classifier)
        }
        .padding()
    }
}

#Preview {
    ActivityClassificationView()
}
