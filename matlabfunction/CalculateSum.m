function ExtractedSum = CalculateSum( NoConnections, InputArray )
%Calculate summation for each cases from extracetd tcptrace file
%   Detailed explanation goes here
ExtractedSum = zeros(1,NoConnections);
InputArrayIndex = 1;
for i=1:NoConnections
    for j=1:i
        ExtractedSum(i)= ExtractedSum(i) + InputArray(InputArrayIndex);
        InputArrayIndex = InputArrayIndex+1;
    end
end
end