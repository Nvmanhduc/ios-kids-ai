import SwiftUI
import PhotosUI

struct DrawingHomeView: View {
    @StateObject private var viewModel = DrawingViewModel()
    @State private var showingSnapshot = false
    @State private var snapshot: UIImage?
    @State private var selectedItem: PhotosPickerItem?

    @State private var showingColorPanel = false
    @State private var isColorizing = false
    @State private var colorizeError: String?
    @State private var colorizedURL: String?
    @State private var selectedStyle: String = "cute"

    private let palette: [Color] = [
        .black, .white, .red, .orange, .yellow, .green, .mint, .blue, .indigo, .purple, .pink, .brown
    ]

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                DrawingCanvasView(viewModel: viewModel)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.horizontal, 12)
                    .padding(.top, 8)

                ScrollView {
                    VStack(spacing: 14) {
                        HStack(spacing: 10) {
                            toolButton(
                                title: "Bút",
                                systemImage: "pencil.tip",
                                selected: !viewModel.isEraserMode,
                                color: .green
                            ) { viewModel.setPenMode() }

                            toolButton(
                                title: "Tẩy",
                                systemImage: "eraser",
                                selected: viewModel.isEraserMode,
                                color: .orange
                            ) { viewModel.toggleEraser() }

                            PhotosPicker(selection: $selectedItem, matching: .images) {
                                HStack(spacing: 6) {
                                    Image(systemName: "photo.on.rectangle")
                                    Text("Ảnh")
                                }
                                .font(.subheadline.weight(.semibold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .foregroundColor(.blue)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.blue.opacity(0.35), lineWidth: 1.2)
                                )
                                .shadow(color: Color.blue.opacity(0.12), radius: 6, y: 2)
                            }

                            Button {
                                showingColorPanel.toggle()
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "paintpalette.fill")
                                    Text("Màu")
                                }
                                .font(.subheadline.weight(.semibold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .foregroundColor(idealTextColor(for: viewModel.selectedColor))
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(viewModel.selectedColor)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.black.opacity(0.18), lineWidth: 1)
                                )
                            }
                            .popover(isPresented: $showingColorPanel, attachmentAnchor: .point(.bottom), arrowEdge: .top) {
                                colorPanel
                                    .padding(12)
                                    .presentationCompactAdaptation(.popover)
                            }

                            if viewModel.importedImage != nil {
                                Button {
                                    viewModel.removeImportedImage()
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title3)
                                        .foregroundColor(.red)
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Độ dày nét: \(Int(viewModel.strokeWidth))")
                                .font(.footnote)
                                .foregroundColor(.secondary)

                            Slider(value: Binding(
                                get: { Double(viewModel.strokeWidth) },
                                set: { viewModel.setStrokeWidth(CGFloat($0)) }
                            ), in: 2...24)
                            .tint(.green)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Zoom đa chiều: dùng 2 ngón để phóng/thu và di chuyển canvas")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }

                        if viewModel.importedImage != nil {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Độ mờ ảnh nền: \(Int(viewModel.importedImageOpacity * 100))%")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)

                                Slider(value: $viewModel.importedImageOpacity, in: 0.1...1.0)
                                    .tint(.blue)
                            }
                        }

                        HStack(spacing: 10) {
                            utilityButton("Undo", icon: "arrow.uturn.backward", color: .gray, action: viewModel.undo)
                            utilityButton("Redo", icon: "arrow.uturn.forward", color: .gray, action: viewModel.redo)
                            utilityButton("Xóa", icon: "trash", color: .red, action: viewModel.clear)
                        }

                        Picker("Style", selection: $selectedStyle) {
                            Text("Cute").tag("cute")
                            Text("Natural").tag("natural")
                            Text("Vivid").tag("vivid")
                        }
                        .pickerStyle(.segmented)

                        Button {
                            snapshot = viewModel.snapshotImage()
                            showingSnapshot = true
                        } label: {
                            HStack {
                                Image(systemName: "photo")
                                Text("XEM ẢNH")
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .foregroundColor(.white)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray))
                        }

                        Button {
                            let img = viewModel.snapshotImage()
                            snapshot = img
                            colorizeError = nil
                            Task {
                                isColorizing = true
                                defer { isColorizing = false }
                                do {
                                    let url = try await AIColorizeService.colorize(image: img, style: selectedStyle)
                                    colorizedURL = url
                                    showingSnapshot = true
                                } catch {
                                    colorizeError = error.localizedDescription
                                }
                            }
                        } label: {
                            HStack {
                                if isColorizing {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                        .tint(.white)
                                } else {
                                    Image(systemName: "sparkles")
                                }
                                Text(isColorizing ? "ĐANG TÔ MÀU..." : "AI TÔ MÀU")
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .foregroundColor(.white)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.green, Color.green.opacity(0.8)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                            .shadow(color: .green.opacity(0.35), radius: 10, y: 6)
                        }
                        .disabled(isColorizing)

                        if let colorizeError {
                            Text(colorizeError)
                                .font(.footnote)
                                .foregroundColor(.red)
                        }
                    }
                    .padding(12)
                }
                .background(Color(UIColor.systemGroupedBackground))
            }
            .navigationTitle("Vẽ tranh")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onChange(of: selectedItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run {
                        viewModel.setImportedImage(image)
                    }
                }
            }
        }
        .sheet(isPresented: $showingSnapshot) {
            if let snapshot {
                ScrollView {
                    VStack(spacing: 12) {
                        Text("Ảnh từ canvas")
                            .font(.headline)
                        Image(uiImage: snapshot)
                            .resizable()
                            .scaledToFit()
                            .padding(.horizontal)

                        if let colorizedURL, let remote = URL(string: colorizedURL) {
                            Text("Kết quả AI")
                                .font(.headline)
                            AsyncImage(url: remote) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFit()
                                case .failure:
                                    Text("Không tải được ảnh kết quả")
                                        .foregroundColor(.red)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .padding(.horizontal)

                            Text(colorizedURL)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
    }

    private var colorPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Chọn màu")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(palette, id: \.self) { color in
                        Button {
                            viewModel.setPenMode()
                            viewModel.setColor(color)
                        } label: {
                            Circle()
                                .fill(color)
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Circle().stroke(
                                        viewModel.selectedColor == color ? Color.white : Color.clear,
                                        lineWidth: 2
                                    )
                                )
                                .overlay(
                                    Circle().stroke(
                                        viewModel.selectedColor == color ? Color.accentColor : Color.clear,
                                        lineWidth: 3
                                    )
                                )
                                .shadow(color: viewModel.selectedColor == color ? .accentColor.opacity(0.35) : .clear, radius: 6)
                        }
                    }
                }
                .padding(.vertical, 2)
            }

            ColorPicker("Màu tuỳ chỉnh", selection: Binding(
                get: { viewModel.selectedColor },
                set: {
                    viewModel.setPenMode()
                    viewModel.setColor($0)
                }
            ))
            .labelsHidden()
        }
        .frame(width: 260)
    }

    private func toolButton(title: String, systemImage: String, selected: Bool, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                Text(title)
            }
            .font(.subheadline.weight(.semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .foregroundColor(selected ? .white : color)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(selected ? color : Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color, lineWidth: selected ? 0 : 1.2)
            )
            .shadow(color: selected ? color.opacity(0.35) : .clear, radius: 10, y: 4)
        }
    }

    private func utilityButton(_ title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(title)
            }
            .font(.subheadline.weight(.semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .foregroundColor(color)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
    }

    private func idealTextColor(for color: Color) -> Color {
        let ui = UIColor(color)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        if !ui.getRed(&r, green: &g, blue: &b, alpha: &a) {
            var white: CGFloat = 0
            ui.getWhite(&white, alpha: &a)
            r = white
            g = white
            b = white
        }

        let luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b
        return luminance > 0.62 ? .black : .white
    }
}
