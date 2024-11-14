//
//  TodoCellReactor.swift
//  RxTodo_ry
//
//  Created by 김라영 on 2024/11/14.
//

import Foundation
import FirebaseFirestore
import ReactorKit
import RxSwift
import RxCocoa

final class TodoCellReactor: Reactor {
    enum Action {
        case changeToggle(Bool, String)
    }
    
    enum Mutation {
        case changeToggle(Bool)
        case showErrorAlert(String)
    }
    
    struct State {
        var isCompleted: Bool?
        var errorMsg: String?
    }
    
    var initialState: State
    
    init(isCompleted: Bool? = nil) {
        self.initialState = State(isCompleted: isCompleted, errorMsg: nil)
    }
}

extension TodoCellReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .changeToggle(isOn, todoId):
//            return .just(Mutation.changeToggle(isOn))
            return Observable.create { observer in
                let db = Firestore.firestore()
                let updateData = [
                    "isCompleted" : isOn
                ]

                db.collection("todos").document(todoId).updateData(updateData) { error in
                    if let error = error {
                        print(#fileID, #function, #line, "- updateData error: \(error)")
                        observer.onNext(Mutation.showErrorAlert(error.localizedDescription))
                    }
                }
                observer.onNext(Mutation.changeToggle(isOn))
                observer.onCompleted()
                return Disposables.create()
            }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState: State = state
        switch mutation {
        case .changeToggle(let isOn):
            print(#fileID, #function, #line, "- 흠냐흠냐 change")
            newState.isCompleted = isOn
        case .showErrorAlert(let errorMsg):
            newState.errorMsg = errorMsg
        }
        
        return newState
    }
}
