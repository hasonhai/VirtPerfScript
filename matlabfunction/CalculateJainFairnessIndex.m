function ThroughputFairness = CalculateJainFairnessIndex( NoConnections, Throughput )
% Calculate Jain Fairness Index
%   The formular is from wikipedia.
%   The input throughput should have the format comming from the extracted
%   TCPtrace file and collectingThroughput.sh script.

ThroughputFairnessNumeritor = zeros(1,NoConnections);
Thptindex = 1;
for i=1:NoConnections
    for j=1:i
        ThroughputFairnessNumeritor(i)= ThroughputFairnessNumeritor(i) + Throughput(Thptindex);
        Thptindex = Thptindex+1;
    end
    ThroughputFairnessNumeritor(i) = (ThroughputFairnessNumeritor(i))^2;
end

ThroughputFairnessdenominator = zeros(1,NoConnections);
Thptindex = 1;
for i=1:NoConnections
    for j=1:i
        ThroughputFairnessdenominator(i)= ThroughputFairnessdenominator(i) + (Throughput(Thptindex))^2;
        Thptindex = Thptindex+1;
    end
        ThroughputFairnessdenominator(i) = i*ThroughputFairnessdenominator(i);
end

ThroughputFairness = ThroughputFairnessNumeritor./ThroughputFairnessdenominator;

end


