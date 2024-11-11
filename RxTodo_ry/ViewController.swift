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
    
    @objc private func addTodoTapped() {
        guard let todoDetailController = DetailTodoViewController.getInstance() else { return }
        todoDetailController.reactor = self.reactor
        todoDetailController.navigationItem.title = "할 일 추가"
        self.navigationController?.pushViewController(todoDetailController, animated: false)
        
    }
}

extension ViewController: StoryboardView {
    func bind(reactor: TodoReactor) {
        reactor.action.onNext(.enterView)
        
        reactor.state.map { $0.todos }
            .bind(to: todoList.rx.items(cellIdentifier: "TodoCell", cellType: TodoCell.self)) {
                _, todo, cell in
                cell.setupData(todo)
            }
            .disposed(by: disposeBag)
    }
}


