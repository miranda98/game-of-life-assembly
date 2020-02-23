#include <stdio.h>
#include <stdlib.h>

#include "board1.h"

int neighbours (int i, int j);
char decideCell (int old, int nn);
void copyBackAndShow (void);

int main (void)
{
	int maxiters;
	printf ("# Iterations: ");
	scanf ("%d", &maxiters);

	for (int n = 1; n <= maxiters; n++) {
		for (int i = 0; i < N; i++) {
			for (int j = 0; j < N; j++) {
				// Get the number of alive neighbours for that cell
				int nn = neighbours (i, j);

				// NOTE: you should be testing neighbours separately to decideCell
				// ie. printing out the output of neighbours is a good way to work on neighbours/
				// and debugg
				// eg.  ;

				// Given the number of alive neighbours for a cell
				// What is the new value of that cell
				// Here, we are implementing the rules of the Game of Life

				// Decidecell returns the cells future value (alive or dead)
				// Load that value into memory @newboard[i][j]
				// NOTE NEWBOARD IS A DIFFERENT MEMORY BLOCK TO THE CURRENT BOARD
				newboard[i][j] = decideCell (board[i][j], nn);

				// Again, you could break down the above problem by
				// first: make decideCell just return 1 and test transforming and entire empty board
				// into a completely alive board
				// or maybe make decideCell return alternating 1 and 0's

				// And then when you know you can correctly allocate new values
				// into their slots, then implement decideCell
				printf("%d", nn);
			}
			printf("\n");
		}
		printf ("=== After iteration %d ===\n", n);
		// Load the newboard into the current board
		copyBackAndShow ();
	}

	return 0;
}

char decideCell (int old, int nn)
{
	char ret;
	// if the current cell is alive
	if (old == 1) {
		// it has less than 2 alive neighbours
		// and hence should die to under population
		if (nn < 2)
			ret = 0;

		// it has 2 or 3 alive neighbours
		// and hence it should live on
		else if (nn == 2 || nn == 3)
			ret = 1;

		// else, it has more than 3 alive neighbours
		// and hence should die to overpopulation
		else
			ret = 0;

	// Then the current cell is dead
	} else if (nn == 3) {
		// it has 3 alive neighbours
		// and hence should be reborn
		ret = 1;
	} else {
		// else it doesnt have exactly 3 alive neighbours,
		// and should stay dead
		ret = 0;
	}

	// Return the cell's future value
	// store it in the $v0 register
	return ret;
}

int neighbours (int i, int j)
{
	int nn = 0;
	for (int x = -1; x <= 1; x++) {
		for (int y = -1; y <= 1; y++) {
			// What if it's on a edge
			if (i + x < 0 || i + x > N - 1) continue;
			if (j + y < 0 || j + y > N - 1) continue;

			// This is pointing to the cell you are investigating
			// A cell doesnt count itself as a neighbour
			if (x == 0 && y == 0) continue;

			// So at this point, we are dealing with 
			// real neighbour cells
			// is it alive? if so, count it
			if (board[i + x][j + y] == 1) nn++;
		}
	}
	return nn;
}

void copyBackAndShow (void)
{
	for (int i = 0; i < N; i++) {
		for (int j = 0; j < N; j++) {
			// load all the values you found from newboard
			// into the current board
			board[i][j] = newboard[i][j];

			// then print out the current board
			if (board[i][j] == 0)
				putchar ('.');
			else
				putchar ('#');
		}
		putchar ('\n');
	}
}
