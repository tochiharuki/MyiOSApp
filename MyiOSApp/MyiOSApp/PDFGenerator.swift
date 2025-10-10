import Foundation
import PDFKit
import UIKit

// 共通フォント管理
private enum ReceiptFont {
    static func regular(size: CGFloat) -> UIFont {
        return UIFont(name: "HiraMinProN-W3", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    static func bold(size: CGFloat) -> UIFont {
        return UIFont(name: "HiraMinProN-W6", size: size) ?? UIFont.boldSystemFont(ofSize: size)
    }
}

enum PDFGeneratorError: Error {
    case generationFailed(String)
}

struct PDFGenerator {
    
    // 領収番号生成（日付 + ランダム）
    private static func generateReceiptNo(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        let dateStr = formatter.string(from: date)
        let random = Int.random(in: 1000...9999)
        return "\(dateStr)-\(random)"
    }
    
    // 数字を3桁カンマ区切り
    private static func formatNumber(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "\(Int(value))"
    }
    
    static func generate(from receipt: ReceiptData) -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "MyiOSApp",
            kCGPDFContextTitle: "領収書"
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth: CGFloat = 841.8   // A4横
        let pageHeight: CGFloat = 595.2
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        return renderer.pdfData { context in
            context.beginPage()
            let ctx = UIGraphicsGetCurrentContext()!
            
            // --- タイトル ---
            let title = "領 収 書"
            let titleFont = ReceiptFont.bold(size: 32)
            let titleAttr: [NSAttributedString.Key: Any] = [.font: titleFont]
            let titleSize = title.size(withAttributes: titleAttr)
            
            // 少し上余裕をもたせる
            let titleY: CGFloat = 60
            title.draw(at: CGPoint(x: (pageWidth - titleSize.width)/2, y: titleY), withAttributes: titleAttr)
            
            // 下線
            ctx.setStrokeColor(UIColor.black.cgColor)
            ctx.setLineWidth(1.2)
            ctx.move(to: CGPoint(x: 60, y: titleY + titleSize.height + 15))
            ctx.addLine(to: CGPoint(x: pageWidth - 60, y: titleY + titleSize.height + 15))
            ctx.strokePath()
            
            // --- 宛名 ---
            let nameFont = ReceiptFont.regular(size: 22)
            let recipient = "\(receipt.recipient) \(receipt.recipientSuffix)"
            let recipientY: CGFloat = titleY + titleSize.height + 60
            recipient.draw(at: CGPoint(x: 80, y: recipientY), withAttributes: [.font: nameFont])
            
            let recipientSize = recipient.size(withAttributes: [.font: nameFont])
            ctx.move(to: CGPoint(x: 80, y: recipientY + recipientSize.height + 3))
            ctx.addLine(to: CGPoint(x: 80 + recipientSize.width + 40, y: recipientY + recipientSize.height + 3))
            ctx.strokePath()
            
            // --- 発行日・番号（右上） ---
            let infoFont = ReceiptFont.regular(size: 14)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy年MM月dd日"
            let rightX = pageWidth - 250
            "領収番号：\(generateReceiptNo(from: receipt.issueDate))".draw(at: CGPoint(x: rightX, y: recipientY), withAttributes: [.font: infoFont])
            "発行日：\(formatter.string(from: receipt.issueDate))".draw(at: CGPoint(x: rightX, y: recipientY + 25), withAttributes: [.font: infoFont])
            
            // --- 金額 ---
            let total = receipt.totalAmount
            let amountText = "¥ \(formatNumber(total))"
            let amountFont = ReceiptFont.bold(size: 36)
            let amountSize = amountText.size(withAttributes: [.font: amountFont])
            let amountY = recipientY + 100
            let amountX = (pageWidth - amountSize.width)/2
            amountText.draw(at: CGPoint(x: amountX, y: amountY), withAttributes: [.font: amountFont])
            
            // 金額下線
            ctx.setLineWidth(1.0)
            ctx.move(to: CGPoint(x: amountX - 10, y: amountY + amountSize.height + 6))
            ctx.addLine(to: CGPoint(x: amountX + amountSize.width + 10, y: amountY + amountSize.height + 6))
            ctx.strokePath()
            
            "(税込)".draw(at: CGPoint(x: amountX + amountSize.width + 20, y: amountY + 10),
                          withAttributes: [.font: ReceiptFont.regular(size: 14)])
            
            // --- 但し書き ---
            let remarks: String
            if receipt.remarks.isEmpty {
                remarks = "上記正に領収いたしました。"
            } else {
                remarks = "但し　\(receipt.remarks)\n上記正に領収いたしました。"
            }
            
            let paragraph = NSMutableParagraphStyle()
            paragraph.lineSpacing = 8
            let remarksAttr: [NSAttributedString.Key: Any] = [
                .font: ReceiptFont.regular(size: 16),
                .paragraphStyle: paragraph
            ]
            (remarks as NSString).draw(
                in: CGRect(x: 80, y: amountY + 70, width: 400, height: 100),
                withAttributes: remarksAttr
            )
            
            // --- 内訳表 ---
            var tableY = amountY + 170
            func drawRow(label: String, value: String) {
                label.draw(at: CGPoint(x: 100, y: tableY), withAttributes: [.font: infoFont])
                value.draw(at: CGPoint(x: 340, y: tableY), withAttributes: [.font: infoFont])
                tableY += 28
            }
            if receipt.taxRate == "8%" {
                drawRow(label: "8%対象小計", value: "¥\(formatNumber(receipt.subtotal))")
                drawRow(label: "8% 消費税", value: "¥\(formatNumber(receipt.tax))")
            } else if receipt.taxRate == "10%" {
                drawRow(label: "10%対象小計", value: "¥\(formatNumber(receipt.subtotal))")
                drawRow(label: "10% 消費税", value: "¥\(formatNumber(receipt.tax))")
            }
            
            // --- 収入印紙枠 ---
            if receipt.showStampBox {
                let stampRect = CGRect(x: 80, y: tableY + 40, width: 100, height: 100)
                let path = UIBezierPath(rect: stampRect)
                UIColor.gray.setStroke()
                path.setLineDash([5, 4], count: 2, phase: 0)
                path.stroke()
                
                // 完全中央配置
                let stampText = "収 入\n印 紙"
                let stampParagraph = NSMutableParagraphStyle()
                stampParagraph.alignment = .center
                (stampText as NSString).draw(
                    in: CGRect(x: 80, y: tableY + 40, width: 100, height: 100),
                    withAttributes: [
                        .font: ReceiptFont.regular(size: 16),
                        .paragraphStyle: stampParagraph
                    ]
                )
            }
            
            // --- 発行者情報（右下） ---
            if !receipt.issuer.isEmpty {
                let issuerParagraph = NSMutableParagraphStyle()
                issuerParagraph.alignment = .right
                issuerParagraph.lineSpacing = 6
                
                // 広く余裕をもたせて配置
                let issuerRect = CGRect(
                    x: pageWidth - 340,
                    y: pageHeight - 150,
                    width: 280,
                    height: 120
                )
                
                (receipt.issuer as NSString).draw(
                    in: issuerRect,
                    withAttributes: [
                        .font: ReceiptFont.regular(size: 16),
                        .paragraphStyle: issuerParagraph
                    ]
                )
            }
        }
    }

}