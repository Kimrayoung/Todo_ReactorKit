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
        case enterView
        case todoSelected(Int)
    }
    
    enum Mutation {
        case fetchTodos([Todo])
        case todoSelected(Int)
        case clearSelectedTodo
        case loading(Bool)
    }
    
    struct State {
        var todos: [Todo]
        var selectTodo: Todo? = nil
        var isLoading: Bool? = nil
    }

    var initialState: State
    
    init(initialState: State = State(todos: [])) {
        self.initialState = initialState
    }
}

extension TodoReactor {

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .enterView:
            let loadingStart = Observable.just(Mutation.loading(true))
            
            let fetchTodoList = Observable<Mutation>.create { observer in
                let db = Firestore.firestore()
                
                // Firebase의 firestore에서 todos collection에 있는 모든 문서를 가지고 온다
                db.collection("todos").getDocuments { query, error in
                    if let error = error {
                        observer.onError(error)
                    } else {
                        var todos: [Todo] = []
                        guard let query = query else {
                            observer.onCompleted()
                            return
                        }
                        
                        //query의 문서들에서 문서를 하나씩 가져와서 Todo형식으로 변환 후 todos에 넣어준다
                        for doc in query.documents {
                            do {
                                let todo = try doc.data(as: Todo.self)
                                todos.append(todo)
                            } catch {
                                observer.onError(error)
                            }
                        }
                        // 데이터를 모두 가져왔을 때 Mutation을 방출함
                        observer.onNext(Mutation.fetchTodos(todos))
                        observer.onCompleted()
                    }
                }
                //비동기 작업이나 리소스 정리가 필요할 때 옵저버블 해제 시 필요한 작업을 수행하기 위해서 사용한다.
                return Disposables.create()
            }
            
            // Loading이 잘 돌아가는지 확인하기 위해서 delay를 걸어줌
            let loadingFinish = Observable.just(Mutation.loading(false)).delay(.seconds(5), scheduler: MainScheduler.instance)
            
            // 3개 차례대로 나가짐
            return Observable.concat([
                loadingStart,
                fetchTodoList,
                loadingFinish
            ])
        case .todoSelected(let idx):
            // clear를 통해서 State의 selectTodo를 nil로 업데이트 해주지 않으면 viewController의 bind의 reactor.state.map { $0.selectTodo }가 계속 실행된다 -> 선택 상태를 해제하는 작업
            // 이유: ViewController에 돌아올때마다 State의 selectTodo에 값이 있어서 계속 트리거 되기 때문이다
            return .concat([
                .just(.todoSelected(idx)),
                .just(.clearSelectedTodo)
            ])
            
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState: State = state
        switch mutation {
        case .fetchTodos(let todos):
            newState.todos = todos
        
        case let .todoSelected(idx):
            newState.selectTodo = newState.todos[idx]
            
        case .clearSelectedTodo:
            newState.selectTodo = nil
            
        case .loading(let isLoading):
            print(#fileID, #function, #line, "- isLoading⭐️: \(isLoading)")
            newState.isLoading = isLoading
        }
        
        return newState
    }
        
}
