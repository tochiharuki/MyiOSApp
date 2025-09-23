//
//  PDFGenerator.swift
//  MyiOSApp
//
//  Created by Tochishita Haruki on 2025/09/21.
//

import Foundation
import PDFKit
import UIKit

enum PDFGeneratorError: Error {
    case generationFailed(String)
}

struct PDFGenerator {
    static func generate(from receipt: ReceiptData) throws -> Data {
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
        
        // 領収書番号（日時ベースで自動生成）
        let formatterForNo = DateFormatter()
        formatterForNo.dateFormat = "yyyyMMddHHmmss"
        let receiptNo = "R-" + formatterForNo.string(from: Date())
        
        // 金額計算
        let total = Int(receipt.amount) ?? 0
        var taxExcluded = total
        var taxAmount = 0
        
        if receipt.taxRate != "非課税" {
            let rate = receipt.taxRate == "8%" ? 0.08 : 0.10
            if receipt.taxType == "内税" {
                taxExcluded = Int(floor(Double(total) / (1.0 + rate)))
                taxAmount = total - taxExcluded
            } else { // 外税
                taxExcluded = total
                taxAmount = Int(floor(Double(total) * rate))
            }
        } else {
            taxExcluded = total
            taxAmount = 0
        }
        
        do {
            let pdfData = try renderer.pdfData { context in
                context.beginPage()
                
                // タイトル
                let title = "領収書"
                let titleFont = UIFont.boldSystemFont(ofSize: 24)
                let titleAttributes: [NSAttributedString.Key: Any] = [.font: titleFont]
                let titleSize = title.size(withAttributes: titleAttributes)
                let titleRect = CGRect(
                    x: (pageWidth - titleSize.width)/2,
                    y: 40,
                    width: titleSize.width,
                    height: titleSize.height
                )
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
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "ja_JP")
                dateFormatter.dateStyle = .long
                
                drawLine("領収書No", receiptNo)
                drawLine("発行日", dateFormatter.string(from: receipt.issueDate))
                drawLine("宛名", receipt.recipient.isEmpty ? "（未入力）" : receipt.recipient)
                drawLine("金額（税込）", "\(total) 円 (\(receipt.taxType)・税率 \(receipt.taxRate))")
                drawLine("税抜金額", "\(taxExcluded) 円")
                drawLine("消費税", "\(taxAmount) 円")
                drawLine("但し書き", receipt.remarks.isEmpty ? "（未入力）" : receipt.remarks)
                drawLine("発行元", receipt.companyName.isEmpty ? "（未入力）" : receipt.companyName)
                
                // 下部に署名欄
                textTop += 60
                let signText = "印"
                let signAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 18)]
                signText.draw(at: CGPoint(x: pageWidth - 100, y: textTop), withAttributes: signAttributes)
            }
            return pdfData
        } catch {
            throw PDFGeneratorError.generationFailed(error.localizedDescription)
        }
    }
}