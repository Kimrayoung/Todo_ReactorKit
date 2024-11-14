//
//  todoCell.swift
//  RxTodo_ry
//
//  Created by 김라영 on 2024/11/07.
//

import Foundation
import UIKit
import SnapKit
import ReactorKit
import RxSwift

class TodoCell: UITableViewCell, View {
    var disposeBag: DisposeBag = DisposeBag()
    var todoId: String?
    
    private var createdAtLabel: UILabel = {
        let label = UILabel()
        
        return label
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    private var isCompleteToggle: UISwitch = {
        let toggle = UISwitch()
        return toggle
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        self.reactor = TodoCellReactor()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder: ) has not been implemented")
    }
}

extension TodoCell {
    func bind(reactor: TodoCellReactor) {
        isCompleteToggle.rx.isOn
            .skip(1)
            .map { [weak self] isOn  -> TodoCellReactor.Action in
                guard let self = self else { return TodoCellReactor.Action.changeToggle(isOn, "") }
                guard let todoId = self.todoId else { return TodoCellReactor.Action.changeToggle(isOn, "") }
                return TodoCellReactor.Action.changeToggle(isOn, todoId)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state.compactMap { $0.isCompleted }
            .bind(to: isCompleteToggle.rx.isOn)
            .disposed(by: disposeBag)
    }
}

extension TodoCell {
    
    func setupData(_ todoData: Todo) {
        todoId = todoData.id
        titleLabel.text = todoData.title
        createdAtLabel.text = todoData.createdAt.stringToDate.dateToString
        isCompleteToggle.isOn = todoData.isCompleted
    }
    
    private func setupLayout() {
        contentView.addSubViews(titleLabel, createdAtLabel, isCompleteToggle)
        
        createdAtLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(5)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(createdAtLabel.snp.bottom).offset(10)
            make.left.equalTo(createdAtLabel.snp.left)
        }
        
        isCompleteToggle.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
        }
    }
}
