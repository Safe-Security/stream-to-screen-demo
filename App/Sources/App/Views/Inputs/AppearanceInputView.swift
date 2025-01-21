import SwiftUI

struct AppearanceInputView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.streamContentActionHandler) var handler
    @State private var toggleState: Bool = false

    let input: Input
    let text: String
    let runImmediately: Bool
    let ready: Bool
    
    init(input: Input) {
        self.input = input
        if case .appearance(let text, let runImmediately, let ready) = input.content {
            self.text = text
            self.runImmediately = runImmediately
            self.ready = ready
        } else {
            runImmediately = false
            ready = false
            text = "Dark Mode"
        }
    }
    
    var body: some View {
        Toggle(isOn: $toggleState) {
            Text(text)
                .font(.headline)
        }
        .animation(.easeInOut(duration: 0.5).delay(0.5), value: toggleState)
        .onChange(of: toggleState) {
            withAnimation(.easeInOut(duration: 0.5)) {
                handler.setColorScheme(toggleState ? .dark : .light)
            }
        }
        .onChange(of: [ready, runImmediately], initial: false) {
            tryExecute()
        }
        .onAppear {
            tryExecute()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private func tryExecute() {
        guard runImmediately && handler.canExecute(input) && ready else { return }
        
        handler.markAsExecuted(input)
        Task {
            try? await Task.sleep(for: .seconds(1))
            
            switch (input.value) {
            case "light":
                toggleState = false
            case "dark":
                toggleState = true
            default:
                switch colorScheme {
                case .light:
                    toggleState = true
                case .dark:
                    toggleState = false
                default:
                    toggleState.toggle()
                }
            }
        }
    }
    
    enum AppearanceTarget: String {
        case light
        case dark
        case toggle
    }
}

#Preview {
    VStack(spacing: 16) {
        AppearanceInputView(
            input: .init(
                name: "appearence",
                value: "light",
                content: .appearance(
                    text: "Dark Mode",
                    runImmediately: true,
                    ready: true
                )
            )
        )
    }
    .padding()
}
