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
        case addTodo(Todo)
        case addTodoSample
    }
    
    enum Mutation {
        case fetchTodos([Todo])
        case addTodo(Bool, Todo)
        case addTodoSample(Bool)
    }
    
    struct State {
        var todos: [Todo]
        var addTodoComplete: Bool?
    }

    var initialState: State
    
    init(initialState: State = State(todos: [], addTodoComplete: nil)) {
        self.initialState = initialState
    }
}

extension TodoReactor {

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .enterView:
            return Observable.create { observer in
                let db = Firestore.firestore()
                
                // Firebase의 firestore에서 todos collection에 있는 모든 문서를 가지고 온다
                db.collection("todos").getDocuments { query, error in
                    if let error = error {
                        observer.onError(error)
                    } else {
                        var todos: [Todo] = [Todo(id: "1", title: "dfdf", description: "", createdAt: "", isCompleted: false)]
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
            } // .enterView
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
                observer.onNext(Mutation.addTodo(true, todo))
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
        case .fetchTodos(let todos):
            newState.todos = todos
        case let .addTodo(todoComplete, todo):
            if todoComplete {
                print(#fileID, #function, #line, "- data 추가성공⭐️")
                newState.todos.append(todo)
                newState.addTodoComplete = todoComplete
            }
        case .addTodoSample(let check):
            print(#fileID, #function, #line, "- todo 들어옴")
        }
        
        return newState
    }
}
