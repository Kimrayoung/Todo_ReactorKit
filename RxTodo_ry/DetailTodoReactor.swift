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
        case editTodo(Todo)
    }
    
    enum Mutation {
        case addTodo(Bool)
        case addTodoSample(Bool)
        case editTodo(Bool)
        case showErrorAlert(String)
    }
    
    struct State {
        var todo: Todo?
        var complete: Bool?
        var errorMsg: String?
    }
    
    var initialState: State
    
    init(initialState: State = State(todo: nil, complete: nil, errorMsg: nil)) {
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
        case .editTodo(let todo):
            return Observable.create { observer in
                let db = Firestore.firestore()
                let updateData = [
                    "title" : todo.title,
                    "description" : todo.description,
                    "editedAt" : todo.editedAt,
                    "dueDate" : todo.dueDate,
                    "isCompleted" : todo.isCompleted
                ]

                db.collection("todos").document(todo.id).updateData(updateData) { error in
                    if let error = error {
                        print(#fileID, #function, #line, "- updateData error: \(error)")
                        observer.onNext(Mutation.showErrorAlert(error.localizedDescription))
                    }
                }
                observer.onNext(Mutation.editTodo(true))
                observer.onCompleted()
                return Disposables.create()
            }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState: State = state
        switch mutation {
        case let .addTodo(addComplete):
            newState.complete = addComplete
        case .addTodoSample(let sample):
            print(#fileID, #function, #line, "- sample: \(sample)")
        case .editTodo(let editComplete):
            print(#fileID, #function, #line, "- update checking⭐️: \(editComplete)")
            if editComplete {
                newState.complete = editComplete
            }
        case .showErrorAlert(let errorMsg):
            newState.errorMsg = errorMsg
        }
        return newState
    }
}
