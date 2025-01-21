import SwiftUI

struct ControlsView: View {
    @Binding var progress: Double
    var length: Double
    @Binding var isPlaying: Bool
    @Binding var chunkSize: Double
    
    var body: some View {
            HStack {
                // Play/Pause Button
                Button {
                    isPlaying.toggle()
                } label: {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .resizable()
                        .frame(width: 44, height: 44)
                        .font(.title)
                }
                .buttonStyle(.plain)
                
                Grid(alignment: .leading) {
                    GridRow {
                        Slider(value: $chunkSize, in: 1...100)
                        Text("Chunk: \(Int(chunkSize))")
                    }
                    
                    
                    GridRow {
                        Slider(value: $progress, in: 0...(length - 1.0))
                        Text("Content: \(Int(progress + 1)) / \(Int(length))")
                    }
                }
                .font(.caption.monospacedDigit())
            }
    }
}

#Preview {
    @Previewable @State var progress: Double = 0
    @Previewable var length: Double = 100
    @Previewable @State var isPlaying: Bool = false
    @Previewable @State var chunkSize: Double = 50
    ControlsView(
        progress: $progress,
        length: length,
        isPlaying: $isPlaying,
        chunkSize: $chunkSize
    )
    .padding()
}
