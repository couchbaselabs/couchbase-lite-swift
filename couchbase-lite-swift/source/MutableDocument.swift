//
//  MutableDocument.swift
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

/// A mutable version of the Document.
public struct MutableDocument : DocumentProtocol, _DocumentProtocol {
    public var id: String {
        return getID(self._cbldoc)
    }
    
    public var revisionID: String? {
        return getRevisionID(self._cbldoc)
    }
    
    public var sequence: UInt64 {
        return CBLDocument_Sequence(self._cbldoc)
    }
    
    // MARK: Initializers
    
    /// Initializes a new MutableDocument object with a new random UUID.
    /// The created document will be saved into a database when you call
    /// the Database's save() method with the document object given.
    public init() {
        self._cbldoc = CBLDocument_Create()
    }
    
    /// Initializes a new MutableDocument object with the given ID.
    /// If a nil ID value is given, the document will be created with a new
    /// random UUID. The created document will be saved into a database when
    /// you call the Database's save() method with the document object given.
    ///
    /// - Parameter id: The document ID.
    public init(id: String?) {
        if let id = id {
            id.withCString { cIdentifier in
                let docID = FLSlice(buf: cIdentifier, size: id.count)
                self._cbldoc = CBLDocument_CreateWithID(docID)
            }
        } else {
            self.init()
        }
    }
    
    /// Initializes a new MutableDocument object with a new random UUID and
    /// the data. Allowed data value types are Array, ArrayObject, Blob, Date,
    /// Dictionary, DictionaryObject, NSNull, Number types, and String.
    /// The Arrays and Dictionaries must contain only the above types.
    /// The created document will be saved into a database when you call the
    /// Database's save() method with the document object given.
    ///
    /// - Parameter data: The data.
    public init(data: Dictionary<String, Any>) {
        self.init()
        setData(data)
    }
    
    /// Initializes a new MutableDocument object with the JSON data.
    ///
    /// - Parameters:
    ///   - json: The JSON string with data.
    /// - Throws: An error on a failure.
    public init(json: String) throws {
        self.init()
        try setJSON(json)
    }
    
    /// Initializes a new MutableDocument object with a given ID and the data.
    /// If a nil ID value is given, the document will be created with a new
    /// random UUID. Allowed data value types are Array, ArrayObject, Blob, Date,
    /// Dictionary, DictionaryObject, NSNull, Number types, and String.
    /// The Arrays and Dictionaries must contain only the above types.
    /// The created document will be saved into a database when you call the
    /// Database's save() method with the document object given.
    ///
    /// - Parameters:
    ///   - id: The document ID.
    ///   - data: The dictionary object.
    public init(id: String?, data: Dictionary<String, Any>) {
        self.init(id: id)
        setData(data)
    }
    
    /// Initializes a new MutableDocument object with the given ID and the JSON data.  If a
    /// nil ID value is given, the document will be created with a new random UUID.
    ///
    /// - Parameters:
    ///   - id: The document ID.
    ///   - json: The JSON string with data.
    /// - Throws: An error on a failure.
    public init(id: String?, json: String) throws {
        self.init(id: id)
        try setJSON(json)
    }
    
    // MARK: Private
    
    private(set) var _cbldoc: OpaquePointer
    
    private func setJSON(_ json: String) throws {
        try json.withCString { cJSON in
            let fleeceJSON = FLSlice(buf: cJSON, size: json.count)
            var err = CBLError()
            guard CBLDocument_SetJSON(self._cbldoc, fleeceJSON, &err) else {
                throw CouchbaseLiteError.convertError(err)
            }
        }
    }
    
    private func setData(_ data: Dictionary<String, Any>) {
        // FIXME: Implement convertion (Swift Dictionary <-> Fleece Dictionary)
    }
}
