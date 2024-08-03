//
//  ContentView.swift
//  Lesson16
//
//  Created by Сергей Дятлов on 03.08.2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    Text("Server Status: \(viewModel.serverStatus)")
                    Button(action: {
                        viewModel.startServer()
                    }) {
                        Text("Start Server")
                    }
                    Button(action: {
                        viewModel.stopServer()
                    }) {
                        Text("Stop Server")
                    }
                }
                .padding()
                
                VStack {
                    Text("Client Status: \(viewModel.clientStatus)")
                    Button(action: {
                        viewModel.connectToServer()
                    }) {
                        Text("Connect to Server")
                    }
                    Button(action: {
                        viewModel.disconnect()
                    }) {
                        Text("Disconnect")
                    }
                    
                    if let receivedData = viewModel.receivedData {
                        Text("Received Data: \(receivedData)")
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                .padding()
            }
            .navigationTitle("Server & Client")
        }
    }
}


#Preview {
    ContentView()
}
