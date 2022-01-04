//
//  Document.swift
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

public protocol DocumentProtocol {
    /// The document's ID.
    var id          : String    { get }
    
    /// The ID representing a document’s revision.
    var revisionID  : String?   { get }
    
    /// Sequence number of the document in the database.
    /// This indicates how recently the document has been changed: every time any document is updated,
    /// the database assigns it the next sequential sequence number. Thus, if a document's `sequence`
    /// property changes that means it's been changed (on-disk); and if one document's `sequence`
    /// is greater than another's, that means it was changed more recently.
    var sequence    : UInt64    { get }
}

internal extension DocumentProtocol {
    func getID(_ doc: OpaquePointer) -> String {
        let fleeceID = CBLDocument_ID(doc)
        let idRawPointer = fleeceID.buf.assumingMemoryBound(to: UInt8.self)
        return String(cString: idRawPointer)
    }
    
    func getRevisionID(_ doc: OpaquePointer) -> String? {
        let fRevID = CBLDocument_RevisionID(doc)
        let revIDPointer = fRevID.buf.assumingMemoryBound(to: UInt8.self)
        return String(cString: revIDPointer)
    }
}

internal protocol _DocumentProtocol {
    var _cbldoc: OpaquePointer { get }
}

/// Couchbase Lite document. The Document is immutable.
public struct Document: DocumentProtocol, _DocumentProtocol {
    public var id: String {
        return getID(self._cbldoc)
    }
    
    public var revisionID: String? {
        return getRevisionID(self._cbldoc)
    }
    
    public var sequence: UInt64 {
        return CBLDocument_Sequence(_cbldoc)
    }
    
    // MARK: Private
    private(set) var _cbldoc: OpaquePointer
}

internal extension Document {
    init(_ doc: OpaquePointer) {
        _cbldoc = doc
    }
}
