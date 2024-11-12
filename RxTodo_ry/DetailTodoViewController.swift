//
//  DetailTodoView.swift
//  RxTodo_ry
//
//  Created by 김라영 on 2024/11/11.
//

import Foundation
import UIKit
import ReactorKit

class DetailTodoViewController: UIViewController, StoryboardView {
    var disposeBag: DisposeBag = DisposeBag()
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var todoTitleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextView!
    @IBOutlet weak var dueDate: UIDatePicker!
    @IBOutlet weak var isCompleteToggle: UISwitch!
    
    var todoReactor: TodoReactor?
    
    let saveBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("저장", for: .normal)
        btn.backgroundColor = .clear
        btn.setTitleColor(.blue, for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 20)
        return btn
    }()
    
    private func showAlert() {
        let alert = UIAlertController(title: "오류", message: "할 일 제목을 입력해주세요", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default)
        alert.addAction(okAction)
        present(alert, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let navigationTrailingBtn = UIBarButtonItem(customView: saveBtn)
        self.navigationItem.rightBarButtonItem = navigationTrailingBtn
        descriptionTextField.layer.borderWidth = 1.0
        descriptionTextField.layer.borderColor = UIColor.systemGray4.cgColor
        descriptionTextField.layer.cornerRadius = 10.0
    }
}


extension DetailTodoViewController {
    func bind(reactor: TodoReactor) {
        /*
        self.saveBtn.rx.tap
            .debug("check saveBtn Tap")
            .withLatestFrom(todoTitleTextField.rx.text.orEmpty)
            .flatMap({ text -> Observable<TodoReactor.Action> in
                if text.isEmpty {
                    print(#fileID, #function, #line, "- Text가 비었어용")
                    return .empty()
                } else {
                    print(#fileID, #function, #line, "- text가 있어용: \(text)")
                    return .just(.addTodoSample)
                }
            })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        */
        
        // 저장버튼 누를 경우
        self.saveBtn.rx.tap
            .withLatestFrom(todoTitleTextField.rx.text.orEmpty)
            .flatMap { text -> Observable<TodoReactor.Action> in
                // title에 값이 들어가 있으면 Observable을 출력출력하고 아니라면 alert출력
                if text.isEmpty {
                    print(#fileID, #function, #line, "- Text비었음")
                    self.showAlert()
                    return .empty() // 빈 Observable을 생성하는 연산자
                } else {
                    let newTodo = Todo(id: UUID().uuidString, title: text, description: self.descriptionTextField.text, createdAt: Date().dateToString, isCompleted: self.isCompleteToggle.isOn)
                    return .just(.addTodo(newTodo))
                }
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // reactor의 state중에서 Todo데이터 추가가 완료되었을 때만 출력
        reactor.state.compactMap { $0.addTodoComplete }
            .filter { $0 }
            .subscribe (
                onNext: { [weak self] _ in
                    self?.navigationController?.popViewController(animated: false)
                }
            )
            .disposed(by: disposeBag)
            
    }
}
