import SwiftUI

struct DrawingCanvasView: View {
    let viewModel: DrawingViewModel

    var body: some View {
        GeometryReader { geo in
            let canvasHeight = max(geo.size.height, CGFloat(420))
            let canvasBounds = CGRect(x: 0, y: 0, width: geo.size.width, height: canvasHeight)

            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)

                PencilCanvasRepresentable(viewModel: viewModel)
                    .background(Color.clear)
            }
            .frame(width: geo.size.width, height: canvasHeight)
            .overlay(alignment: .topTrailing) {
                Button {
                    viewModel.resetCanvasTransform()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.left.and.down.right.magnifyingglass")
                        Text("Reset")
                    }
                    .font(.caption.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                }
                .padding(10)
            }
        }
        .frame(minHeight: CGFloat(420))
        .clipped()
    }

    private func aspectFitRect(imageSize: CGSize, in bounds: CGRect) -> CGRect {
        guard imageSize.width > 0, imageSize.height > 0, bounds.width > 0, bounds.height > 0 else {
            return bounds
        }

        let imageAspect = imageSize.width / imageSize.height
        let boundsAspect = bounds.width / bounds.height

        var drawSize = bounds.size
        if imageAspect > boundsAspect {
            drawSize.height = bounds.width / imageAspect
        } else {
            drawSize.width = bounds.height * imageAspect
        }

        let origin = CGPoint(
            x: bounds.midX - drawSize.width / 2,
            y: bounds.midY - drawSize.height / 2
        )
        return CGRect(origin: origin, size: drawSize)
    }
}
