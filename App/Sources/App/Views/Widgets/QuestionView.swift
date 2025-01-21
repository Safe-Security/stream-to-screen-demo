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

struct SingleQuestionView: View {
    let question: Question
    
    var body: some View {
        Text(question.text)
            .font(.subheadline)
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            .multilineTextAlignment(.leading)
    }
}

struct GroupedQuestionView: View {
    let question: Question
    
    var body: some View {
        Text(question.text)
            .font(.subheadline)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
    }
}

struct QuestionGroupView: View {
    let group: QuestionGroup
    
    var body: some View {
        VStack(alignment: .leading) {
            if let title = group.title {
                Text(title)
                    .font(.headline)
                    .padding(.horizontal)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(group.questions) { item in
                        GroupedQuestionView(question: item.value)
                            .aspectRatio(1, contentMode: .fill)
                            .containerRelativeFrame(.horizontal, count: 5, span: 2, spacing: 12)
                    }
                }
                .padding(.horizontal)
            }
            .scrollClipDisabled()
        }
    }
}
