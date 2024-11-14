//
//  Data.swift
//  RxTodo_ry
//
//  Created by 김라영 on 2024/11/06.
//

import Foundation

struct Todo: Codable, Identifiable {
    var id: String
    var title: String
    var description: String
    var dueDate: String?
    var createdAt: String
    var editedAt: String?
    var isCompleted: Bool
}

enum DetailTodoType {
    case add
    case edit
}
