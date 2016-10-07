function noise = GenGaussianNoise(I)

noise = imnoise(I,'gaussian',M,V);