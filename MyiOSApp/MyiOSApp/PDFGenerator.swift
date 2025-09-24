//
// PDFGenerator.swift
// MyiOSApp
//

import Foundation
import PDFKit
import UIKit

enum PDFGeneratorError: Error {
    case generationFailed(String)
}

struct PDFGenerator {

    // 日付ベース領収書No生成
    private static func generateReceiptNo(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let dateStr = formatter.string(from: date)
        let random = Int.random(in: 1000...9999)
        return "\(dateStr)-\(random)"
    }
    
    // 数字を3桁カンマ区切りに
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
            
            // タイトル
            let title = "領収書"
            let titleFont = UIFont.boldSystemFont(ofSize: 24)
            let titleAttributes: [NSAttributedString.Key: Any] = [.font: titleFont]
            let titleSize = title.size(withAttributes: titleAttributes)
            let titleRect = CGRect(
                x: (pageWidth - titleSize.width)/2,
                y: 20,
                width: titleSize.width,
                height: titleSize.height
            )
            title.draw(in: titleRect, withAttributes: titleAttributes)
            
            var textTop: CGFloat = 80
            let leftMargin: CGFloat = 40
            let lineSpacing: CGFloat = 28
            let font = UIFont.systemFont(ofSize: 16)
            
            func drawLine(_ label: String, _ value: String, highlight: Bool = false) {
                let text = "\(label): \(value)"
                let attributes: [NSAttributedString.Key: Any] = [.font: font]
                if highlight {
                    let rect = CGRect(x: leftMargin + 100, y: textTop - 4, width: 200, height: 24)
                    UIColor.lightGray.setFill()
                    UIRectFill(rect)
                }
                text.draw(at: CGPoint(x: leftMargin, y: textTop), withAttributes: attributes)
                textTop += lineSpacing
            }
            
            // 領収書No
            let receiptNo = generateReceiptNo(from: receipt.issueDate)
            drawLine("領収書No", receiptNo)
            
            // 日付
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ja_JP")
            formatter.dateStyle = .long
            drawLine("発行日", formatter.string(from: receipt.issueDate))
            
            drawLine("宛名", receipt.recipient)
            
            // 金額計算（四捨五入）
            let total = receipt.amount ?? 0.0  // nil の場合 0 に置換
            var taxExcluded: Double = 0.0
            var taxAmount: Double = 0.0
            var totalAmount: Double = total
            
            if receipt.taxRate != "非課税" {
                let rate: Double = receipt.taxRate == "8%" ? 0.08 : 0.10
            
                if receipt.taxType == "内税" {
                    taxExcluded = (total / (1.0 + rate)).rounded()
                    taxAmount = (total - taxExcluded).rounded()
                    totalAmount = total
                } else { // 外税
                    taxExcluded = total
                    taxAmount = (total * rate).rounded()
                    totalAmount = (total + taxAmount).rounded()
                }
            }
            
            drawLine("金額（税込）", "¥\(formatNumber(totalAmount))", highlight: true)
            drawLine("税抜金額", "¥\(formatNumber(taxExcluded))")
            drawLine("消費税（\(receipt.taxRate)）", "¥\(formatNumber(taxAmount))")
            
            drawLine("但し書き", receipt.remarks)
            drawLine("発行元", receipt.companyName)
            
            // 署名欄
            textTop += 40
            let signText = "印"
            let signAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 18)]
            signText.draw(at: CGPoint(x: pageWidth - 100, y: textTop), withAttributes: signAttributes)
        }
        
        return pdfData
    }
}