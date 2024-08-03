//
//  ExtensionNWConnection.swift
//  Lesson16
//
//  Created by Сергей Дятлов on 03.08.2024.
//

import Foundation
import Network

class ConnectionWrapper: Equatable, Hashable {
    let id: UUID
    let connection: NWConnection
    
    init(id: UUID, connection: NWConnection) {
        self.id = id
        self.connection = connection
    }
    
    static func == (lhs: ConnectionWrapper, rhs: ConnectionWrapper) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
