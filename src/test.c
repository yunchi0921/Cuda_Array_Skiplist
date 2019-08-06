#include<stdio.h>

int main(){
	int n_r1,n_r2;
	double time_r1,time_r2;

	FILE *fp_r1=fopen("gpu.txt","r");
	FILE *fp_r2=fopen("cpu.txt","r");
	FILE *fp_w=fopen("gpu_nor.txt","w");

	if(!fp_r1) return -1;
	if(!fp_r2) return -1;
	if(!fp_w) return -1;

	while(!feof(fp_r2)){
	fscanf(fp_r1,"%d %lf",&n_r1,&time_r1);
	fscanf(fp_r2,"%d %lf",&n_r2,&time_r2);
	fprintf(fp_w,"%d		%lf\n",n_r1,time_r2/time_r1);
	}
	fclose(fp_r1);
	fclose(fp_r2);
	fclose(fp_w);

}
