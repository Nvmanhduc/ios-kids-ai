import SwiftUI
import PencilKit

struct PencilCanvasRepresentable: UIViewRepresentable {
    let viewModel: DrawingViewModel

    func makeUIView(context: Context) -> PKCanvasView {
        let uiView = viewModel.canvasView
        uiView.isOpaque = false
        uiView.backgroundColor = .clear
        return uiView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.isOpaque = false
        uiView.backgroundColor = .clear
        for sub in uiView.subviews {
            sub.backgroundColor = .clear
            sub.isOpaque = false
        }
        viewModel.syncCanvasMetrics()
        viewModel.syncBackgroundLayerFrame()
    }
}
