import SwiftUI
import MarkdownUI

public struct AppView: View {
    @Environment(\.colorScheme) var colorScheme
    @Bindable var viewModel: AppViewModel
    
    public init(viewModel: Bindable<AppViewModel>) {
        self._viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    StreamContentView(content: viewModel.content)
                        .environment(\.streamContentInputHandler, viewModel.inputHandler)
                        .environment(\.streamContentActionHandler, viewModel.actionHandler)
                        .id("content")
                        .onChange(of: viewModel.content.items) {
                            withAnimation {
                                proxy.scrollTo("content", anchor: .bottom)
                            }
                        }
                }
                .animation(.default, value: viewModel.content)
                .scrollClipDisabled()
            }
            
            HStack {
                ControlsView(
                    progress: .init(get: { viewModel.progress }, set: { viewModel.reload(length: $0) }),
                    length: viewModel.contentLength,
                    isPlaying: $viewModel.isPlaying,
                    chunkSize: $viewModel.chunkSize
                )
                
                if viewModel.content.options.page.control == .submit {
                    Button {
                        viewModel.submit()
                    } label: {
                        Image(systemName: "square.and.pencil.circle.fill")
                            .resizable()
                            .frame(width: 44, height: 44)
                            .font(.title)
                    }
                    .buttonStyle(.plain)
                    .transition(.move(edge: .trailing))
                }
            }
            .animation(.default, value: viewModel.content.options)
            .padding()
            .background(.ultraThinMaterial)
        }
        .background(.windowBackground)
        .colorScheme(viewModel.colorScheme ?? colorScheme)
    }
}

#Preview {
    AppView(viewModel: .init(AppViewModel()))
}
