//
//  todoCell.swift
//  RxTodo_ry
//
//  Created by 김라영 on 2024/11/07.
//

import Foundation
import UIKit
import SnapKit

class TodoCell: UITableViewCell {
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder: ) has not been implemented")
    }
    
    func setupData(_ todoData: Todo) {
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
