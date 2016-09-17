//
//  SparseMatrix.m
//  SparseObjects
//
//  Created by Matt on 9/17/16.
//  Copyright © 2016 Matt Rajca. All rights reserved.
//

#import "SparseMatrix.h"

#import <Accelerate/Accelerate.h>

@implementation SparseMatrix {
	sparse_matrix_double _matrix;
}

_Static_assert(sizeof(NSInteger) <= sizeof(sparse_dimension), "Our sizes will be truncated");
_Static_assert(sizeof(NSInteger) <= sizeof(sparse_index), "Our indices will be truncated");
_Static_assert(sizeof(void *) <= sizeof(double), "Our pointers will be truncated");

- (instancetype)initWithRows:(NSInteger)rows columns:(NSInteger)columns
{
	if (!(self = [super init])) {
		return nil;
	}

	_matrix = sparse_matrix_create_double((sparse_dimension)rows, (sparse_dimension)columns);

	return self;
}

- (void)dealloc
{
	const NSInteger rows = (NSInteger)sparse_get_matrix_number_of_rows(_matrix);
	const sparse_dimension columns = sparse_get_matrix_number_of_columns(_matrix);
	double *const columnSpace = malloc(columns * sizeof(double));
	sparse_index *const indices = malloc(columns * sizeof(sparse_index));

	for (NSInteger row = 0; row < rows; row++) {
		if (sparse_get_matrix_nonzero_count_for_row(_matrix, row) > 0) {
			sparse_index columnEnd = 0;
			sparse_extract_sparse_row_double(_matrix, row, 0, &columnEnd, columns, columnSpace, indices);

			for (NSInteger column = 0; column < columns; column++) {
				[(id)((uint64_t)columnSpace[column]) release];
			}
		}
	}

	free(columnSpace);
	free(indices);

	sparse_matrix_destroy(_matrix);

	[super dealloc];
}

- (void)setObject:(id)object atRow:(NSInteger)row column:(NSInteger)column
{
	sparse_insert_entry_double(_matrix, (double)((uint64_t)[object retain]), (sparse_index)row, (sparse_index)column);
}

- (id)objectAtRow:(NSInteger)row column:(NSInteger)column
{
	double value = 0;
	sparse_index end = 0;
	sparse_index index = 0;
	sparse_extract_sparse_row_double(_matrix, (sparse_index)row, (sparse_index)column, &end, 1, &value, &index);

	return [[(id)((uint64_t)value) retain] autorelease];
}

- (void)removeObjectAtRow:(NSInteger)row column:(NSInteger)column
{
	// Doesn't use -objectAtRow... for retrieval to avoid autorelease.
	double value = 0;
	sparse_index end = 0;
	sparse_index index = 0;
	sparse_extract_sparse_row_double(_matrix, (sparse_index)row, (sparse_index)column, &end, 1, &value, &index);
	[(id)((uint64_t)value) release];

	sparse_insert_entry_double(_matrix, 0, (sparse_index)row, (sparse_index)column);
}

@end
