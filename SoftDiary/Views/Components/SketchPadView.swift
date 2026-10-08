import PencilKit
import SwiftUI
import UIKit

enum SketchPalette {
    static let swatches: [(color: Color, ui: UIColor)] = [
        (Color(hex: 0x3D3A4A), UIColor(red: 0.24, green: 0.23, blue: 0.29, alpha: 1)),
        (Color(hex: 0xFF8A80), UIColor(red: 1.0, green: 0.54, blue: 0.50, alpha: 1)),
        (Color(hex: 0xFFB347), UIColor(red: 1.0, green: 0.70, blue: 0.28, alpha: 1)),
        (Color(hex: 0xFFE29A), UIColor(red: 1.0, green: 0.89, blue: 0.60, alpha: 1)),
        (Color(hex: 0x7EC8E3), UIColor(red: 0.49, green: 0.78, blue: 0.89, alpha: 1)),
        (Color(hex: 0xA8E6CF), UIColor(red: 0.66, green: 0.90, blue: 0.81, alpha: 1)),
        (Color(hex: 0xC9A0FF), UIColor(red: 0.79, green: 0.63, blue: 1.0, alpha: 1)),
        (Color(hex: 0xFFB4A8), UIColor(red: 1.0, green: 0.71, blue: 0.66, alpha: 1))
    ]

    static let widths: [CGFloat] = [4, 8, 14]
}

struct SketchCanvasView: UIViewRepresentable {
    @Binding var drawing: PKDrawing
    var inkColor: UIColor
    var inkWidth: CGFloat
    var isEraser: Bool
    var canvasClearToken: Int

    func makeCoordinator() -> Coordinator {
        Coordinator(drawing: $drawing)
    }

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.delegate = context.coordinator
        canvas.drawing = drawing
        canvas.backgroundColor = .clear
        canvas.isOpaque = false
        canvas.drawingPolicy = .anyInput
        canvas.isScrollEnabled = false
        canvas.alwaysBounceVertical = false
        canvas.tool = makeTool()
        context.coordinator.canvas = canvas
        return canvas
    }

    func updateUIView(_ canvas: PKCanvasView, context: Context) {
        canvas.tool = makeTool()

        if canvasClearToken != context.coordinator.lastClearToken {
            context.coordinator.lastClearToken = canvasClearToken
            context.coordinator.isProgrammaticUpdate = true
            canvas.drawing = PKDrawing()
            drawing = PKDrawing()
            context.coordinator.isProgrammaticUpdate = false
        }
    }

    private func makeTool() -> PKTool {
        if isEraser {
            return PKEraserTool(.bitmap)
        }
        return PKInkingTool(.marker, color: inkColor, width: inkWidth)
    }

    final class Coordinator: NSObject, PKCanvasViewDelegate {
        @Binding var drawing: PKDrawing
        weak var canvas: PKCanvasView?
        var lastClearToken = 0
        var isProgrammaticUpdate = false

        init(drawing: Binding<PKDrawing>) {
            _drawing = drawing
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            guard !isProgrammaticUpdate else { return }
            drawing = canvasView.drawing
        }
    }
}

struct DiarySketchPad: View {
    @Binding var drawing: PKDrawing

    @State private var colorIndex = 0
    @State private var widthIndex = 1
    @State private var isEraser = false
    @State private var clearToken = 0
    @State private var expandCanvas = false

    private var selectedColor: Color { SketchPalette.swatches[colorIndex].color }
    private var selectedUIColor: UIColor { SketchPalette.swatches[colorIndex].ui }
    private var selectedWidth: CGFloat { SketchPalette.widths[widthIndex] }
    private var hasStrokes: Bool { !drawing.strokes.isEmpty }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Doodle", systemImage: "paintbrush.pointed.fill")
                    .font(AppTheme.headlineFont)
                    .foregroundStyle(AppTheme.ink)
                Spacer()
                if hasStrokes {
                    Text("Drawn")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(Color(hex: 0xFF8A80))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color(hex: 0xFFCDD2).opacity(0.7)))
                }
                Button {
                    expandCanvas = true
                } label: {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(AppTheme.inkSoft)
                        .padding(8)
                        .background(Circle().fill(Color.white.opacity(0.7)))
                }
            }

            canvasChrome(height: 220)

            toolRow

            Text("Draw with your finger — saved with the portrait")
                .font(AppTheme.captionFont)
                .foregroundStyle(AppTheme.inkSoft)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(AppTheme.card)
                .shadow(color: selectedColor.opacity(0.18), radius: 12, y: 6)
        )
        .fullScreenCover(isPresented: $expandCanvas) {
            SketchFullscreenEditor(drawing: $drawing)
        }
    }

    private func canvasChrome(height: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: 0xFFFBF5), Color(hex: 0xF0F7FF)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Canvas { ctx, size in
                let spacing: CGFloat = 18
                for x in stride(from: 10, through: size.width, by: spacing) {
                    for y in stride(from: 10, through: size.height, by: spacing) {
                        let rect = CGRect(x: x, y: y, width: 2, height: 2)
                        ctx.fill(Path(ellipseIn: rect), with: .color(Color(hex: 0xD8D2E4).opacity(0.55)))
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .allowsHitTesting(false)

            if !hasStrokes {
                VStack(spacing: 6) {
                    Image(systemName: "scribble.variable")
                        .font(.system(size: 28, weight: .medium))
                    Text("Draw here")
                        .font(AppTheme.captionFont)
                }
                .foregroundStyle(AppTheme.inkSoft.opacity(0.55))
                .allowsHitTesting(false)
            }

            SketchCanvasView(
                drawing: $drawing,
                inkColor: selectedUIColor,
                inkWidth: selectedWidth,
                isEraser: isEraser,
                canvasClearToken: clearToken
            )
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
        .frame(height: height)
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(selectedColor.opacity(0.35), lineWidth: 2)
        )
    }

    private var toolRow: some View {
        VStack(spacing: 10) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Array(SketchPalette.swatches.enumerated()), id: \.offset) { index, swatch in
                        Button {
                            withAnimation(AppTheme.softSpring) {
                                colorIndex = index
                                isEraser = false
                            }
                        } label: {
                            Circle()
                                .fill(swatch.color)
                                .frame(width: 28, height: 28)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: colorIndex == index && !isEraser ? 3 : 0)
                                )
                                .overlay(
                                    Circle()
                                        .stroke(AppTheme.ink.opacity(0.15), lineWidth: 1)
                                )
                                .scaleEffect(colorIndex == index && !isEraser ? 1.15 : 1)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            HStack(spacing: 10) {
                ForEach(Array(SketchPalette.widths.enumerated()), id: \.offset) { index, width in
                    Button {
                        withAnimation(AppTheme.softSpring) {
                            widthIndex = index
                            isEraser = false
                        }
                    } label: {
                        Circle()
                            .fill(isEraser || widthIndex != index ? AppTheme.inkSoft.opacity(0.25) : selectedColor)
                            .frame(width: 10 + width, height: 10 + width)
                            .padding(8)
                            .background(
                                Circle().fill(widthIndex == index && !isEraser ? selectedColor.opacity(0.18) : Color.white.opacity(0.5))
                            )
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                toolButton(icon: "eraser.fill", active: isEraser) {
                    isEraser.toggle()
                }
                toolButton(icon: "trash", active: false) {
                    clearToken += 1
                }
            }
        }
    }

    private func toolButton(icon: String, active: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(active ? Color(hex: 0xFF8A80) : AppTheme.inkSoft)
                .padding(10)
                .background(
                    Circle().fill(active ? Color(hex: 0xFFCDD2).opacity(0.8) : Color.white.opacity(0.65))
                )
        }
        .buttonStyle(CartoonPressStyle())
    }
}

struct SketchFullscreenEditor: View {
    @Binding var drawing: PKDrawing
    @Environment(\.dismiss) private var dismiss

    @State private var colorIndex = 0
    @State private var widthIndex = 1
    @State private var isEraser = false
    @State private var clearToken = 0

    private var selectedColor: Color { SketchPalette.swatches[colorIndex].color }
    private var selectedUIColor: UIColor { SketchPalette.swatches[colorIndex].ui }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppTheme.skyTop, AppTheme.skyBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 12) {
                HStack {
                    Button("Done") { dismiss() }
                        .font(AppTheme.headlineFont)
                        .foregroundStyle(AppTheme.ink)
                    Spacer()
                    Text("Doodle freely")
                        .font(AppTheme.titleFont)
                        .foregroundStyle(AppTheme.ink)
                    Spacer()
                    Button {
                        clearToken += 1
                    } label: {
                        Image(systemName: "trash")
                            .foregroundStyle(AppTheme.inkSoft)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                ZStack {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(Color.white.opacity(0.92))

                    SketchCanvasView(
                        drawing: $drawing,
                        inkColor: selectedUIColor,
                        inkWidth: SketchPalette.widths[widthIndex],
                        isEraser: isEraser,
                        canvasClearToken: clearToken
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                }
                .padding(.horizontal, 16)
                .frame(maxHeight: .infinity)

                HStack(spacing: 12) {
                    ForEach(Array(SketchPalette.swatches.enumerated()), id: \.offset) { index, swatch in
                        Button {
                            colorIndex = index
                            isEraser = false
                        } label: {
                            Circle()
                                .fill(swatch.color)
                                .frame(width: 30, height: 30)
                                .overlay(Circle().stroke(Color.white, lineWidth: colorIndex == index && !isEraser ? 3 : 0))
                        }
                    }
                    Button {
                        isEraser.toggle()
                    } label: {
                        Image(systemName: "eraser.fill")
                            .foregroundStyle(isEraser ? Color(hex: 0xFF8A80) : AppTheme.inkSoft)
                            .padding(8)
                            .background(Circle().fill(Color.white.opacity(0.8)))
                    }
                }
                .padding(.bottom, 20)
            }
        }
    }
}

struct SketchPreviewImage: View {
    let data: Data?
    var cornerRadius: CGFloat = 22

    var body: some View {
        Group {
            if let data,
               let drawing = try? PKDrawing(data: data),
               !drawing.strokes.isEmpty {
                let raw = drawing.bounds
                let bounds = raw.isNull || raw.isEmpty
                    ? CGRect(x: 0, y: 0, width: 300, height: 200)
                    : raw.insetBy(dx: -16, dy: -16)
                let image = drawing.image(from: bounds, scale: 2)
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: 0xFFFBF5), Color(hex: 0xF0F7FF)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(Color.white.opacity(0.8), lineWidth: 1)
                    )
            }
        }
    }
}

extension PKDrawing {
    var softDiaryData: Data? {
        strokes.isEmpty ? nil : dataRepresentation()
    }

    static func fromSoftDiary(_ data: Data?) -> PKDrawing {
        guard let data, let drawing = try? PKDrawing(data: data) else {
            return PKDrawing()
        }
        return drawing
    }
}
