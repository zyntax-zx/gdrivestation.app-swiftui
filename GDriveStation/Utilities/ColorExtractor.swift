import SwiftUI
import UIKit
import CoreImage.CIFilterBuiltins

enum ColorExtractor {
    static func dominantColor(from imageURL: URL) async -> Color? {
        await withCheckedContinuation { (continuation: CheckedContinuation<Color?, Never>) in
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

                var pixel = [UInt8](repeating: 0, count: 4)
                let colorSpace = CGColorSpaceCreateDeviceRGB()
                guard let bitmapContext = CGContext(data: &pixel,
                                                    width: 1,
                                                    height: 1,
                                                    bitsPerComponent: 8,
                                                    bytesPerRow: 4,
                                                    space: colorSpace,
                                                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
                else {
                    continuation.resume(returning: nil)
                    return
                }

                bitmapContext.draw(output, in: CGRect(x: 0, y: 0, width: 1, height: 1))

                let r = CGFloat(pixel[0]) / 255.0
                let g = CGFloat(pixel[1]) / 255.0
                let b = CGFloat(pixel[2]) / 255.0
                let a = CGFloat(pixel[3]) / 255.0

                let swiftUIColor = Color(red: min(r + 0.1, 1.0),
                                         green: min(g + 0.1, 1.0),
                                         blue: min(b + 0.1, 1.0),
                                         opacity: Double(a))
                continuation.resume(returning: swiftUIColor)
            }
        }
    }
}
