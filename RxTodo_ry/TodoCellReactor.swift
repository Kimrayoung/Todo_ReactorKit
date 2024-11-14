//
//  TodoCellReactor.swift
//  RxTodo_ry
//
//  Created by 김라영 on 2024/11/14.
//

import Foundation
import ReactorKit
import RxSwift
import RxCocoa

final class TodoCellReactor: Reactor {
    enum Action {
        case changeToggle(Bool)
    }
    
    enum Mutation {
        case changeToggle(Bool)
    }
    
    struct State {
        var isCompleted: Bool
    }
    
    var initialState: State
    
    init(initialState: State = State(isCompleted: false)) {
        self.initialState = initialState
    }
}

extension TodoCellReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .changeToggle(let isOn):
            return .just(Mutation.changeToggle(isOn))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState: State = state
        switch mutation {
        case .changeToggle(let isOn):
            newState.isCompleted = isOn
        }
        
        return newState
    }
}
