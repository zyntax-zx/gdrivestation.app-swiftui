import SwiftUI
import CoreImage.CIFilterBuiltins

enum ColorExtractor {
    static func dominantColor(from imageURL: URL) async -> Color? {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                guard let data = try? Data(contentsOf: imageURL),
                      let image = UIImage(data: data),
                      let cgImage = image.cgImage else {
                    continuation.resume(returning: nil)
                    return
                }

                let ciImage = CIImage(cgImage: cgImage)
                let context = CIContext()

                let filter = CIFilter.areaAverage()
                filter.inputImage = ciImage
                filter.extent = ciImage.extent

                guard let outputImage = filter.outputImage,
                      let output = context.createCGImage(outputImage, from: outputImage.extent) else {
                    continuation.resume(returning: nil)
                    return
                }

                let color = UIColor(cgImage: output).cgColor
                var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
                UIColor(cgImage: output).getRed(&r, green: &g, blue: &b, alpha: nil)

                let uiColor = UIColor(
                    red: min(r + 0.1, 1.0),
                    green: min(g + 0.1, 1.0),
                    blue: min(b + 0.1, 1.0),
                    alpha: 1.0
                )
                let swiftUIColor = Color(uiColor: uiColor)
                continuation.resume(returning: swiftUIColor)
            }
        }
    }
}
