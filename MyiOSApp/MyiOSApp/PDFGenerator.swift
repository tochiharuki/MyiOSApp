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
            let titleFont = ReceiptFont.bold(size: 24)
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
            let nameFont = ReceiptFont.regular(size: 16)
            let recipient = "\(receipt.recipient) \(receipt.recipientSuffix)"   // ← ここで連動
            let recipientPoint = CGPoint(x: 50, y: titleRect.maxY + 40)
            recipient.draw(at: recipientPoint, withAttributes: [.font: nameFont])
            
            // 宛名文字列の幅を計算
            let recipientSize = recipient.size(withAttributes: [.font: nameFont])
            
            // 宛名下線（宛名の長さ＋余白で止める）
            let underlineStartX = recipientPoint.x
            let underlineEndX = recipientPoint.x + recipientSize.width + 20  // ← 余白20ptくらい
            let underlineY = recipientPoint.y + recipientSize.height + 2
            
            ctx.setStrokeColor(UIColor.black.cgColor)
            ctx.setLineWidth(1)
            ctx.move(to: CGPoint(x: underlineStartX, y: underlineY))
            ctx.addLine(to: CGPoint(x: underlineEndX, y: underlineY))
            ctx.strokePath()
            
            // 領収番号と発行日（右上）
            let receiptNo = generateReceiptNo(from: receipt.issueDate)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy年MM月dd日"
            
            let rightAttr: [NSAttributedString.Key: Any] = [.font: nameFont]
            "領収番号: \(receiptNo)".draw(at: CGPoint(x: pageWidth - 250, y: recipientPoint.y), withAttributes: rightAttr)
            "発行日: \(formatter.string(from: receipt.issueDate))".draw(at: CGPoint(x: pageWidth - 250, y: recipientPoint.y + 30), withAttributes: rightAttr)
            
            // 金額中央表示（背景グレー）
            let total = receipt.totalAmount   // ← 修正ポイント
            let amountText = "¥ \(formatNumber(total)) -"
            let amountFont = ReceiptFont.bold(size: 28)
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
                         withAttributes: [.font: ReceiptFont.regular(size: 14)])
            
            // 但し書き
            var remarksText: String
            if receipt.remarks.isEmpty {
                remarksText = "上記正に領収いたしました。"
            } else {
                remarksText = "但し　\(receipt.remarks)\n上記正に領収いたしました。"
            }
            
            // 行間を広げるためのスタイル
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 6  // ← 行間を広げる値（ポイント単位）
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: nameFont,
                .paragraphStyle: paragraphStyle
            ]
            
            // 描画
            remarksText.draw(
                with: CGRect(x: 50, y: amountRect.maxY + 40, width: 400, height: 100),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: attributes,
                context: nil
            )


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
            
            if receipt.taxRate == "8%" {
                drawRow(label: "8%税率 対象小計", value: "¥\(formatNumber(receipt.subtotal))")
                drawRow(label: "8% 税額", value: "¥\(formatNumber(receipt.tax))")
            } else if receipt.taxRate == "10%" {
                drawRow(label: "10%税率 対象小計", value: "¥\(formatNumber(receipt.subtotal))")
                drawRow(label: "10% 税額", value: "¥\(formatNumber(receipt.tax))")
            }
            // 左側 収入印紙枠
            if receipt.showStampBox {
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
                                                .font: ReceiptFont.regular(size: 16),
                                                .paragraphStyle: paragraph
                                             ])
            }
                
            // 発行元を右下に配置
            if !receipt.issuer.isEmpty {
                let issuerParagraph = NSMutableParagraphStyle()
                issuerParagraph.lineSpacing = 4
                issuerParagraph.alignment = .right   // 右寄せにする
            
                let issuerAttributes: [NSAttributedString.Key: Any] = [
                    .font: nameFont,
                    .paragraphStyle: issuerParagraph
                ]
            
                // ページサイズ取得
                let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842) // A4 (72dpi)
            
                // 発行元のテキスト
                let issuerText = "【発行元】\n\(receipt.issuer)"
            
                // 描画サイズを計算
                let textSize = issuerText.boundingRect(
                    with: CGSize(width: pageRect.width - 100, height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: issuerAttributes,
                    context: nil
                )
            
                // 下端から余白を取って配置（マージン 50）
                let issuerRect = CGRect(
                    x: 50,
                    y: pageRect.height - 50 - textSize.height,
                    width: pageRect.width - 100,
                    height: textSize.height
                )
            
                issuerText.draw(
                    with: issuerRect,
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: issuerAttributes,
                    context: nil
                )
            }
        
        return pdfData
    }
}