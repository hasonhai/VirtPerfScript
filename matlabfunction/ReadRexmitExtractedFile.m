function [ SenderRexmitPkts, ReceiverRexmitPkts, SenderTotalPkts, ReceiverTotalPkts, TotalPkts ] = ReadRexmitExtractedFile( filename, noConnections )
% Read the Rexmit from Extracted File
%   The Extracted file is generated by ./collectRexmit.sh and tcptrace
%   TotalPkts: packets from both directions
%   The most important output of this function is the array of SenderRexmitPkts

% filename='';
% noConnections= 32;
if strcmp(filename,'')
    filename = 'DataStatistic/Sender_NATIVE60sProcsRenoDelay10Rexmit.txt';
end
tempStr = fileread(filename);
TextRemovedStr = regexp(tempStr,'\s[0-9]+','match');
TextRemovedStr = char(deblank(TextRemovedStr));
NumberArr = [str2num(TextRemovedStr)]';

NumberArrIndex = 1;
PktsIndex = 1;
for i=1:noConnections
    for j=1:i
        TotalPkts(PktsIndex) = NumberArr(NumberArrIndex);
        NumberArrIndex = NumberArrIndex + 1;
        SenderTotalPkts(PktsIndex) = NumberArr(NumberArrIndex);
        NumberArrIndex = NumberArrIndex + 1;
        ReceiverTotalPkts(PktsIndex) = NumberArr(NumberArrIndex);
        NumberArrIndex = NumberArrIndex + 1;
        SenderRexmitPkts(PktsIndex) = NumberArr(NumberArrIndex);
        NumberArrIndex = NumberArrIndex + 1;
        ReceiverRexmitPkts(PktsIndex) = NumberArr(NumberArrIndex);
        NumberArrIndex = NumberArrIndex + 1;
        PktsIndex = PktsIndex + 1;
    end
end
end