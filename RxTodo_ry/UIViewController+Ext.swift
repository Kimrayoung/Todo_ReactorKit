//
//  UIViewController+Ext.swift
//  RxTodo_ry
//
//  Created by 김라영 on 2024/11/18.
//

import Foundation
import UIKit

//
extension UIViewController {
    /// UIViewController에서 로딩뷰를 보이도록 한다
    func showLoadingView() {
        print(#fileID, #function, #line, "- startLoading⭐️")
        LoadingView.shared.startLoading()
    }
    
    /// /// UIViewController에서 로딩뷰가 없어지도록 한다
    func hideLoadingView() {
        print(#fileID, #function, #line, "- stopLoading⭐️")
        LoadingView.shared.stopLoading()
    }
}
