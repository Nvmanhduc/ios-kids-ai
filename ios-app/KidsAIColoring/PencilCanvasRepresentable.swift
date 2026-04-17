import SwiftUI
import PencilKit

struct PencilCanvasRepresentable: UIViewRepresentable {
    @ObservedObject var viewModel: DrawingViewModel

    func makeUIView(context: Context) -> PKCanvasView {
        viewModel.canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // Tool is controlled by view model
    }
}
