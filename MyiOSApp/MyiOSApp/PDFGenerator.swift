import Foundation
import PDFKit
import UIKit

enum PDFGeneratorError: Error {
    case generationFailed(String)
}

struct PDFGenerator {
    
    // 領収番号生成（日付 + ランダム）
    private static func generateReceiptNo(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
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
            kCGPDFContextAuthor: "MyiOSApp User",
            kCGPDFContextTitle: "領収書"
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        // 横向き A4
        let pageWidth: CGFloat = 841.8
        let pageHeight: CGFloat = 595.2
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let pdfData = renderer.pdfData { context in
            context.beginPage()
            
            let ctx = UIGraphicsGetCurrentContext()!
            
            // タイトル
            let title = "領収書"
            let titleFont = UIFont.boldSystemFont(ofSize: 24)
            let titleAttributes: [NSAttributedString.Key: Any] = [.font: titleFont]
            let titleSize = title.size(withAttributes: titleAttributes)
            let titleRect = CGRect(x: (pageWidth - titleSize.width)/2,
                                   y: 30,
                                   width: titleSize.width,
                                   height: titleSize.height)
            title.draw(in: titleRect, withAttributes: titleAttributes)
            
            // タイトル下線
            ctx.setStrokeColor(UIColor.black.cgColor)
            ctx.setLineWidth(1)
            ctx.move(to: CGPoint(x: 40, y: titleRect.maxY + 10))
            ctx.addLine(to: CGPoint(x: pageWidth - 40, y: titleRect.maxY + 10))
            ctx.strokePath()
            
            // 宛名
            let nameFont = UIFont.systemFont(ofSize: 16)
            let recipient = "\(receipt.recipient) 御中"
            let recipientPoint = CGPoint(x: 50, y: titleRect.maxY + 40)
            recipient.draw(at: recipientPoint, withAttributes: [.font: nameFont])
            
            // 宛名下線
            ctx.setStrokeColor(UIColor.black.cgColor)
            ctx.setLineWidth(1)
            ctx.move(to: CGPoint(x: 40, y: recipientPoint.y + 22))
            ctx.addLine(to: CGPoint(x: pageWidth - 40, y: recipientPoint.y + 22))
            ctx.strokePath()
            
            // 領収番号と発行日（右上）
            let receiptNo = generateReceiptNo(from: receipt.issueDate)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy年MM月dd日"
            
            let rightAttr: [NSAttributedString.Key: Any] = [.font: nameFont]
            "領収番号: \(receiptNo)".draw(at: CGPoint(x: pageWidth - 250, y: recipientPoint.y), withAttributes: rightAttr)
            "発行日: \(formatter.string(from: receipt.issueDate))".draw(at: CGPoint(x: pageWidth - 250, y: recipientPoint.y + 30), withAttributes: rightAttr)
            
            // 金額中央表示（背景グレー）
            let total = receipt.totalAmount
            let amountText = "¥ \(formatNumber(total)) -"
            let amountFont = UIFont.boldSystemFont(ofSize: 28)
            let amountSize = amountText.size(withAttributes: [.font: amountFont])
            let amountRect = CGRect(x: (pageWidth - amountSize.width)/2,
                                    y: recipientPoint.y + 80,
                                    width: amountSize.width + 40,
                                    height: amountSize.height + 10)
            
            UIColor(white: 0.9, alpha: 1).setFill()
            ctx.fill(amountRect)
            
            amountText.draw(in: CGRect(x: amountRect.origin.x + 20,
                                       y: amountRect.origin.y + 5,
                                       width: amountSize.width,
                                       height: amountSize.height),
                            withAttributes: [.font: amountFont])
            
            "(税込)".draw(at: CGPoint(x: amountRect.maxX + 10, y: amountRect.minY + 8),
                         withAttributes: [.font: UIFont.systemFont(ofSize: 14)])
            
            // 但し書き
            let remarks = receipt.remarks.isEmpty ? "上記正に領収いたしました。" : receipt.remarks
            remarks.draw(at: CGPoint(x: 50, y: amountRect.maxY + 40), withAttributes: [.font: nameFont])
            
            // 内訳表
            var tableTop: CGFloat = amountRect.maxY + 100
            let col1: CGFloat = 60
            let col2: CGFloat = 400
            
            func drawRow(label: String, value: String) {
                label.draw(at: CGPoint(x: col1, y: tableTop),
                           withAttributes: [.font: nameFont])
                value.draw(at: CGPoint(x: col2, y: tableTop),
                           withAttributes: [.font: nameFont])
                tableTop += 28
            }
            
            // --- 内訳 (ReceiptData を使用) ---
            if let s8 = receipt.subtotal8, s8 > 0 {
                drawRow(label: "8%税率 対象小計", value: "¥\(formatNumber(s8))")
                if receipt.taxType == "外税" {
                    drawRow(label: "8% 税額", value: "¥\(formatNumber(receipt.tax8))")
                }
            }
            if let s10 = receipt.subtotal10, s10 > 0 {
                drawRow(label: "10%税率 対象小計", value: "¥\(formatNumber(s10))")
                if receipt.taxType == "外税" {
                    drawRow(label: "10% 税額", value: "¥\(formatNumber(receipt.tax10))")
                }
            }
            
            // 左側 収入印紙枠
            let stampRect = CGRect(x: 50, y: tableTop + 40, width: 100, height: 100)
            let dash: [CGFloat] = [4, 4]
            let path = UIBezierPath(rect: stampRect)
            UIColor.lightGray.setStroke()
            path.setLineDash(dash, count: dash.count, phase: 0)
            path.stroke()
            
            let stampText = "収 入\n印 紙"
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = .center
            (stampText as NSString).draw(in: stampRect,
                                         withAttributes: [
                                            .font: UIFont.systemFont(ofSize: 16),
                                            .paragraphStyle: paragraph
                                         ])
            
            // 発行元情報（右下）
            let issuerY: CGFloat = tableTop + 40
            let issuer = """
            \(receipt.companyName)
            〒XXX-XXXX
            東京都千代田区〇〇1-2-3
            TEL: 000-0000-0000
            印：〇〇 太郎
            """
            issuer.draw(at: CGPoint(x: pageWidth - 300, y: issuerY),
                        withAttributes: [.font: nameFont])
        }
        
        return pdfData
    }
}