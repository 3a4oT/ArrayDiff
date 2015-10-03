//
//  ArrayDiffTests.swift
//  ArrayDiffTests
//
//  Created by Adlai Holler on 10/1/15.
//  Copyright © 2015 Adlai Holler. All rights reserved.
//

import XCTest
@testable import ArrayDiff

class ArrayDiffTests: XCTestCase {
	
    func testACommonCase() {
		let old = "a b c d e".componentsSeparatedByString(" ")
		let new = "m a b f".componentsSeparatedByString(" ")
		
		let allFirstIndexes = NSIndexSet(indexesInRange: NSMakeRange(0, old.count))
		
		let expectedRemoves = NSMutableIndexSet()
		expectedRemoves.addIndexesInRange(NSMakeRange(2, 3))

		let expectedInserts = NSMutableIndexSet()
		expectedInserts.addIndex(0)
		expectedInserts.addIndex(3)
		

		let expectedCommonObjects = "a b".componentsSeparatedByString(" ")

		let diff = old.diff(new)
		
		XCTAssertEqual(expectedInserts, diff.insertedIndexes)
		XCTAssertEqual(expectedRemoves, diff.removedIndexes)
		XCTAssertEqual(expectedCommonObjects, old[diff.commonIndexes])
		
		let removedPlusCommon = NSMutableIndexSet(indexSet: diff.removedIndexes)
		removedPlusCommon.addIndexes(diff.commonIndexes)
		XCTAssertEqual(removedPlusCommon, allFirstIndexes)
		
		var reconstructed = old
		reconstructed.removeAtIndexes(diff.removedIndexes)
		reconstructed.insertElements(new[diff.insertedIndexes], atIndexes: diff.insertedIndexes)
		XCTAssertEqual(reconstructed, new)
    }
	
	func testNewIndexForOldIndex() {
		let old = "a b c d e".componentsSeparatedByString(" ")
		let new = "m a b f".componentsSeparatedByString(" ")
		let diff = old.diff(new)
		let newIndexes: [Int?] = (0..<old.count).map { diff.newIndexForOldIndex($0) }
		let expectedNewIndexes: [Int?] = [1, 2, nil, nil, nil]
		XCTAssert(newIndexes.elementsEqual(expectedNewIndexes, isEquivalent: { $0 == $1 }), "Expected newIndexes to be \(expectedNewIndexes), got \(newIndexes)")
	}
	
	func testNewIndexForOldIndexWithInsertTail() {
		let old = "a b c d".componentsSeparatedByString(" ")
		let new = "a b c e f g j h d".componentsSeparatedByString(" ")
		let diff = old.diff(new)
		let newIndexes: [Int?] = (0..<old.count).map { diff.newIndexForOldIndex($0) }
		let expectedNewIndexes: [Int?] = [0, 1, 2, 8]
		XCTAssert(newIndexes.elementsEqual(expectedNewIndexes, isEquivalent: { $0 == $1 }), "Expected newIndexes to be \(expectedNewIndexes), got \(newIndexes)")
	}
	
	func testOldIndexForNewIndex() {
		let old = "a b c d e".componentsSeparatedByString(" ")
		let new = "m a b f".componentsSeparatedByString(" ")
		let diff = old.diff(new)
		let oldIndexes: [Int?] = (0..<new.count).map { diff.oldIndexForNewIndex($0) }
		let expectedOldIndexes: [Int?] = [nil, 0, 1, nil]
		XCTAssert(oldIndexes.elementsEqual(expectedOldIndexes, isEquivalent: { $0 == $1 }), "Expected oldIndexes to be \(expectedOldIndexes), got \(oldIndexes)")
	}
	
	func testCustomEqualityOperator() {
		let old = "a b c d e".componentsSeparatedByString(" ")
		let oldWrapped = old.map { TestType(value: $0) }
		let new = "m a b f".componentsSeparatedByString(" ")
		let newWrapped = new.map { TestType(value: $0) }
		let diff = oldWrapped.diff(newWrapped, elementsAreEqual: TestType.customEqual)
		var reconstructed = oldWrapped
		reconstructed.removeAtIndexes(diff.removedIndexes)
		reconstructed.insertElements(newWrapped[diff.insertedIndexes], atIndexes: diff.insertedIndexes)
		let reconstructedUnwrapped = reconstructed.map { $0.value }
		XCTAssertEqual(reconstructedUnwrapped, new)
	}
}

struct TestType {
	var value: String
	
	static func customEqual(t0: TestType, t1: TestType) -> Bool {
		return t0.value == t1.value
	}
}