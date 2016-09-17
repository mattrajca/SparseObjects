//
//  SparseObjectsTests.m
//  SparseObjectsTests
//
//  Created by Matt on 9/17/16.
//  Copyright © 2016 Matt Rajca. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <SparseObjects/SparseObjects.h>

@interface Person : NSObject
@property (nonatomic, copy) NSString *name;
@end

@implementation Person

@end

@interface SparseObjectsTests : XCTestCase

@end

@implementation SparseObjectsTests

- (void)testMatrixOwnership {
	Person *person = [Person new];
	person.name = @"Steve";

	SparseMatrix *matrix = [[SparseMatrix alloc] initWithRows:2 columns:2];
	[matrix setObject:person atRow:1 column:1];
	[person release];

	XCTAssertEqual([matrix objectAtRow:1 column:1], person, @"The matrix did not retain the object");
	[matrix release];
}

- (void)testMatrixCleanup {
	Person *person = [Person new];
	person.name = @"Steve";

	SparseMatrix *matrix = [[SparseMatrix alloc] initWithRows:2 columns:2];
	[matrix setObject:person atRow:1 column:1];
	XCTAssertEqual(person.retainCount, 2);
	[matrix release];
	XCTAssertEqual(person.retainCount, 1);
	[person release];
}

- (void)testNonExistentAccess {
	SparseMatrix *matrix = [[SparseMatrix alloc] initWithRows:2 columns:2];
	XCTAssertNil([matrix objectAtRow:1 column:1]);
	[matrix release];
}

- (void)testHugeMatrix {
	Person *person = [Person new];
	person.name = @"Steve";

	const NSInteger side = 4096 * 10;
	SparseMatrix *matrix = [[SparseMatrix alloc] initWithRows:side columns:side];
	[matrix setObject:person atRow:1320 column:17];
	[person release];

	XCTAssertEqual([matrix objectAtRow:1320 column:17], person);
	[matrix release];
}

- (void)testRemoval {
	Person *person = [Person new];
	person.name = @"Steve";

	SparseMatrix *matrix = [[SparseMatrix alloc] initWithRows:2 columns:2];
	[matrix setObject:person atRow:1 column:1];
	[matrix removeObjectAtRow:1 column:1];
	XCTAssertEqual(person.retainCount, 1);
	[person release];

	XCTAssertNil([matrix objectAtRow:1 column:1]);
	[matrix release];
}

@end
