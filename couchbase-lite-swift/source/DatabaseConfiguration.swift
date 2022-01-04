//
//  DatabaseConfiguration.swift
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


/// Configuration for opening a database.
public struct DatabaseConfiguration {
    
    /// Path to the directory to store the database in.
    public var directory: String = DatabaseConfiguration.defaultDirectory()
    
    #if COUCHBASE_ENTERPRISE
    /// The key to encrypt the database with.
    public var encryptionKey: EncryptionKey?
    #endif
    
    /// Initializes a DatabaseConfiguration's builder with default values.
    public init() {
        self.init(config: nil)
    }
    
    /// Initializes a DatabaseConfiguration's builder with the configuration object.
    public init(config: DatabaseConfiguration?) {
        if let c = config {
            self.directory = c.directory
            #if COUCHBASE_ENTERPRISE
            self.encryptionKey = c.encryptionKey
            #endif
        }
    }
}

// MARK: -- Internal

internal extension DatabaseConfiguration {
    func toCBL() -> CBLDatabaseConfiguration {
        directory.withCString { cDirectory in
            let _dir = FLSlice(buf: cDirectory, size: directory.count)
#if COUCHBASE_ENTERPRISE
            if let encryptionKey = encryptionKey {
                return CBLDatabaseConfiguration(directory: _dir, encryptionKey: encryptionKey.toCBL())
            }
#endif
            var config = CBLDatabaseConfiguration_Default()
            config.directory = _dir
            return config
        }
    }
}

// MARK: -- Private

fileprivate extension DatabaseConfiguration {
    static func defaultDirectory() -> String {
#if os(tvOS)
        // Apple TV only allows apps to store data in the Caches directory
        let dirPaths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
#else
        let dirPaths = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)
#endif
        guard var path = dirPaths.first else {
            fatalError("Application directory path doesn't exists!")
        }
#if !os(iOS)
        print("NOT TARGET_OS_IPHONE -------> \(path)")
        guard let bundleID = Bundle.main.bundleIdentifier else {
            // default for non-apps
            return FileManager.default.currentDirectoryPath
        }
        
        path.append(contentsOf: "/\(bundleID)")
#endif
        return path.appending("/CouchbaseLite")
    }
}
