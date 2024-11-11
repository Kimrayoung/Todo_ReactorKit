//
//  Storyboard+Ext.swift
//  RxTodo_ry
//
//  Created by 김라영 on 2024/11/11.
//

import Foundation
import UIKit

protocol Storyboarded {
    static func getInstance(_ storyboardName: String?, storyboardID: String?) -> Self?
}

extension Storyboarded {
    static func getInstance(_ storyboardName: String? = nil, storyboardID: String? = nil) -> Self? {
        let name = storyboardName ?? String(describing: self)
        let id = storyboardID ?? String(describing: self)
        
        let storyBoard = UIStoryboard(name: name, bundle: Bundle.main)
        return storyBoard.instantiateViewController(withIdentifier: id) as? Self
    }
}

extension UIViewController: Storyboarded {}
