//
//  String+Ext.swift
//  RxTodo_ry
//
//  Created by 김라영 on 2024/11/07.
//

import Foundation

extension String {
    var stringToDate: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        
        return formatter.date(from: self) ?? .now
    }
}
