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
    
    var todoData: Todo?
    var vcType: DetailTodoType?
    
    let saveBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("저장", for: .normal)
        btn.backgroundColor = .clear
        btn.setTitleColor(.blue, for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 20)
        return btn
    }()
    
    private func showAlert(_ msg: String) {
        let alert = UIAlertController(title: "오류", message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default)
        alert.addAction(okAction)
        present(alert, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reactor = DetailTodoReactor()
        setData()
        let navigationTrailingBtn = UIBarButtonItem(customView: saveBtn)
        self.navigationItem.rightBarButtonItem = navigationTrailingBtn
        descriptionTextField.layer.borderWidth = 1.0
        descriptionTextField.layer.borderColor = UIColor.systemGray4.cgColor
        descriptionTextField.layer.cornerRadius = 10.0
    }
    
    private func setData() {
        guard let todoData = todoData else { return }
        todoTitleTextField.text = todoData.title
        descriptionTextField.text = todoData.description
        if let originalDueDate = todoData.dueDate {
            dueDate.date = originalDueDate.stringToDate
        }
        isCompleteToggle.isOn = todoData.isCompleted
    }
}


extension DetailTodoViewController {
    func bind(reactor: DetailTodoReactor) {
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
            .flatMap { [weak self] text -> Observable<DetailTodoReactor.Action> in
                guard let self = self else { return .empty() }
                // title에 값이 들어가 있으면 Observable을 출력출력하고 아니라면 alert출력
                if text.isEmpty {
                    print(#fileID, #function, #line, "- Text비었음")
                    self.showAlert("할 일 제목을 입력해주세요")
                    return .empty() // 빈 Observable을 생성하는 연산자
                } else {
                    guard let vcType = self.vcType else { return .empty() }
                    if vcType == .add {
                        let newTodo = Todo(id: UUID().uuidString, title: text, description: self.descriptionTextField.text, createdAt: Date().dateToString, isCompleted: self.isCompleteToggle.isOn)
                        return .just(.addTodo(newTodo))
                    } else {
                        guard let originalTodo = self.todoData else { return .empty() }
                        let changeTodo = Todo(id: originalTodo.id, title: text, description: self.descriptionTextField.text, createdAt: originalTodo.createdAt, editedAt: Date().dateToString, isCompleted: self.isCompleteToggle.isOn)
                        return .just(.editTodo(changeTodo))
                    }
                }
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // reactor의 state중에서 Todo데이터 추가가 완료되었을 때만 출력
        reactor.state.compactMap { $0.complete }
            .filter { $0 }
            .subscribe (
                onNext: { [weak self] _ in
                    self?.navigationController?.popViewController(animated: false)
                }
            )
            .disposed(by: disposeBag)
            
        reactor.state.compactMap { $0.errorMsg }
            .subscribe (
                onNext: { [weak self] errorMsg in
                    guard let self = self else { return }
                    self.showAlert(errorMsg)
                }
            )
            .disposed(by: disposeBag)
    }
}
