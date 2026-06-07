import Foundation
import Vision
import AppKit
import PDFKit

/// OCR on-device (Vision). Lê texto de imagem ou PDF escaneado — sem conta Apple.
enum OCR {
    private static func dataFromDataURL(_ dataURL: String) -> Data? {
        let marker = "base64,"
        guard let range = dataURL.range(of: marker) else {
            return Data(base64Encoded: dataURL)
        }
        return Data(base64Encoded: String(dataURL[range.upperBound...]))
    }

    private static func recognize(_ cgImage: CGImage) -> String {
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.recognitionLanguages = ["pt-BR", "en-US"]
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
            let results = request.results ?? []
            return results.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
        } catch {
            return ""
        }
    }

    private static func cgImage(for page: PDFPage) -> CGImage? {
        let bounds = page.bounds(for: .mediaBox)
        let scale: CGFloat = 2
        let size = NSSize(width: bounds.width * scale, height: bounds.height * scale)
        let image = page.thumbnail(of: size, for: .mediaBox)
        var rect = NSRect(origin: .zero, size: image.size)
        return image.cgImage(forProposedRect: &rect, context: nil, hints: nil)
    }

    /// Retorna o texto reconhecido (ou nil se nada).
    static func recognize(dataURL: String) -> String? {
        guard let data = dataFromDataURL(dataURL) else { return nil }

        // PDF (escaneado): renderiza páginas e faz OCR.
        if let pdf = PDFDocument(data: data), pdf.pageCount > 0 {
            var out = ""
            let maxPages = min(pdf.pageCount, 15)
            for i in 0..<maxPages {
                guard let page = pdf.page(at: i), let cg = cgImage(for: page) else { continue }
                let text = recognize(cg)
                if !text.isEmpty { out += (out.isEmpty ? "" : "\n\n") + text }
            }
            return out.isEmpty ? nil : out
        }

        // Imagem.
        if let image = NSImage(data: data) {
            var rect = NSRect(origin: .zero, size: image.size)
            if let cg = image.cgImage(forProposedRect: &rect, context: nil, hints: nil) {
                let text = recognize(cg)
                return text.isEmpty ? nil : text
            }
        }
        return nil
    }
}
