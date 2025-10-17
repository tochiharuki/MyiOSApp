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
            kCGPDFContextAuthor: "MyiOSApp User",
            kCGPDFContextTitle: "領収書"
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        // A4 横
        let pageWidth: CGFloat = 841.8
        let pageHeight: CGFloat = 595.2
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            guard let ctx = UIGraphicsGetCurrentContext() else { return }
            
            // --- タイトル ---
            let title = "領　収　書"
            let titleFont = ReceiptFont.bold(size: 32)
            let titleAttr: [NSAttributedString.Key: Any] = [.font: titleFont]
            let titleSize = title.size(withAttributes: titleAttr)
            
            // 上余白（上マージン）
            let titleY: CGFloat = 60
            title.draw(at: CGPoint(x: (pageWidth - titleSize.width)/2, y: titleY), withAttributes: titleAttr)
            
            // タイトル下余白基準（他要素はこれを基準に配置）
            let afterTitleY = titleY + titleSize.height + 40 // 下余白を広めに
            
            // タイトル下線（見た目整える）
            ctx.setStrokeColor(UIColor.black.cgColor)
            ctx.setLineWidth(1.2)
            ctx.move(to: CGPoint(x: 60, y: titleY + titleSize.height + 18))
            ctx.addLine(to: CGPoint(x: pageWidth - 60, y: titleY + titleSize.height + 18))
            ctx.strokePath()
            
            // --- 宛名 ---
            let nameFont = ReceiptFont.regular(size: 22)
            let recipient = "\(receipt.recipient)   \(receipt.recipientSuffix)"
            let recipientY: CGFloat = afterTitleY + 10
            recipient.draw(at: CGPoint(x: 80, y: recipientY), withAttributes: [.font: nameFont])
            
            let recipientSize = recipient.size(withAttributes: [.font: nameFont])
            ctx.setLineWidth(1.0)
            ctx.move(to: CGPoint(x: 80, y: recipientY + recipientSize.height + 6))
            ctx.addLine(to: CGPoint(x: 80 + recipientSize.width + 40, y: recipientY + recipientSize.height + 6))
            ctx.strokePath()
            
            // --- 発行日・領収番号（右上） ---
            let infoFont = ReceiptFont.regular(size: 17)
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "ja_JP")
            dateFormatter.dateFormat = "yyyy年MM月dd日"

            let rightMargin: CGFloat = 40 // 右端からの余白
            let baseY = recipientY

            // 領収番号
            let receiptNumberText = "領収番号: \(generateReceiptNo(from: receipt.issueDate))" as NSString
            let receiptNumberSize = receiptNumberText.size(withAttributes: [.font: infoFont])
            receiptNumberText.draw(
                at: CGPoint(x: pageWidth - rightMargin - receiptNumberSize.width, y: baseY),
                withAttributes: [.font: infoFont]
            )

            // 発行日
            let issueDateText = "発行日: \(dateFormatter.string(from: receipt.issueDate))" as NSString
            let issueDateSize = issueDateText.size(withAttributes: [.font: infoFont])
            issueDateText.draw(
                at: CGPoint(x: pageWidth - rightMargin - issueDateSize.width, y: baseY + 24),
                withAttributes: [.font: infoFont]
            )

            
            // --- 金額 ---
            let total = receipt.totalAmount
            let amountText = "¥ \(formatNumber(total))"
            let amountFont = ReceiptFont.bold(size: 36)
            let amountSize = amountText.size(withAttributes: [.font: amountFont])
            let amountY = recipientY + 90
            let amountX = (pageWidth - amountSize.width) / 2
            (amountText as NSString).draw(at: CGPoint(x: amountX, y: amountY), withAttributes: [.font: amountFont])
            
            // 金額下線（幅を金額に合わせて上品に）
            ctx.setLineWidth(1.0)
            ctx.move(to: CGPoint(x: amountX - 12, y: amountY + amountSize.height + 8))
            ctx.addLine(to: CGPoint(x: amountX + amountSize.width + 12, y: amountY + amountSize.height + 8))
            ctx.strokePath()
            
            // (税込) 表示
            ("(税込)" as NSString).draw(at: CGPoint(x: amountX + amountSize.width + 18, y: amountY + 10), withAttributes: [.font: ReceiptFont.regular(size: 14)])
            
            // --- 右側の起点（但し書き・内訳を右にまとめる） ---
            let contentTop: CGFloat = amountY + amountSize.height + 60
            let rightAreaX: CGFloat = pageWidth / 2 - 200
            let rightAreaWidth: CGFloat = pageWidth - rightAreaX - 80
            
            // --- 但し書き（右側） ---
            let remarksText: String
            if receipt.remarks.isEmpty {
                remarksText = "上記正に領収いたしました。"
            } else {
                remarksText = "但し　\(receipt.remarks)\n上記正に領収いたしました。"
            }
            
            let remarksParagraph = NSMutableParagraphStyle()
            remarksParagraph.lineSpacing = 6
            let remarksAttr: [NSAttributedString.Key: Any] = [
                .font: ReceiptFont.regular(size: 16),
                .paragraphStyle: remarksParagraph
            ]
            let remarksRect = CGRect(x: rightAreaX, y: contentTop, width: rightAreaWidth, height: 60)
            (remarksText as NSString).draw(with: remarksRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: remarksAttr, context: nil)
            
            // --- 内訳表（但し書きの下、右側） ---
            var tableY = remarksRect.maxY + 12
            let col1X: CGFloat = rightAreaX
            let col2X: CGFloat = rightAreaX + 150
            func drawRow(label: String, value: String) {
                (label as NSString).draw(at: CGPoint(x: col1X, y: tableY), withAttributes: [.font: infoFont])
                (value as NSString).draw(at: CGPoint(x: col2X, y: tableY), withAttributes: [.font: infoFont])
                tableY += 28
            }
            if receipt.taxRate == "8%" {
                drawRow(label: "8%対象小計", value: "¥\(formatNumber(receipt.subtotal))")
                drawRow(label: "8% 消費税", value: "¥\(formatNumber(receipt.tax))")
            } else if receipt.taxRate == "10%" {
                drawRow(label: "10%対象小計", value: "¥\(formatNumber(receipt.subtotal))")
                drawRow(label: "10% 消費税", value: "¥\(formatNumber(receipt.tax))")
            }
            
            // --- 収入印紙枠（左側） ---
            if receipt.showStampBox {
                let stampWidth: CGFloat = 100
                let stampHeight: CGFloat = 100
                let stampX: CGFloat = 80
                var stampY: CGFloat = 400
                // 収入印紙がページ下にはみ出すのを防ぐため調整
                let bottomMargin: CGFloat = 30
                let stampRect = CGRect(x: stampX, y: stampY, width: stampWidth, height: stampHeight)
                
                // 点線枠
                let path = UIBezierPath(rect: stampRect)
                UIColor.gray.setStroke()
                path.setLineDash([5, 4], count: 2, phase: 0)
                path.lineWidth = 1.0
                path.stroke()
                
                // テキストを中央に描画する（行間調整）
                let stampText = "収 入\n印 紙"
                let stampParagraph = NSMutableParagraphStyle()
                stampParagraph.alignment = .center
                stampParagraph.lineSpacing = 6
                
                let textAttributes: [NSAttributedString.Key: Any] = [
                    .font: ReceiptFont.regular(size: 16),
                    .paragraphStyle: stampParagraph
                ]
                
                let textBounding = (stampText as NSString).boundingRect(
                    with: CGSize(width: stampWidth, height: CGFloat.greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: textAttributes,
                    context: nil
                )
                // 中央揃え：枠の中央 - テキスト高さ/2
                let textY = stampRect.midY - textBounding.height / 2
                let textRect = CGRect(x: stampRect.origin.x, y: textY, width: stampRect.width, height: textBounding.height)
                (stampText as NSString).draw(in: textRect, withAttributes: textAttributes)
            }
            
            // --- 発行元（右下、余裕を持ってマージン付き） ---
            if !receipt.issuer.isEmpty {
                let issuerParagraph = NSMutableParagraphStyle()
                issuerParagraph.alignment = .left  // ← 左揃え
                issuerParagraph.lineSpacing = 6
            
                let font = ReceiptFont.regular(size: 16)
                let issuerAttr: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .paragraphStyle: issuerParagraph,
                    .foregroundColor: UIColor.black
                ]
            
                let marginRight: CGFloat = 40
                let marginBottom: CGFloat = 40
                let maxWidth: CGFloat = 250
            
                // --- テキストサイズを計算 ---
                let textBounding = (receipt.issuer as NSString).boundingRect(
                    with: CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: issuerAttr,
                    context: nil
                )
            
                // ✅ 右下に合わせるように配置
                let x = pageWidth - textBounding.width - marginRight
                let y = pageHeight - textBounding.height - marginBottom
                let issuerRect = CGRect(x: x, y: y, width: textBounding.width, height: textBounding.height)
            
                (receipt.issuer as NSString).draw(
                    with: issuerRect,
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: issuerAttr,
                    context: nil
                )
            }



        }
        
        return data
    }


}