function TotalThroughput = CalculateTotalThroughput( NoConnections, Throughput )
%Calculate total throughput from extracetd tcptrace file
%   Detailed explanation goes here
TotalThroughput = zeros(1,NoConnections);
Thptindex = 1;
for i=1:NoConnections
    for j=1:i
        TotalThroughput(i)= TotalThroughput(i) + Throughput(Thptindex);
        Thptindex = Thptindex+1;
    end
end
end

