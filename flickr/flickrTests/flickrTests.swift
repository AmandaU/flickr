//
//  flickrTests.swift
//  flickrTests
//
//  Created by Amanda Baret on 2022/11/24.
//

import XCTest
import Combine

final class flickrTests: XCTestCase {
    private var cancellables: Set<AnyCancellable> = []
    var error = ""
   
    var store: ImagesStore?
   
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testGetPhotosSuccess() {
        let validation = expectation(description: "FullFill")
        
        guard let apiKey = Bundle.main.infoDictionary?["API_KEY"] as? String else {
            XCTAssertTrue(false)
            return
        }
     
        store = ImagesStore(apiKey: apiKey)
        store?.photosFetched.sink { [weak self] error in
                   validation.fulfill()
               }.store(in: &cancellables)

        self.waitForExpectations(timeout: 20) { error in
            XCTAssertTrue(!(self.store?.images.isEmpty ?? true))
        }
    }

    func testGetPhotosFailureWithBadApiKey() {
        let validation = expectation(description: "FullFill")
        store = ImagesStore(apiKey: nil)
        store?.photosFetched.sink { [weak self] error in
            self?.error = error ?? ""
            validation.fulfill()
        }.store(in: &cancellables)

        self.waitForExpectations(timeout: 20) { error in
            XCTAssertFalse(self.error.isEmpty)
        }
    }
}
