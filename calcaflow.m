function affinemat = calcaflow(tmat)
len = length(tmat);
count = 1;
temp = zeros(size(tmat));
s = 1;
while(len)
s = tmat(1,1,count)+1;
theta = tmat(1,2,count);
a = tmat(2,1,count);
b = tmat(2,2,count);

capA = s*cos(theta)-s*b*sin(theta);
capB = s*sin(theta)+s*b*cos(theta);
capC = s*a*cos(theta)-s*sin(theta);
capD = s*a*sin(theta)+s*cos(theta);
capE = tmat(3,1,count);
capF = tmat(3,2,count);

temp(:,:,count) = [capA, capB; capC, capD; capE, capF];

len = len-1;
count = count+1;

end

affinemat = temp;