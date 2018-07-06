# docker-libsvm

[libsvm](https://github.com/cjlin1/libsvm), [liblinear](https://github.com/cjlin1/liblinear) docker image based alpine.

The following libsvm parallelizing patch is applied.
* [Q: How can I use OpenMP to parallelize LIBSVM on a multicore/shared-memory computer?](https://www.csie.ntu.edu.tw/~cjlin/libsvm/faq.html#f432)
* https://github.com/niam/libsvm_openmp_patch

```bash
docker build -t local/libsvm .
docker run -it --rm -v $(pwd):/code -w /code local/libsvm sh

$ type train svm-train
train is a tracked alias for /usr/local/bin/train
svm-train is a tracked alias for /usr/local/bin/svm-train

$ svm-train -h
Usage: svm-train [options] training_set_file [model_file]
options:
-s svm_type : set type of SVM (default 0)
	0 -- C-SVC		(multi-class classification)
	1 -- nu-SVC		(multi-class classification)
	2 -- one-class SVM
	3 -- epsilon-SVR	(regression)
	4 -- nu-SVR		(regression)
-t kernel_type : set type of kernel function (default 2)
	0 -- linear: u'*v
	1 -- polynomial: (gamma*u'*v + coef0)^degree
	2 -- radial basis function: exp(-gamma*|u-v|^2)
	3 -- sigmoid: tanh(gamma*u'*v + coef0)
	4 -- precomputed kernel (kernel values in training_set_file)
-d degree : set degree in kernel function (default 3)
-g gamma : set gamma in kernel function (default 1/num_features)
-r coef0 : set coef0 in kernel function (default 0)
-c cost : set the parameter C of C-SVC, epsilon-SVR, and nu-SVR (default 1)
-n nu : set the parameter nu of nu-SVC, one-class SVM, and nu-SVR (default 0.5)
-p epsilon : set the epsilon in loss function of epsilon-SVR (default 0.1)
-m cachesize : set cache memory size in MB (default 100)
-e epsilon : set tolerance of termination criterion (default 0.001)
-h shrinking : whether to use the shrinking heuristics, 0 or 1 (default 1)
-b probability_estimates : whether to train a SVC or SVR model for probability estimates, 0 or 1 (default 0)
-wi weight : set the parameter C of class i to weight*C, for C-SVC (default 1)
-v n: n-fold cross validation mode
-q : quiet mode (no outputs)

```

## Parallelizing libsvm example

```bash
$ wget 'http://www.csie.ntu.edu.tw/~cjlin/libsvmtools/datasets/binary/ijcnn1.bz2'
$ bzip2 -d ijcnn1.bz2

## 1 core
$ export OMP_NUM_THREADS=1
$ time svm-train -c 16 -g 4 -m 400 -t 2 ijcnn1
................*.......*
optimization finished, #iter = 23830
nu = 0.025946
obj = -14014.950179, rho = 0.415656
nSV = 3370, nBSV = 792
Total nSV = 3370
real	0m 29.20s
user	0m 27.92s
sys	0m 1.15s

## 3 core
$ export OMP_NUM_THREADS=3
$ time svm-train -c 16 -g 4 -m 400 -t 2 ijcnn1
................*.......*
optimization finished, #iter = 23830
nu = 0.025946
obj = -14014.950179, rho = 0.415656
nSV = 3370, nBSV = 792
Total nSV = 3370
real	0m 15.19s
user	0m 30.97s
sys	0m 3.48s

## Execution time was reduced almost by half
```