import SwiftUI
import Foundation

struct StreamContentItemView: View {
    let item: StreamContentItem<StreamItemValue>
    
    var body: some View {
        switch item.value {
        case .markdown(let entry):
            MarkdownEntryView(entry: entry)
                .padding(.horizontal)
        case .markdownTable(let table):
            MarkdownTableView(table: table)
        case .question(let question):
            SingleQuestionView(question: question)
                .padding(.horizontal)
        case .questionGroup(let group):
            QuestionGroupView(group: group)
        case .widget(let widget):
            WidgetView(widget: widget)
                .padding(.horizontal)
        case .container(let container):
            ContainerWidgetView(container: container)
        case .input(let input):
            InputView(input: input)
        case .xml:
            EmptyView()
        }
    }
}

extension EnvironmentValues {
    @Entry var streamContentInputHandler: (Input) -> Void = { _ in }
    @Entry var streamContentActionHandler: StreamContentActionHandler = {
        .init(
            markAsExecuted: { _ in },
            canExecute: {_ in true },
            setColorScheme: { _ in }
        )
    }()
}

struct StreamContentActionHandler {
    var markAsExecuted: (Input) -> Void
    var canExecute: (Input) -> Bool
    var setColorScheme: (ColorScheme) -> Void
}

struct StreamContentView: View {
    let content: StreamContent
    
    var body: some View {
        LazyVStack(alignment: .leading, spacing: 12) {
            ForEach(content.items) { item in
                StreamContentItemView(item: item)
            }
        }
        .animation(.default, value: content.items)
        .padding(.bottom, 88)
    }
}
