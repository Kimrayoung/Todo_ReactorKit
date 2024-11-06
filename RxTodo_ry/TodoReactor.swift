//
//  TodoReactor.swift
//  RxTodo_ry
//
//  Created by 김라영 on 2024/11/06.
//

import Foundation
import ReactorKit
import RxSwift
import FirebaseFirestore

final class TodoReactor: Reactor {
    enum Action {
        case fetchTodos
    }
    
    enum Mutation {
        case fetchTodos([Todo])
    }
    
    struct State {
        var todos: [Todo]
    }

    var initialState: State
    
    init(initialState: State) {
        self.initialState = initialState
    }
}

extension TodoReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchTodos:
            var todos: [Todo] = []
            Firestore.firestore().collection("todos").getDocuments { query, error in
                if let error = error {
                    print(#fileID, #function, #line, "- error: \(error)")
                } else {
                    guard let query = query else { return }
                    for doc in query.documents {
                        do {
                            let todo = try doc.data(as: Todo.self)
                            todos.append(todo)
                        } catch {
                            print(#fileID, #function, #line, "- error: \(error)")
                        }
                        
                    }
                }
            }
            return Observable.just(Mutation.fetchTodos(todos))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState: State = state
        switch mutation {
        case .fetchTodos(let todos):
            newState.todos = todos
        }
        
        return newState
    }
}
