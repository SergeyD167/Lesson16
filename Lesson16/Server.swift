//
//  Server.swift
//  Lesson16
//
//  Created by Сергей Дятлов on 03.08.2024.
//

import Foundation
import Network

protocol ServerProtocol {
    func addClient(_ connection: NWConnection)
    func synchronizeResults() async
}

class Server: ServerProtocol {
    private var clients: [UUID: ConnectionWrapper] = .init()
    private var results: [UUID: Data] = .init()
    private let queue = DispatchQueue(label: "ServerQueue")
    
    //Добавление нового клиента
    func addClient(_ connection: NWConnection) {
        let id = UUID()
        let wrappedConnection = ConnectionWrapper(id: id, connection: connection)
        clients[id] = wrappedConnection
        Task {
            await setupReceive(on: wrappedConnection)
        }
    }
    
    //Настройка приема данных
    private func setupReceive(on wrapper: ConnectionWrapper) async {
        while true {
            do {
                let (data, _, isComplete, error): (Data?, NWConnection.ContentContext?, Bool, Error?) = try await withCheckedThrowingContinuation { continuation in
                    wrapper.connection.receive(
                        minimumIncompleteLength: 1,
                        maximumLength: 65536
                    ) { data, context, isComplete, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else {
                            continuation.resume(returning: (data, context, isComplete, error))
                        }
                    }
                }
                
                if let data = data, !data.isEmpty {
                    await handleReceivedData(data, from: wrapper)
                }
                
                if isComplete {
                    removeClient(wrapper.id)
                    break
                }
                
                if let error = error {
                    await handleError(error, for: wrapper)
                    break
                }
                
            } catch {
                await handleError(error, for: wrapper)
                break
            }
        }
    }
    
    //Обработка полученных данных и синхронизация результатов
    private func handleReceivedData(_ data: Data, from wrapper: ConnectionWrapper) async {
        results[wrapper.id] = data
        
        // Распределяем задачи (или данные) для обработки
        await distributeTask(data)
        
        // Обновляем результаты
        await synchronizeResults()
    }
    
    //Асинхронное распределение задач
    private func distributeTask(_ task: Data) async {
        await withTaskGroup(of: Void.self) { group in
            for (_, wrapper) in clients {
                group.addTask {
                    wrapper.connection.send(content: task, completion: .contentProcessed({ _ in }))
                }
            }
        }
    }
    
    //Обработка ошибок
    private func handleError(_ error: Error, for wrapper: ConnectionWrapper) async {
        print("Error: \(error.localizedDescription)")
    }
    
    //Удаление клиента
    private func removeClient(_ id: UUID) {
        clients.removeValue(forKey: id)
        results.removeValue(forKey: id)
    }
    
    //Синхронизация результатов
    func synchronizeResults() async {
        print("Synchronizing results")
        for (clientId, result) in results {
            print("Client \(clientId) result: \(result)")
        }
    }
}

