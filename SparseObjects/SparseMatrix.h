//
//  SparseMatrix.h
//  SparseObjects
//
//  Created by Matt on 9/17/16.
//  Copyright © 2016 Matt Rajca. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SparseMatrix : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithRows:(NSInteger)rows columns:(NSInteger)columns;

- (void)setObject:(id)object atRow:(NSInteger)row column:(NSInteger)column;
- (nullable id)objectAtRow:(NSInteger)row column:(NSInteger)column;

- (void)removeObjectAtRow:(NSInteger)row column:(NSInteger)column;

@end

NS_ASSUME_NONNULL_END
