//
//  Date+Ext.swift
//  RxTodo_ry
//
//  Created by 김라영 on 2024/11/07.
//

import Foundation

extension Date {
    /// UI에 보여지는 string형식으로 변환(2021.03.21 21:11)
    var dateToString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        
        return formatter.string(from: self)
    }
    
    var dbString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        
        return formatter.string(from: self)
    }
}
