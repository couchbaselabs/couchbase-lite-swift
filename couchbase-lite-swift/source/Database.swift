//
//  Database.swift
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

/// Concurruncy control type used when saving or deleting a document.
///
/// - lastWriteWins: The last write operation will win if there is a conflict.
/// - failOnConflict: The operation will fail if there is a conflict.
public enum ConcurrencyControl: UInt8 {
    case lastWriteWins = 0
    case failOnConflict
}

/// Maintenance Type used when performing database maintenance
///
/// - compact: Compact the database file and delete unused attachments.
/// - reindex: (Volatile API) Rebuild the entire database's indexes.
/// - integrityCheck: (Volatile API) Check for the database’s corruption. If found, an error will be returned.
/// - optimize: Quickly updates database statistics that may help optimize queries that have been run by this Database since it was opened
/// - fullOptimize: Fully scans all indexes to gather database statistics that help optimize queries.
public enum MaintenanceType: UInt8 {
    case compact = 0
    case reindex
    case integrityCheck
    case optimize
    case fullOptimize
}

/// A Couchbase Lite database.
public final class Database {
    
    /// The database's name.
    public let name: String!
    
    /// The database configuration.
    public let config: DatabaseConfiguration!
    
    /// The database's path. If the database is closed or deleted, nil value will be returned.
    public var path: String? {
        let fleecePath = CBLDatabase_Path(_cbldb)
        let pathRawPointer = fleecePath.buf.assumingMemoryBound(to: UInt8.self)
        return String(cString: pathRawPointer)
    }
    
    /// The total numbers of documents in the database.
    public var count: UInt64 {
        return CBLDatabase_Count(_cbldb)
    }
    
    // MARK: Functions
    
    /// Initializes a Couchbase Lite database with a given name and database options.
    /// If the database does not yet exist, it will be created, unless the `readOnly` option is used.
    ///
    /// - Parameters:
    ///   - name: The name of the database.
    ///   - config: The database options, or nil for the default options.
    /// - Throws: An error when the database cannot be opened.
    public init(name: String, config: DatabaseConfiguration? = nil) throws {
        Database.checkFileLogging();
        self.config = DatabaseConfiguration(config: config)
        self.name = name
        var err = CBLError()
        self._cbldb = name.withCString { cName in
            let _name = FLSlice(buf: cName, size: name.count)
            
            var _config: CBLDatabaseConfiguration
            if let config = config {
                _config = config.toCBL()
            } else {
                _config = CBLDatabaseConfiguration_Default()
            }
            
            guard let db = CBLDatabase_Open(_name, &_config, &err) else {
                fatalError("Error opening database \(err)")
            }
            return db
        }
    }
    
    /// Gets a Document object with the given ID.
    public func document(withID id: String) -> Document? {
        id.withCString { cIdentifier in
            let _id = FLSlice(buf: cIdentifier, size: id.count)
            
            var err = CBLError()
            if let doc = CBLDatabase_GetDocument(self._cbldb, _id, &err) {
                return Document(doc)
            }
            
            if err.code != 0 {
                fatalError("Error while getting document \(err)")
            }
            
            return nil
        }
    }
    
    // FIXME: Add 'subscript(key: String) -> DocumentFragment'
    
    /// Saves a document to the database. When write operations are executed
    /// concurrently, the last writer will overwrite all other written values.
    /// Calling this function is the same as calling the saveDocument(document,
    /// concurrencyControl) function with ConcurrencyControl.lastWriteWins.
    ///
    /// - Parameter document: The document.
    /// - Throws: An error on a failure.
    public func saveDocument(_ document: MutableDocument) throws {
//        try _impl.save(document._impl as! CBLMutableDocument)
    }
    
    //MARK: Private
    
    private let _cbldb: OpaquePointer
}

internal extension Database {
    static func checkFileLogging() {
        // TODO: check the log file
    }
}
