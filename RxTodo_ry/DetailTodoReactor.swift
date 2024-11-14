//
//  DetailTodoReactor.swift
//  RxTodo_ry
//
//  Created by 김라영 on 2024/11/13.
//

import Foundation
import ReactorKit
import FirebaseFirestore

final class DetailTodoReactor: Reactor {
    enum Action {
        case addTodo(Todo)
        case addTodoSample
    }
    
    enum Mutation {
        case addTodo(Bool)
        case addTodoSample(Bool)
    }
    
    struct State {
        var todo: Todo?
        var addTodoComplete: Bool?
    }
    
    var initialState: State
    
    init(initialState: State = State(todo: nil, addTodoComplete: nil)) {
        self.initialState = initialState
    }
}

extension DetailTodoReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .addTodo(let todo):
            return Observable.create { observer in
                let db = Firestore.firestore()
                do {
                    try db.collection("todos").document(todo.id).setData(from: todo) { error in
                        if let error = error { observer.onError(error) }
                    }
                } catch let error {
                    observer.onError(error)
                }
                observer.onNext(Mutation.addTodo(true))
                observer.onCompleted()
                return Disposables.create()
            }
        case .addTodoSample:
            return Observable.just(Mutation.addTodoSample(true))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState: State = state
        switch mutation {
        case let .addTodo(addComplete):
            newState.addTodoComplete = addComplete
        case .addTodoSample(let sample):
            print(#fileID, #function, #line, "- sample")
        }
        return newState
    }
}
