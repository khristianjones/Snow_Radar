diff=nan(1,999);
for i = 1:999
    diff(:,i)=time_samples(i+1)-time_samples(i);
end