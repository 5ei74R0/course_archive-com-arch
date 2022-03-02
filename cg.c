#include <omp.h>
#include <stdio.h>
#include <math.h>
#define MAX 1024
//#define MAX 384
#define EPS 1e-10

void main() {
	int i, j, k;
	int ss;
	int thread;
	float a[MAX][MAX], b[MAX], x[MAX], p[MAX], y[MAX], r[MAX];
	float alpha, alpha0, alpha1, beta, beta0;
	double ts1, ts2;
	double t;
	double remain;

// Initialize
	#pragma omp parallel for
	for (i = 0; i < MAX; i++)
		b[i] = 50.0+i;
	#pragma omp parallel for
	for (i = 0; i < MAX; i++)
		x[i] = 0;
	#pragma omp parallel for private(i)
	for (j = 0; j < MAX; j++) {
		for(i = 0; i < MAX; i++) {
			if(i == j)
				a[i][j] = 8.0;
			else
				a[i][j] = 5.0; 
		}
	}
	#pragma omp parallel for private(i)
	for (j = 0; j < MAX; j++) {
		y[j] = 0;
		for (i = 0; i< MAX; i++) 
			y[j] += a[i][j] * x[i];
	}
	#pragma omp parallel for
	for(i = 0; i < MAX; i++) {
		p[i] = b[i]- y[i];
		r[i] = p[i];
	}

	ts1 = omp_get_wtime();

	// Loop
	for(k=0; k<MAX; k++) {
		// A x p
		#pragma omp parallel for private(i)
		for (j=0; j<MAX; j++) {
			thread = omp_get_num_threads();
			y[j] = 0.0;
			for(i = 0; i < MAX; i++)
				y[j] += a[i][j] * p[i];
		}

		alpha0 = 0;
		alpha1 = 0;
		#pragma omp parallel for reduction(+:alpha0)
		for(i = 0; i<MAX; i++)
			alpha0 += p[i] * r[i];
		#pragma omp parallel for reduction(+:alpha1)
		for(i = 0; i<MAX; i++)
			alpha1 += p[i] * y[i];

		alpha = alpha0 / alpha1;
		#pragma omp parallel for
		for(i = 0;i < MAX;i++) 
			x[i] += alpha * p[i];
		#pragma omp parallel for
		for(i=0;i<MAX;i++) 
			r[i] -= alpha * y[i];

		beta0 = 0.0;
		#pragma omp parallel for reduction(+:beta0)
		for(i = 0; i < MAX;i++) 
			beta0 += r[i] * y[i];
		beta = -beta0 / alpha1;

		#pragma omp parallel for
		for(i = 0; i < MAX;i++) 
			p[i] = r[i] + beta * p[i];

		remain=0.0;
		#pragma omp parallel for reduction(+:remain)
		for(i = 0;i < MAX; i++) 
			remain += r[i] * r[i];
		printf("%d: %lf\n", k, remain);

		if (remain < EPS)
			break;
	}

	ts2 = omp_get_wtime();

	for(i=0;i<MAX;i++) 
		printf("%d: %f %f\n", i, x[i], r[i]);

	printf("Time:%lf thread:%d \n", ts2-ts1, thread);
}
