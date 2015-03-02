function tsmooth = mSmooth(tchain, windowsize)
temp = zeros(size(tchain));
len = length(tchain);
k = (windowsize-1)/2;
t = k;
%---Define Gaussian Kernel---------------
gs = zeros(k);
while(t)
j = floor(t/2);
gs(t) = exp(-(j^2)/2*(k^2))/sqrt(2*pi*k);
t = t-1;
end
%----------Ignoring the first k frames----------------
count3 = 1;
while(k)
    k = k-1;
    len = len-1;
    temp(:,:,count3)=tchain(:,:,count3);
    count3 = count3 + 1;
end
%-----------------------------------------------------
%----------------Applying the smoothing function------------------------
while(len)
    first = -k;
    sc = 1;
    while(first<=k)
    temp(:,:,count3)=temp(:,:,count3)+ conv2(tchain(:,:,count3+first),gs(sc));
    first = first+1;
    sc = sc+1;
    end
    count3 = count3 + 1;
    len = len-1;
% temp(:,:,count3) = temp(:,:,count3-1)+conv2(tchain(:,:,count3+k),gs)-conv2(tchain(:,:,count3-k),gs);
% count3 = count3+1;
% len = len-1;
end
%----------Return the smoothed chain---------------------
tsmooth = temp;
