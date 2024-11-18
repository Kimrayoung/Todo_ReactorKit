//
//  ViewController.swift
//  RxTodo_ry
//
//  Created by 김라영 on 2024/11/06.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa
import SnapKit

class ViewController: UIViewController {
    var disposeBag: DisposeBag = DisposeBag()
    @IBOutlet weak var todoList: UITableView!
    
//    private static var loadingView = LoadingV
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTodoTapped))
        self.navigationItem.rightBarButtonItem = addButton
        self.reactor = TodoReactor()
        todoList.rowHeight = 60
        todoList.register(TodoCell.self, forCellReuseIdentifier: "TodoCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // reactor에 action옵저버블을 보낸다
        self.reactor?.action.onNext(.enterView)
    }
    
    @objc private func addTodoTapped() {
        guard let todoDetailController = DetailTodoViewController.getInstance() else { return }
//        todoDetailController.reactor = self.reactor
        todoDetailController.navigationItem.title = "할 일 추가"
        todoDetailController.vcType = .add
        self.navigationController?.pushViewController(todoDetailController, animated: false)
    }
}


extension ViewController: StoryboardView {
    func bind(reactor: TodoReactor) {
        todoList.rx.itemSelected
            .withLatestFrom(reactor.state) { indexPath, state in
                (indexPath.row, state.todos[indexPath.row])
            }
            .subscribe { [weak self] index, todo in
                guard let self = self else { return }
                guard let todoDetailController = DetailTodoViewController.getInstance() else { return }
                todoDetailController.navigationItem.title = "할 일 수정"
                todoDetailController.todoData = todo
                todoDetailController.vcType = .edit
                self.navigationController?.pushViewController(todoDetailController, animated: false)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.todos }
            .bind(to: todoList.rx.items(cellIdentifier: "TodoCell", cellType: TodoCell.self)) {
                _, todo, cell in
                cell.setupData(todo)
            }
            .disposed(by: disposeBag)
        
        reactor.state.compactMap { $0.isLoading } // nil일때는 부르지 않도록 compactMap사용
            .subscribe(onNext: {
                if $0 { self.showLoadingView() } //true일때는 show
                else { self.hideLoadingView() } //false일때는 hide
            })
            .disposed(by: disposeBag)
    }
}


