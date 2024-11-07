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
    
    init(initialState: State = State(todos: [])) {
        self.initialState = initialState
    }
}

extension TodoReactor {

    func mutate(action: Action) -> Observable<Mutation> {
        /*
         // 의도한 결과가 나오지 않는 코드이다.
         // 이렇게 되면 firebase에서 데이터를 가져오는 부분이 observable.just보다 나중에 실행된다
         // 즉, 실행순서가 Observable.just -> db.collection.getDocuments를 통해서 todos.append가 된다.
         // 결과적으로 firebase에서 가져온 데이터가 Mutation.fetchTodos(todos)에서 todos에 담겨서 나가지 않게 된다.
         // 이유: Observable.just는 생성된 즉시 값을 방출하기 때문이다
         // 대처방안: 즉시 값을 방출하는 것이 아니라 비동기 작업이 완료된 후에 데이터를 방출하도록 설계하기 위해서는 어떤 Observable을 사용해야 할까? -> Observable.create를 사용하면 된다.
        switch action {
        case .fetchTodos:
            var todos: [Todo] = [Todo(id: "1", title: "dfdf", description: "", createdAt: "", isCompleted: false)]
            let db = Firestore.firestore()
            
            db.collection("todos").getDocuments { query, error in
                if let error = error {
                    print(#fileID, #function, #line, "- error ?1⭐️: \(error)")
                } else {
                    guard let query = query else { return }
                    for doc in query.documents {
                        do {
                            let todo = try doc.data(as: Todo.self)
                            print(#fileID, #function, #line, "- todo: \(todo)")
                            todos.append(todo)
                        } catch {
                            print(#fileID, #function, #line, "- error ?2⭐️: \(error)")
                        }
                        
                    }
                }
            }
            return Observable.just(Mutation.fetchTodos(todos))
        }
         */
        
        switch action {
        case .fetchTodos:
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
            }
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
