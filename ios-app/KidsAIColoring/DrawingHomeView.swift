import SwiftUI

struct DrawingHomeView: View {
    @StateObject private var viewModel = DrawingViewModel()
    @State private var showingSnapshot = false
    @State private var snapshot: UIImage?

    private let palette: [Color] = [.black, .red, .orange, .yellow, .green, .blue, .purple, .pink, .brown]

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                DrawingCanvasView(viewModel: viewModel)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                    )
                    .padding(.horizontal, 12)
                    .padding(.top, 8)

                VStack(spacing: 12) {
                    HStack(spacing: 8) {
                        ForEach(palette, id: \.self) { color in
                            Button {
                                viewModel.setPenMode()
                                viewModel.setColor(color)
                            } label: {
                                Circle()
                                    .fill(color)
                                    .frame(width: 28, height: 28)
                                    .overlay(
                                        Circle().stroke(Color.white, lineWidth: 2)
                                    )
                                    .shadow(radius: viewModel.selectedColor == color ? 3 : 0)
                            }
                        }
                    }

                    HStack {
                        Text("Nét: \(Int(viewModel.strokeWidth))")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        Slider(value: Binding(
                            get: { Double(viewModel.strokeWidth) },
                            set: { viewModel.setStrokeWidth(CGFloat($0)) }
                        ), in: 2...24)
                    }

                    HStack(spacing: 10) {
                        Button(action: viewModel.undo) {
                            Label("Undo", systemImage: "arrow.uturn.backward")
                        }
                        .buttonStyle(.bordered)

                        Button(action: viewModel.redo) {
                            Label("Redo", systemImage: "arrow.uturn.forward")
                        }
                        .buttonStyle(.bordered)

                        Button {
                            viewModel.toggleEraser()
                        } label: {
                            Label(viewModel.isEraserMode ? "Đang tẩy" : "Tẩy", systemImage: "eraser")
                        }
                        .buttonStyle(.bordered)

                        Button(role: .destructive, action: viewModel.clear) {
                            Label("Xóa", systemImage: "trash")
                        }
                        .buttonStyle(.bordered)
                    }

                    Button {
                        snapshot = viewModel.snapshotImage()
                        showingSnapshot = true
                    } label: {
                        Text("XONG - XEM ẢNH")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(12)
                .background(Color(UIColor.systemGroupedBackground))
            }
            .navigationTitle("Vẽ tranh")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingSnapshot) {
            if let snapshot {
                VStack(spacing: 12) {
                    Text("Ảnh xuất từ canvas")
                        .font(.headline)
                    Image(uiImage: snapshot)
                        .resizable()
                        .scaledToFit()
                        .padding()
                    Text("Bước sau: gửi ảnh này lên API /v1/ai/lineart-colorize")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
            }
        }
    }
}
