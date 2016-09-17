//
//  SparseMatrix.m
//  SparseObjects
//
//  Created by Matt on 9/17/16.
//  Copyright © 2016 Matt Rajca. All rights reserved.
//

#import "SparseMatrix.h"

#import <Accelerate/Accelerate.h>

#if defined(__LP64__) && __LP64__
#define sparse_pointer_storage double
#define sparse_pointer_storage_int uint64_t
#define sparse_pointer_matrix sparse_matrix_double
#define sparse_pointer_matrix_create sparse_matrix_create_double
#define sparse_pointer_matrix_insert sparse_insert_entry_double
#define sparse_pointer_matrix_extract sparse_extract_sparse_row_double
#else
#define sparse_pointer_storage float
#define sparse_pointer_storage_int uint32_t
#define sparse_pointer_matrix sparse_matrix_float
#define sparse_pointer_matrix_create sparse_matrix_create_float
#define sparse_pointer_matrix_insert sparse_insert_entry_float
#define sparse_pointer_matrix_extract sparse_extract_sparse_row_float
#endif

@implementation SparseMatrix {
	sparse_pointer_matrix _matrix;
}

_Static_assert(sizeof(NSInteger) <= sizeof(sparse_dimension), "Our sizes will be truncated");
_Static_assert(sizeof(NSInteger) <= sizeof(sparse_index), "Our indices will be truncated");
_Static_assert(sizeof(void *) <= sizeof(sparse_pointer_storage), "Our pointers will be truncated");

- (instancetype)initWithRows:(NSInteger)rows columns:(NSInteger)columns
{
	if (!(self = [super init])) {
		return nil;
	}

	_matrix = sparse_pointer_matrix_create((sparse_dimension)rows, (sparse_dimension)columns);

	return self;
}

- (void)dealloc
{
	const NSInteger rows = (NSInteger)sparse_get_matrix_number_of_rows(_matrix);
	const sparse_dimension columns = sparse_get_matrix_number_of_columns(_matrix);
	sparse_pointer_storage *const columnSpace = malloc(columns * sizeof(sparse_pointer_storage));
	sparse_index *const indices = malloc(columns * sizeof(sparse_index));

	for (NSInteger row = 0; row < rows; row++) {
		if (sparse_get_matrix_nonzero_count_for_row(_matrix, row) > 0) {
			sparse_index columnEnd = 0;
			sparse_extract_sparse_row_double(_matrix, row, 0, &columnEnd, columns, columnSpace, indices);

			for (NSInteger column = 0; column < columns; column++) {
				[(id)((sparse_pointer_storage_int)columnSpace[column]) release];
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
	sparse_pointer_matrix_insert(_matrix, (sparse_pointer_storage)((sparse_pointer_storage_int)[object retain]), (sparse_index)row, (sparse_index)column);
}

- (id)objectAtRow:(NSInteger)row column:(NSInteger)column
{
	sparse_pointer_storage value = 0;
	sparse_index end = 0;
	sparse_index index = 0;
	sparse_pointer_matrix_extract(_matrix, (sparse_index)row, (sparse_index)column, &end, 1, &value, &index);

	return [[(id)((sparse_pointer_storage_int)value) retain] autorelease];
}

- (void)removeObjectAtRow:(NSInteger)row column:(NSInteger)column
{
	// Doesn't use -objectAtRow... for retrieval to avoid autorelease.
	sparse_pointer_storage value = 0;
	sparse_index end = 0;
	sparse_index index = 0;
	sparse_pointer_matrix_extract(_matrix, (sparse_index)row, (sparse_index)column, &end, 1, &value, &index);
	[(id)((sparse_pointer_storage_int)value) release];

	sparse_pointer_matrix_insert(_matrix, 0, (sparse_index)row, (sparse_index)column);
}

@end
