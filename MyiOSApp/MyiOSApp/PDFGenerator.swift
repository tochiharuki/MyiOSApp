//
//  PDFGenerator.swift
//  MyiOSApp
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
    
    static func generate(from receipt: ReceiptData) throws -> Data {
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
                    y: 20,
                    width: titleSize.width,
                    height: titleSize.height
                )
                title.draw(in: titleRect, withAttributes: titleAttributes)
                
                var textTop: CGFloat = 80
                let leftMargin: CGFloat = 40
                let lineSpacing: CGFloat = 28
                let font = UIFont.systemFont(ofSize: 16)
                
                // 項目描画関数
                func drawLine(_ label: String, _ value: String) {
                    let text = "\(label): \(value)"
                    let attributes: [NSAttributedString.Key: Any] = [.font: font]
                    text.draw(at: CGPoint(x: leftMargin, y: textTop), withAttributes: attributes)
                    textTop += lineSpacing
                }
                
                // 領収書No
                let receiptNo = generateReceiptNo(from: receipt.issueDate)
                drawLine("領収書No", receiptNo)
                
                // 日付フォーマット
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "ja_JP")
                formatter.dateStyle = .long
                
                drawLine("発行日", formatter.string(from: receipt.issueDate))
                drawLine("宛名", receipt.recipient)
                
                // 金額計算
                let inputAmount = Int(receipt.amount) ?? 0
                var taxExcluded = inputAmount
                var taxAmount = 0
                var totalAmount = inputAmount
                
                if receipt.taxRate != "非課税" {
                    let rate = receipt.taxRate == "8%" ? 0.08 : 0.10
                    if receipt.taxType == "内税" {
                        taxExcluded = Int(floor(Double(inputAmount) / (1.0 + rate)))
                        taxAmount = inputAmount - taxExcluded
                        totalAmount = inputAmount
                    } else { // 外税
                        taxExcluded = inputAmount
                        taxAmount = Int(floor(Double(inputAmount) * rate))
                        totalAmount = inputAmount + taxAmount
                    }
                }
                
                // 金額表示
                drawLine("金額（税込）", "\(totalAmount) 円")
                if receipt.taxRate != "非課税" {
                    drawLine("消費税（\(receipt.taxRate)）", "\(taxAmount) 円")
                } else {
                    drawLine("消費税", "非課税")
                }
                drawLine("税抜金額", "\(taxExcluded) 円")
                
                drawLine("但し書き", receipt.remarks)
                drawLine("発行元", receipt.companyName)
                
                // 下部に署名欄
                textTop += 40
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