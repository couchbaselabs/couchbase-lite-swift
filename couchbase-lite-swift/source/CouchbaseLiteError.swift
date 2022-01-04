//
//  CouchbaseLiteError.swift
//  CouchbaseLiteSwift
//
//  Copyright (c) 2022 Couchbase, Inc All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import CouchbaseLite

internal enum CouchbaseLiteError: Error {
    case cblError(Int, String)
    case posixError (Int, String)
    case sqliteError (Int, String)
    case fleeceError (Int, String)
    case networkError (Int, String)
    case webSocketError (Int, String)
}

extension CouchbaseLiteError {
    static func convertError(_ e: CBLError) -> CouchbaseLiteError {
        // code
        precondition(e.code != 0)
        let code = Int(e.code)
        
        // message
        var ee = e
        let flMessage = CBLError_Message(&ee)
        let flMessagePointer = flMessage.buf.assumingMemoryBound(to: UInt8.self)
        let message = String(cString: flMessagePointer)
        
        switch e.domain {
        case .cblDomain: return .cblError(code, message)
        case .cblsqLiteDomain: return .sqliteError(code, message)
        case .cblFleeceDomain: return .fleeceError(code, message)
        case .cblposixDomain: return .posixError(code, message)
        case .cblNetworkDomain: return .networkError(code, message)
        case .cblWebSocketDomain: return .webSocketError(code, message)
        default: return .cblError(Int(CBLErrorCode.unexpectedError.rawValue), message)
        }
    }
}
