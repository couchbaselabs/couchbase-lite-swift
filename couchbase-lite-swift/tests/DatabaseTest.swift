//
//  CouchbaseLiteSwiftTests.swift
//  CouchbaseLiteSwiftTests
//
//  Created by Jayahari Vavachan on 11/17/21.
//

import XCTest
@testable import CouchbaseLiteSwift

class DatabaseTest: XCTestCase {
    
    var db: Database!
    
    override func setUpWithError() throws {
        let dir = NSTemporaryDirectory().appending("cbl_temp")
        if FileManager.default.fileExists(atPath: dir) {
            try! FileManager.default.removeItem(atPath: dir)
        }
        XCTAssertTrue(!FileManager.default.fileExists(atPath: dir))
        
        var config = DatabaseConfiguration()
        config.directory = dir
        print(dir)
        db = try Database(name: "test-db", config: config)
        XCTAssertEqual(db.count, 0)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testPath() throws {
        let dir = NSTemporaryDirectory().appending("cbl_temp/test")
        
        var config = DatabaseConfiguration()
        config.directory = dir
        let db = try Database(name: "test-db", config: config)
        
        guard let path = db.path else {
            XCTFail("Path empty!")
            return
        }
        XCTAssert(path.contains(dir))
        XCTAssert(path.contains(db.name))
    }
    
    func testEmptyDoc() throws {
        let doc = db.document(withID: "unknown-doc")
        XCTAssertNil(doc)
    }
}
