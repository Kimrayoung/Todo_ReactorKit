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
        // viewDidLoad가 되자마자 Action을 트리거
        // onNext메서드를 사용하여 Action을 Reactor에게 전달한다.
        // 기존의 tap.map.bind -> 이것과 비슷하다
        // 기존의 Tap이라는 액션이 들어오면 해당 액션에 트리거되어서 map{reactor.Action.increase}를 통해서 Tap을 Action Type으로 변환하고 .bind(to: reactor.action)을 통해서 reactor.action에 연결 시켜준 것과 같이
        // 즉, 사용자의 tap액션을 Reactor에게 전달하는 것
        //reactor.action.onNext(.enterView)도 위의 원리와 비슷하게 fetchTodos라는 액션을 전달해준 것이다.
        reactor.action.onNext(.enterView)
        
        reactor.state.map { $0.todos }
            .bind(to: todoList.rx.items(cellIdentifier: "TodoCell", cellType: TodoCell.self)) {
                _, todo, cell in
                cell.setupData(todo)
            }
            .disposed(by: disposeBag)
    }
}


