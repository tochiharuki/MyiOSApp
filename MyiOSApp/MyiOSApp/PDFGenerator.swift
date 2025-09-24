//
//  PDFGenerator.swift
//  MyiOSApp
//
//  Created by Tochishita Haruki on 2025/09/21.
//

import Foundation
import PDFKit
import UIKit

struct PDFGenerator {
    static func generate(from data: ReceiptData) -> Data? {
        let pdfMetaData = [
            kCGPDFContextCreator: "MyiOSApp",
            kCGPDFContextAuthor: "MyiOSApp User",
            kCGPDFContextTitle: "領収書"
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        // A4 横向き
        let pageWidth: CGFloat = 841.8
        let pageHeight: CGFloat = 595.2
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let pdfData = renderer.pdfData { context in
            context.beginPage()
            
            // 共通フォント
            let font = UIFont.systemFont(ofSize: 14)
            let boldFont = UIFont.boldSystemFont(ofSize: 14)
            
            // 領収書タイトル
            let title = "領収書"
            let titleFont = UIFont.boldSystemFont(ofSize: 28)
            let titleAttributes: [NSAttributedString.Key: Any] = [.font: titleFont]
            let titleSize = title.size(withAttributes: titleAttributes)
            title.draw(at: CGPoint(x: (pageWidth - titleSize.width)/2, y: 40),
                       withAttributes: titleAttributes)
            
            // 上部情報（右寄せ）
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ja_JP")
            formatter.dateStyle = .long
            
            let receiptNo = "No. \(generateReceiptNumber(date: data.issueDate))"
            let issueDate = "発行日: \(formatter.string(from: data.issueDate))"
            let recipient = "宛名: \(data.recipient)"
            
            let infoRightX: CGFloat = pageWidth - 280
            let infoTop: CGFloat = 100
            let lineSpacing: CGFloat = 24
            
            [receiptNo, issueDate, recipient].enumerated().forEach { (index, text) in
                text.draw(at: CGPoint(x: infoRightX, y: infoTop + CGFloat(index) * lineSpacing),
                          withAttributes: [.font: font])
            }
            
            // 金額（背景付き）
            let amountY: CGFloat = 180
            let amountHeight: CGFloat = 60
            let amountRect = CGRect(x: 60, y: amountY, width: pageWidth - 120, height: amountHeight)
            
            UIColor(white: 0.95, alpha: 1.0).setFill()
            UIBezierPath(rect: amountRect).fill()
            
            let amountText = "金額（税込）　¥\(formatNumber(data.amount))"
            let amountFont = UIFont.boldSystemFont(ofSize: 24)
            let amountAttributes: [NSAttributedString.Key: Any] = [.font: amountFont]
            let amountSize = amountText.size(withAttributes: amountAttributes)
            amountText.draw(at: CGPoint(x: amountRect.midX - amountSize.width/2,
                                        y: amountRect.midY - amountSize.height/2),
                            withAttributes: amountAttributes)
            
            // 内訳
            var detailTop: CGFloat = amountY + amountHeight + 40
            func drawDetail(label: String, value: String) {
                let labelAttr: [NSAttributedString.Key: Any] = [.font: boldFont]
                let valueAttr: [NSAttributedString.Key: Any] = [.font: font]
                
                label.draw(at: CGPoint(x: 80, y: detailTop), withAttributes: labelAttr)
                value.draw(at: CGPoint(x: 200, y: detailTop), withAttributes: valueAttr)
                detailTop += 26
            }
            
            let taxExcluded = Int(Double(data.amount) / (1 + data.taxRate/100))
            let taxAmount = data.amount - taxExcluded
            
            drawDetail(label: "税抜金額", value: "¥\(formatNumber(taxExcluded))")
            drawDetail(label: "消費税 (\(Int(data.taxRate))%)", value: "¥\(formatNumber(taxAmount))")
            drawDetail(label: "発行元", value: data.companyName)
            drawDetail(label: "但し書き", value: data.remarks)
            
            // 下部 印欄
            let signText = "印"
            let signFont = UIFont.systemFont(ofSize: 20)
            signText.draw(at: CGPoint(x: pageWidth - 100, y: pageHeight - 100),
                          withAttributes: [.font: signFont])
        }
        
        return pdfData
    }
    
    /// 日付ベースのユニーク番号生成
    private static func generateReceiptNumber(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        return formatter.string(from: date)
    }
    
    /// 数字フォーマット（3桁区切り）
    private static func formatNumber(_ num: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: num)) ?? "\(num)"
    }
}