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

    // ランダム領収書No生成
    private static func generateReceiptNo() -> String {
        let number = Int.random(in: 1000...9999)
        return "RC\(number)"
    }

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
                
                // 領収書No
                let receiptNo = generateReceiptNo()
                drawLine("領収書No", receiptNo)
                
                // 日付フォーマット
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "ja_JP")
                formatter.dateStyle = .long
                
                drawLine("発行日", formatter.string(from: receipt.issueDate))
                drawLine("宛名", receipt.recipient)
                
                // 金額計算
                let total = Int(receipt.amount) ?? 0
                var taxExcluded = total
                var taxAmount = 0
                var totalAmount = total
                
                if receipt.taxRate != "非課税" {
                    let rate = receipt.taxRate == "8%" ? 0.08 : 0.10
                    if receipt.taxType == "内税" {
                        taxExcluded = Int(floor(Double(total) / (1.0 + rate)))
                        taxAmount = total - taxExcluded
                        totalAmount = total
                    } else { // 外税
                        taxExcluded = total
                        taxAmount = Int(floor(Double(total) * rate))
                        totalAmount = total + taxAmount
                    }
                }
                
                drawLine("金額（税込）", "\(totalAmount) 円 (\(receipt.taxType)・税率 \(receipt.taxRate))")
                drawLine("税抜金額", "\(taxExcluded) 円")
                drawLine("消費税", "\(taxAmount) 円")
                
                drawLine("但し書き", receipt.remarks)
                drawLine("発行元", receipt.companyName)
                
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