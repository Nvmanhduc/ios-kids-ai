import SwiftUI
import PencilKit

final class DrawingViewModel: ObservableObject {
    @Published var canvasView: PKCanvasView = PKCanvasView()
    @Published var isEraserMode: Bool = false
    @Published var strokeWidth: CGFloat = 8
    @Published var selectedColor: Color = .black

    init() {
        configureCanvas()
        applyTool()
    }

    func configureCanvas() {
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = .white
        canvasView.alwaysBounceVertical = false
        canvasView.alwaysBounceHorizontal = false
    }

    func setColor(_ color: Color) {
        selectedColor = color
        if !isEraserMode {
            applyTool()
        }
    }

    func setStrokeWidth(_ width: CGFloat) {
        strokeWidth = width
        if !isEraserMode {
            applyTool()
        }
    }

    func toggleEraser() {
        isEraserMode.toggle()
        applyTool()
    }

    func setPenMode() {
        isEraserMode = false
        applyTool()
    }

    private func applyTool() {
        if isEraserMode {
            canvasView.tool = PKEraserTool(.vector)
        } else {
            let uiColor = UIColor(selectedColor)
            canvasView.tool = PKInkingTool(.pen, color: uiColor, width: strokeWidth)
        }
    }

    func undo() {
        canvasView.undoManager?.undo()
    }

    func redo() {
        canvasView.undoManager?.redo()
    }

    func clear() {
        canvasView.drawing = PKDrawing()
    }

    func snapshotImage() -> UIImage {
        let bounds = canvasView.bounds
        let image = canvasView.drawing.image(from: bounds, scale: UIScreen.main.scale)
        return image
    }
}
