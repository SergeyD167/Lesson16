//
//  Client.swift
//  Lesson16
//
//  Created by Сергей Дятлов on 03.08.2024.
//

import Foundation
import Network

protocol ClientProtocol {
    var onReceiveData: ((Data) -> Void)? { get set }
    
    func connect()
}

class Client: ClientProtocol {
    private let id: UUID
    private let connection: NWConnection
    private let queue = DispatchQueue(label: "ClientQueue")
    
    var onReceiveData: ((Data) -> Void)?
    
    init(id: UUID, host: NWEndpoint.Host, port: NWEndpoint.Port) {
        self.id = id
        self.connection = NWConnection(host: host, port: port, using: .tcp)
    }
    
    //Метод для установления соединения
    func connect() {
        connection.stateUpdateHandler = self.stateDidChange(to:)
        connection.start(queue: queue)
        Task {
            await receiveData()
        }
    }
    
    //Обработчик изменения состояния соединения
    private func stateDidChange(to state: NWConnection.State) {
        switch state {
        case .ready:
            print("Client \(id) connected")
        case .failed(let error):
            Task {
                await handleError(error)
            }
        default:
            break
        }
    }
    
    //Метод для приема данных
    private func receiveData() async {
        while true {
            do {
                let (_, _, isComplete, error): (Data?, NWConnection.ContentContext?, Bool, Error?) = try await withCheckedThrowingContinuation { continuation in
                    connection.receive(
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
                if isComplete {
                    connection.cancel()
                    break
                }
                if let error = error {
                    await handleError(error)
                    break
                }
            } catch {
                await handleError(error)
                break
            }
        }
    }
    
    //Обработка полученных данных
    private func handleReceivedData(_ data: Data) async {
        onReceiveData?(data)
        
        await sendResult(data)
    }
    
    //Отправка результатов обратно серверу
    private func sendResult(_ result: Data) async {
        connection.send(content: result, completion: .contentProcessed({ _ in }))
    }
    
    //Обработка ошибок
    private func handleError(_ error: Error) async {
        print("Error: \(error.localizedDescription)")
    }
}
