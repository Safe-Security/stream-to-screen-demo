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

struct InputView: View {
    @Environment(\.streamContentInputHandler) var handler
    
    var input: Input
    var body: some View {
        switch input.content {
        case .hidden:
            EmptyView()
        case .button(let name):
            InputButtonView(name: name) {
                handler(input)
            }
            .padding(.horizontal)
        case .appearance:
            AppearanceInputView(input: input)
                .padding(.horizontal)
        }
    }
}

struct InputButtonView: View {
    var name: String
    var onTap: () -> Void
    var body: some View {
        Button(action: onTap) {
            Text(name)
                .font(.headline)
                .foregroundStyle(Color(uiColor: .systemBackground))
                .frame(maxWidth: .infinity)
                .padding()
                .frame(height: 44)
                .background(Color(uiColor: .label))
                .cornerRadius(12)
        }
    }
}
