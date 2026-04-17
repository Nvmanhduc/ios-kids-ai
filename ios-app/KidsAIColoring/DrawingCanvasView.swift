import SwiftUI

struct DrawingCanvasView: View {
    @ObservedObject var viewModel: DrawingViewModel

    var body: some View {
        GeometryReader { geo in
            PencilCanvasRepresentable(viewModel: viewModel)
                .frame(width: geo.size.width, height: max(geo.size.height, 420))
        }
        .frame(minHeight: 420)
    }
}
