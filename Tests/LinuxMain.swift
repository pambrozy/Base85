import XCTest

import Base85Tests

var tests = [XCTestCaseEntry]()
tests += Base85Tests.allTests()
XCTMain(tests)
