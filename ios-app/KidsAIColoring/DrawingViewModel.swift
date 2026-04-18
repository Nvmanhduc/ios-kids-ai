import SwiftUI
import PencilKit

final class DrawingViewModel: NSObject, ObservableObject, PKCanvasViewDelegate {
    @Published var canvasView: PKCanvasView = PKCanvasView()
    @Published var isEraserMode: Bool = false
    @Published var strokeWidth: CGFloat = 8
    @Published var selectedColor: Color = .black
    @Published var importedImage: UIImage? {
        didSet { updateBackgroundImage() }
    }
    @Published var importedImageOpacity: Double = 0.7 {
        didSet { backgroundImageView.alpha = CGFloat(importedImageOpacity) }
    }

    private let backgroundImageView = UIImageView()

    // Mirror PKCanvasView transform to background image layer in SwiftUI
    @Published var canvasZoomScale: CGFloat = 1.0
    @Published var canvasContentOffset: CGPoint = .zero
    @Published var canvasViewportSize: CGSize = .zero
    @Published var canvasAdjustedInset: UIEdgeInsets = .zero

    override init() {
        super.init()
        configureCanvas()
        applyTool()
    }

    func configureCanvas() {
        canvasView.delegate = self
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.overrideUserInterfaceStyle = .light

        backgroundImageView.contentMode = .scaleAspectFit
        backgroundImageView.clipsToBounds = true
        backgroundImageView.alpha = CGFloat(importedImageOpacity)
        attachBackgroundImageViewIfNeeded()

        // Zoom/pan by 2 fingers only
        canvasView.minimumZoomScale = 1.0
        canvasView.maximumZoomScale = 4.0
        canvasView.bouncesZoom = true
        canvasView.bounces = true
        canvasView.alwaysBounceVertical = true
        canvasView.alwaysBounceHorizontal = true
        canvasView.panGestureRecognizer.minimumNumberOfTouches = 2
        canvasView.panGestureRecognizer.maximumNumberOfTouches = 2
    }

    func setColor(_ color: Color) {
        selectedColor = color
        if !isEraserMode { applyTool() }
    }

    func setStrokeWidth(_ width: CGFloat) {
        strokeWidth = width
        if !isEraserMode { applyTool() }
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
            let resolved = UIColor(selectedColor).resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
            let finalColor: UIColor
            if resolved.isEqual(UIColor.black) {
                finalColor = UIColor.black
            } else if resolved.isEqual(UIColor.white) {
                finalColor = UIColor.white
            } else {
                finalColor = resolved
            }
            canvasView.tool = PKInkingTool(.pen, color: finalColor, width: strokeWidth)
        }
    }

    func undo() { canvasView.undoManager?.undo() }
    func redo() { canvasView.undoManager?.redo() }
    func clear() { canvasView.drawing = PKDrawing() }

    func setImportedImage(_ image: UIImage?) {
        importedImage = image
        resetCanvasTransform()
    }

    func removeImportedImage() {
        importedImage = nil
        resetCanvasTransform()
    }

    func resetCanvasTransform() {
        canvasView.setZoomScale(1.0, animated: true)
        let targetOffset = CGPoint(x: -canvasView.adjustedContentInset.left, y: -canvasView.adjustedContentInset.top)
        canvasView.setContentOffset(targetOffset, animated: true)
        canvasZoomScale = 1.0
        canvasContentOffset = targetOffset
        canvasViewportSize = canvasView.bounds.size
        canvasAdjustedInset = canvasView.adjustedContentInset
        syncBackgroundLayerFrame()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView === canvasView else { return }
        canvasContentOffset = scrollView.contentOffset
        canvasViewportSize = canvasView.bounds.size
        canvasAdjustedInset = canvasView.adjustedContentInset
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        guard scrollView === canvasView else { return }
        canvasZoomScale = scrollView.zoomScale
        canvasContentOffset = scrollView.contentOffset
        canvasViewportSize = canvasView.bounds.size
        canvasAdjustedInset = canvasView.adjustedContentInset
    }

    func syncCanvasMetrics() {
        canvasViewportSize = canvasView.bounds.size
        canvasAdjustedInset = canvasView.adjustedContentInset
        canvasZoomScale = canvasView.zoomScale
        canvasContentOffset = canvasView.contentOffset
        syncBackgroundLayerFrame()
    }

    func syncBackgroundLayerFrame() {
        attachBackgroundImageViewIfNeeded()
        guard let container = zoomContainerView() else { return }
        backgroundImageView.frame = container.bounds.insetBy(dx: 6, dy: 6)
    }

    private func updateBackgroundImage() {
        backgroundImageView.image = importedImage
        backgroundImageView.alpha = CGFloat(importedImageOpacity)
        syncBackgroundLayerFrame()
    }

    private func zoomContainerView() -> UIView? {
        // PKCanvasView is UIScrollView; the first subview is the zoomed content container.
        return canvasView.subviews.first
    }

    private func attachBackgroundImageViewIfNeeded() {
        guard let container = zoomContainerView() else { return }
        if backgroundImageView.superview !== container {
            backgroundImageView.removeFromSuperview()
            container.insertSubview(backgroundImageView, at: 0)
        }
    }

    func snapshotImage() -> UIImage {
        let bounds = canvasView.bounds
        let format = UIGraphicsImageRendererFormat()
        format.opaque = true
        format.scale = UIScreen.main.scale

        let renderer = UIGraphicsImageRenderer(size: bounds.size, format: format)
        return renderer.image { context in
            UIColor.white.setFill()
            context.fill(bounds)

            if let importedImage {
                let fitted = aspectFitRect(imageSize: importedImage.size, in: bounds)
                importedImage.draw(in: fitted, blendMode: .normal, alpha: CGFloat(importedImageOpacity))

                // Draw normalized strokes only inside image area so outside remains white.
                context.cgContext.saveGState()
                context.cgContext.clip(to: fitted)
                let drawingImage = normalizedDrawingForSnapshot().image(from: bounds, scale: UIScreen.main.scale)
                drawingImage.draw(in: bounds)
                context.cgContext.restoreGState()
            } else {
                let drawingImage = normalizedDrawingForSnapshot().image(from: bounds, scale: UIScreen.main.scale)
                drawingImage.draw(in: bounds)
            }
        }
    }

    private func normalizedDrawingForSnapshot() -> PKDrawing {
        let lightTrait = UITraitCollection(userInterfaceStyle: .light)

        let normalizedStrokes: [PKStroke] = canvasView.drawing.strokes.map { stroke in
            let resolved = stroke.ink.color.resolvedColor(with: lightTrait)
            let fixedColor: UIColor

            if resolved.isEqual(UIColor.black) {
                fixedColor = UIColor.black
            } else if resolved.isEqual(UIColor.white) {
                fixedColor = UIColor.white
            } else {
                fixedColor = resolved
            }

            let ink = PKInk(stroke.ink.inkType, color: fixedColor)
            return PKStroke(ink: ink, path: stroke.path, transform: stroke.transform, mask: stroke.mask)
        }

        return PKDrawing(strokes: normalizedStrokes)
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
