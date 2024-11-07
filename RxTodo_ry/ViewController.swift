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
        self.reactor = TodoReactor()
        todoList.rowHeight = 60
        todoList.register(TodoCell.self, forCellReuseIdentifier: "TodoCell")
    }
}

extension ViewController: StoryboardView {
    func bind(reactor: TodoReactor) {
        reactor.action.onNext(.fetchTodos)
        
        reactor.state.map { $0.todos }
            .bind(to: todoList.rx.items(cellIdentifier: "TodoCell", cellType: TodoCell.self)) {
                _, todo, cell in
                cell.setupData(todo)
            }
            .disposed(by: disposeBag)
    }
}

//extension ViewController: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 1
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let todoCell = todoList.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath) as? TodoCell else { return UITableViewCell() }
//        
//        todoCell.setupData(Todo(id: "", title: "", description: "", createdAt: "", isCompleted: false))
//        
//        return todoCell
//    }
//    
//    
//}

