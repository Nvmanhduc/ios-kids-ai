import Foundation
import UIKit

struct AIColorizeResponse: Decodable {
    struct ColorResult: Decodable {
        let id: String
        let url: String
    }

    let requestId: String
    let result: ColorResult
}

enum AIColorizeService {
    static func colorize(
        image: UIImage,
        style: String,
        deviceId: String = UIDevice.current.identifierForVendor?.uuidString ?? "ios-device",
        baseURL: String = "http://172.30.0.1:8080"
    ) async throws -> String {
        guard let data = image.jpegData(compressionQuality: 0.9) else {
            throw NSError(domain: "AIColorize", code: -1, userInfo: [NSLocalizedDescriptionKey: "Không tạo được dữ liệu ảnh"])
        }

        let boundary = "Boundary-\(UUID().uuidString)"
        let url = URL(string: "\(baseURL)/v1/ai/lineart-colorize")!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        req.setValue(deviceId, forHTTPHeaderField: "X-Device-Id")

        var body = Data()

        func append(_ s: String) {
            body.append(Data(s.utf8))
        }

        append("--\(boundary)\r\n")
        append("Content-Disposition: form-data; name=\"style\"\r\n\r\n")
        append("\(style)\r\n")

        append("--\(boundary)\r\n")
        append("Content-Disposition: form-data; name=\"lineart\"; filename=\"lineart.jpg\"\r\n")
        append("Content-Type: image/jpeg\r\n\r\n")
        body.append(data)
        append("\r\n")

        append("--\(boundary)--\r\n")

        req.httpBody = body

        let (respData, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else {
            throw NSError(domain: "AIColorize", code: -2, userInfo: [NSLocalizedDescriptionKey: "Không có phản hồi HTTP"])
        }

        guard (200...299).contains(http.statusCode) else {
            let msg = String(data: respData, encoding: .utf8) ?? "Lỗi API \(http.statusCode)"
            throw NSError(domain: "AIColorize", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: msg])
        }

        let parsed = try JSONDecoder().decode(AIColorizeResponse.self, from: respData)
        return parsed.result.url
    }
}
