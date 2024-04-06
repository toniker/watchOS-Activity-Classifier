//
//  ActivityClassifier+ChartView.swift
//  Activity Classifier
//
//  Created by Antonis Keremidis on 5/4/24.
//

import SwiftUI
import Charts

struct ChartView: View {
    @ObservedObject var classifier: ActivityClassifier

    var body: some View {
        Chart(classifier.classifiedActivities) { activity in
            BarMark(x: .value("Activity", activity.type.debugDescription),
                    y: .value("Confidence", activity.confidence))
        }
    }
}

#Preview {
    @StateObject var classifier = ActivityClassifier()
    classifier.classifiedActivities = [
        .init(type: .Walking, confidence: 0.8),
        .init(type: .Running, confidence: 0.1),
        .init(type: .Standing, confidence: 0.1)
    ]
    return ChartView(classifier: classifier)
}
