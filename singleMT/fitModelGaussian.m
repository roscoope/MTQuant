function x = fitModelGaussian(y)

binSize = 1;
muPsf = 0;
sigmaPsf = 1.27*binSize; % equivalent to real avg PSF
psf = gaussmf(-10*binSize:10*binSize,[sigmaPsf muPsf]);
psf(psf < 0.01) = [];
psf = psf' / sum(psf);

thresh = max(y) * 0.1;
x = spline(1:length(y),y/sum(psf),(1/binSize:1/binSize:length(y))');
yHat = conv(x,psf);
yHatToCompare = yHat(ceil(length(psf)/2):binSize:end-floor(length(psf)/2));
err = y - yHatToCompare;

allErrs = 10000000000000000000;
count = 1;
while norm(err) > thresh && norm(err) < allErrs(end)
    allErrs = [allErrs norm(err)];
    x = spline(1:length(y),x(binSize:binSize:end)+err/sum(psf),(1/binSize:1/binSize:length(y))');
    yHat = conv(x,psf);
    yHatToCompare = yHat(ceil(length(psf)/2):binSize:end-floor(length(psf)/2));
    err = y - yHatToCompare;
    count = count + 1;
    if mod(count,50) == 0
        temp = 5;
    end
end
