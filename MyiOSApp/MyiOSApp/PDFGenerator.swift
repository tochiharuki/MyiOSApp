import UIKit
import PDFKit

struct PDFGenerator {

    static func generate(from receipt: ReceiptData) -> Data? {
        let pdfMetaData = [
            kCGPDFContextCreator: "MyiOSApp",
            kCGPDFContextAuthor: receipt.companyName
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageWidth = 595.2  // A4 横幅
        let pageHeight = 841.8
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        let data = renderer.pdfData { ctx in
            ctx.beginPage()
            let context = ctx.cgContext

            // フォント
            let titleFont = UIFont.boldSystemFont(ofSize: 28)
            let headerFont = UIFont.systemFont(ofSize: 16)
            let bodyFont = UIFont.systemFont(ofSize: 14)
            let amountFont = UIFont.boldSystemFont(ofSize: 20)

            // MARK: - タイトル
            let title = "領収書"
            let titleSize = title.size(withAttributes: [.font: titleFont])
            let titleRect = CGRect(x: (pageWidth - titleSize.width)/2, y: 40, width: titleSize.width, height: titleSize.height)
            title.draw(in: titleRect, withAttributes: [.font: titleFont])

            var yPosition = titleRect.maxY + 40

            // MARK: - 日付・宛名
            let dateText = "発行日: \(dateFormatter.string(from: receipt.issueDate))"
            dateText.draw(at: CGPoint(x: 40, y: yPosition), withAttributes: [.font: headerFont])
            yPosition += 24

            let recipientText = "宛名: \(receipt.recipient)"
            recipientText.draw(at: CGPoint(x: 40, y: yPosition), withAttributes: [.font: headerFont])
            yPosition += 40

            // MARK: - 金額・税
            let total = receipt.amount ?? 0
            let taxRate = receipt.taxRate == "8%" ? 0.08 : (receipt.taxRate == "10%" ? 0.10 : 0)
            var taxExcluded: Double = 0
            var taxAmount: Double = 0
            var totalAmount: Double = total

            if receipt.taxRate != "非課税" {
                if receipt.taxType == "内税" {
                    taxExcluded = (total / (1 + taxRate)).rounded()
                    taxAmount = (total - taxExcluded).rounded()
                } else { // 外税
                    taxExcluded = total
                    taxAmount = (total * taxRate).rounded()
                    totalAmount = total + taxAmount
                }
            } else {
                taxExcluded = total
                taxAmount = 0
                totalAmount = total
            }

            func formatYen(_ amount: Double) -> String {
                String(format: "¥%.0f", amount)
            }

            let amountLines = [
                "金額（税抜）: \(formatYen(taxExcluded))",
                "消費税: \(formatYen(taxAmount))",
                "合計: \(formatYen(totalAmount)) (\(receipt.taxType)・税率 \(receipt.taxRate))"
            ]

            for line in amountLines {
                line.draw(at: CGPoint(x: 40, y: yPosition), withAttributes: [.font: amountFont])
                yPosition += 28
            }
            yPosition += 20

            // MARK: - 但し書き
            let remarks = receipt.remarks.isEmpty ? "但し書き: " : "但し書き: \(receipt.remarks)"
            let remarksRect = CGRect(x: 40, y: yPosition, width: pageWidth - 80, height: 100)
            remarks.draw(in: remarksRect, withAttributes: [.font: bodyFont])
            yPosition += 120

            // MARK: - 発行元
            let companyText = receipt.companyName
            let companySize = companyText.size(withAttributes: [.font: headerFont])
            let companyRect = CGRect(x: pageWidth - companySize.width - 40, y: pageHeight - 80, width: companySize.width, height: companySize.height)
            companyText.draw(in: companyRect, withAttributes: [.font: headerFont])
        }

        return data
    }

}

// 日付表示用フォーマッター
private let dateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateStyle = .long
    f.locale = Locale(identifier: "ja_JP")
    return f
}()