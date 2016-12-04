# SDM for Face Alignment

This is my MATLAB implementation of the Supervised Descent Method (SDM) for face alignment proposed by Xiong and De La Torre 
(https://courses.cs.washington.edu/courses/cse590v/13au/intraface.pdf).

The included model is trained on the 300W dataset using 49 points (no jaw points).

At the moment, this package provides code for face landmark registration only. The code for training will be released at a later time.

## Running the code

There are no external dependancies or mex functions. Running "runDemo.m" should produce an example fit.

## License

This code is not to be used for commerical purposes. This code can be freely used for personal, academic and research purposes. However, we ask that any files retain our copyright notice
when redistributed. This software is provided ``as is'', with no warranty or guarantee. We accept no responsibility for any damages incurred.

The original algorithm (described in: https://courses.cs.washington.edu/courses/cse590v/13au/intraface.pdf) is the work of Xiong and De La Torre.

## Acknowledgements

I would like to acknowledge Chen-Hsuan Lin for providing his SIFT code
and for many useful discussions when developing this package. I would
also like to thank Prof. Simon Lucey for his guidance.

