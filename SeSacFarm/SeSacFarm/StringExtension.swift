//
//  StringExtension.swift
//  SeSacFarm
//
//  Created by 천수현 on 2022/01/09.
//

import Foundation
extension String {
    func convertToDate() -> String {
        let date = DateFormatter().date(from: self) ?? Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd"
        return dateFormatter.string(from: date)
    }
}
