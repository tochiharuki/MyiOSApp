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
        
        let pageWidth: CGFloat = 595.2   // A4横幅 (pt)
        let pageHeight: CGFloat = 841.8  // A4縦 (pt)
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { (context) in
            context.beginPage()
            
            // タイトル
            let title = "領収書"
            let titleFont = UIFont.boldSystemFont(ofSize: 24)
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: titleFont
            ]
            let titleSize = title.size(withAttributes: titleAttributes)
            let titleRect = CGRect(x: (pageWidth - titleSize.width)/2,
                                   y: 40,
                                   width: titleSize.width,
                                   height: titleSize.height)
            title.draw(in: titleRect, withAttributes: titleAttributes)
            
            var textTop: CGFloat = 100
            let leftMargin: CGFloat = 40
            let lineSpacing: CGFloat = 28
            let font = UIFont.systemFont(ofSize: 16)
            
            // 項目を描画する小関数
            func drawLine(_ label: String, _ value: String) {
                let text = "\(label): \(value)"
                let attributes: [NSAttributedString.Key: Any] = [.font: font]
                text.draw(at: CGPoint(x: leftMargin, y: textTop), withAttributes: attributes)
                textTop += lineSpacing
            }
            
            // 内容
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ja_JP")
            formatter.dateStyle = .long
            
            drawLine("発行日", formatter.string(from: data.issueDate))
            drawLine("宛名", data.recipient)
            drawLine("金額", "\(data.amount) 円 (\(data.taxType)・税率 \(data.taxRate))")
            drawLine("但し書き", data.remarks)
            drawLine("発行元", data.companyName)
            
            // 下部に署名欄
            textTop += 60
            let signText = "印"
            let signAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 18)
            ]
            signText.draw(at: CGPoint(x: pageWidth - 100, y: textTop), withAttributes: signAttributes)
        }
        
        return data
    }
}