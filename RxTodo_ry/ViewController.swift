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

class ViewController: UIViewController {
    var disposeBag: DisposeBag = DisposeBag()
    @IBOutlet weak var todoList: UITableView!
    
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
////         tableView에서 데이터를 선택했음을 알려준다
////         reactor의 state에서 선택한 index에 해당 하는 데이터만 가지고 오게 하기 위해서 몇번째 인덱스인지 알려준다
//        todoList.rx.itemSelected
//            .map { TodoReactor.Action.todoSelected($0.row) }
//            .bind(to: reactor.action)
//            .disposed(by: disposeBag)
//        
////         todoList.rx.itemSelected에서 todoSelected 액션을 통해서 나온 selectTodo state를 사용
////         이 데이터를 기준으로 DetailTodoVC에 데이터를 넣어준 후 view를 이동한다
//        reactor.state.map { $0.selectTodo }
//            .debug("????")
//            .filter { $0 != nil }
//            .subscribe { [weak self] todo in
//                guard let self = self else { return }
//                guard let todoDetailController = DetailTodoViewController.getInstance() else { return }
//                todoDetailController.navigationItem.title = "할 일 수정"
//                todoDetailController.todoData = todo
//                todoDetailController.vcType = .edit
//                self.navigationController?.pushViewController(todoDetailController, animated: false)
//            }
//            .disposed(by: disposeBag)
        
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
    }
}


