//
//  ViewModel.swift
//  Lesson16
//
//  Created by Сергей Дятлов on 03.08.2024.
//

import SwiftUI
import Network

class ViewModel: ObservableObject {
    private var server: ServerProtocol?
    private var client: ClientProtocol?
    
    @Published var serverStatus: String = "Server is offline"
    @Published var clientStatus: String = "Client is disconnected"
    @Published var receivedData: Data? = nil
    
    //Запуск сервера
    func startServer() {
        server = Server()
        serverStatus = "Server is online"
    }
    
    //Остановка сервера
    func stopServer() {
        server = nil
        serverStatus = "Server is offline"
    }
    
    //Подключение клиента
    func connectToServer() {
        client = Client(id: UUID(), host: "localhost", port: 8080)
        client?.onReceiveData = { [weak self] data in
            self?.receivedData = data
        }
        client?.connect()
        clientStatus = "Client is connected"
    }
    
    //Отключение клиента
    func disconnect() {
        client = nil
        clientStatus = "Client is disconnected"
    }
    
}
