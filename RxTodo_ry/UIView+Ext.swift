//
//  UIView+Ext.swift
//  RxTodo_ry
//
//  Created by 김라영 on 2024/11/07.
//

import UIKit

extension UIView {
    func addSubViews(_ views: UIView...) {
        _ = views.map { self.addSubview($0) }
    }
}

