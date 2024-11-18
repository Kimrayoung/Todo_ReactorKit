//
//  LoadingView.swift
//  RxTodo_ry
//
//  Created by 김라영 on 2024/11/18.
//

import Foundation
import UIKit
import SnapKit

class LoadingView: UIView {
    static let shared = LoadingView()
    
    private var loadingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.isHidden = true
        return view
    }()
    
    /// 로딩뷰
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .gray
        return indicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpView()
    }
    
    /// window에 loadingView 추가해주기
    func addToWindow() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        if loadingView.superview != window {
            print(#fileID, #function, #line, "- ⭐️⭐️")
            window.addSubview(loadingView)
            
            loadingView.snp.makeConstraints { make in
                make.leading.equalTo(window.snp.leading)
                make.trailing.equalTo(window.snp.trailing)
                make.top.equalTo(window.snp.top)
                make.bottom.equalTo(window.snp.bottom)
            }
        }
    }
    
    /// 로딩 시작하는 함수
    func startLoading() {
        addToWindow()

        UIView.animate(withDuration: 0.3) {
            self.loadingView.alpha = 1
        } completion: { [weak self] _ in
            guard let self = self else { return }
            self.loadingView.isHidden = false
            self.activityIndicator.startAnimating()
        }
    }
    
    
    /// 로딩 멈추는 함수
    func stopLoading() {
        UIView.animate(withDuration: 0.3) {
            self.loadingView.alpha = 0
        } completion: { [weak self] _ in
            guard let self = self else {return}
            self.loadingView.isHidden = true
            self.activityIndicator.stopAnimating()
        }
        
    }
}

extension LoadingView {
    // activityIndicator 레이아웃 잡아주기
    func setUpView() {
        loadingView.addSubview(activityIndicator)
        
        self.activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}


