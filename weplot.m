function plotsuccess = weplot(t1,t2)


[m,n,l] = size(t1);
t = [1:l];
t = transpose(t);
count = 1;
a = 0;
b = 1;
c = 1;
while(count<=(m*n))
    if(count<=m)
        a = a+1;
    elseif(c)
        c = 0;
        a = 1;
        b = 2;
    else
        a = a+1;
    end
    
    x = t1(a,b,:);
    x = x(:);
    y = t2(a,b,:);
    y = y(:);
    subplot(m,n,count)
    plot(t,x,t,y);
    count = count+1;
end

plotsuccess = 1;