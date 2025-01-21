// Copyright © 2025 Safe Security
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy of this Project ("Software") from Safe Security, to use it solely for personal learning and internal demonstration.
// 
// **Restrictions:**
// 1. The Software may not be redistributed, sublicensed, or used commercially without prior written consent from Safe Security.
// 2. You must not remove or alter any copyright or proprietary notices.
// 3. You must not use this Software (or derivatives) in any way that harms, competes with, or discredits Safe Security.
// 
// THE SOFTWARE IS PROVIDED "AS IS," WITHOUT WARRANTY OF ANY KIND. IN NO EVENT SHALL SAFE SECURITY BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT, OR OTHERWISE, ARISING FROM, OUT OF, OR IN CONNECTION WITH THE SOFTWARE OR ITS USE.

import SwiftUI
import Charts

// MARK: - Views

struct TrendWidgetView: View {
    let widget: TrendWidget
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title = widget.riskScenarioName {
                Text(title)
                    .font(.headline)
            }
            
            if let data = widget.trendData, !data.isEmpty {
                Chart(data, id: \.timestamp) { point in
                    if let timestamp = point.timestamp, let eventLikelihood = point.eventLikelihood {
                        LineMark(
                            x: .value("Time", timestamp),
                            y: .value("Likelihood", eventLikelihood)
                        )
                    }
                }
                .frame(height: 200)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(12)
    }
}
