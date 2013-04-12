function [ Timeline1p, Throughput1p,...
    Timeline10p, Throughput10p,...
    TimelineAvg, ThroughputAvg,...
    TimelineYp, ThroughputYp,...
    TimelineZp, ThroughputZp ] = readDatasets( options, datasetsFile )
%Read the Throughput File from GNUPlot
%Throughput plot from tcptrace meaning

%>> When I plot a2b_tput.xpl I get two curves, one red and one blue
%>> plus the yellow dots for packets. What is not clear for me is what
%>> are the blue and red curves represents with respect to throughput?

% Sorry, that stuff hasn't been documented very well, partly because I'm not
%sure how to display it more clearly, but here's what it means:
% The yellow dots are the instantaneous throughput samples.  They're
%calculated by using the time since the last segment for the connection
%and the size of the current segment to get bytes/second for this sample.
% The red line is the result of averaging together multiple yellow dots.
% By default (see -A), the red line uses the last 10 segments to calculate
%a throughput.  Higher -A values give smoother curves.
% The blue line is simply a running average throughput from the beginning of
%the transfer, and it's final value is the same as what is reported for the
%connection's transfer rate.
% Hope that helps.  As I said, I'm not really sure what should be on this
%graph.  What's there is the stuff that we've wanted here locally, but I'd
%be glad to hear other ideas!

%================OUTPUT=======================%
% Timeline1p, Throughput1p : Timeline and throughput of sample at 1 packet.
% Xplot represent this one by 'dot'.
% Timeline10p, Throughput10p : Timeline and throughput of sample every 10
% packets. Xplot represent this one by 'line'.
% TimelineXp, ThroughputXp : This one looks like the average. Xplot represent this one by 'line'.
% TimelineYp, ThroughputYp : This one looks like have the same value at Xp.
% Xplot represent this one by 'dot'.
% TimelineYp, ThroughputYp : This one looks like have the same value at
% 10p. Xplot represent this one by 'dot'.
%=============================================%

%================OPTIONS======================%
% options = 'InstTput' -> Take only the instantaneous throughput
% options = '10pTput' -> Take only the 10-packets period throughput
% options = 'avgTput' -> Take only the average throughput
% optines = 'all' -> Take all the information
%=============================================%

% datasetsFile=''; %for testing only

if strcmp(datasetsFile,'')
   %datasetsFile = 'xplFile/a2b_tput.datasets';
    disp('Input filename please!');
end

tempStr = fileread(datasetsFile);
Segment_idx = regexp(tempStr,'\n\n\n'); %Find throughput data segment

if strcmp(options, 'all') || strcmp(options, 'InstTput')    
    %Read the instantaneous throughput
    StrimedStr = tempStr(:,1:Segment_idx(1)); %Remove the last part
    idx = regexp(StrimedStr,'\n'); %Seperate each line
    
    Timeline1p = zeros(1,length(idx));
    Throughput1p = zeros(1,length(idx));
    temp = sscanf(StrimedStr(:,1:idx(1)),'%f %f'); %Read first line
    Timeline1p(1) = temp(1); %Store first value
    Throughput1p(1) = temp(2); %Store first value
    for i=1:(length(idx)-1) %Read the remained part
        temp = sscanf(StrimedStr(:,idx(i):idx(i+1)),'%f %f'); %Read line i+1
        Timeline1p(i+1) = temp(1); %Store value i+1
        Throughput1p(i+1) = temp(2); %Store first value i+1
    end
else
    Timeline1p = 0;
    Throughput1p = 0;
end
%     figure(1)
%     plot(Timeline1p,Throughput1p);hold all;

if strcmp(options, 'all') || strcmp(options, '10pTput')
    %Read the throughput every 10 packets
    StrimedStr = tempStr(Segment_idx(1):Segment_idx(2)); %Remove the last part
    idx = regexp(StrimedStr,'\n'); %Seperate each line
    
    index10p = 1;
    for i=4:3:(length(idx)-1) %Omit 3 first line
        temp = sscanf(StrimedStr(:,idx(i):idx(i+1)),'%f %f'); %Read line i+1
        Timeline10p(index10p) = temp(1); %Store value i+1
        Throughput10p(index10p) = temp(2); %Store first value i+1
        index10p = index10p + 1;
    end
    temp = sscanf(StrimedStr(:,idx(length(idx)-2):idx(length(idx)-1)),'%f %f'); %Read line i+1
    Timeline10p(index10p) = temp(1);
    Throughput10p(index10p) = temp(2);
else
    Timeline10p = 0;
    Throughput10p = 0;
end
%     plot(Timeline10p,Throughput10p); hold all;

if strcmp(options, 'all') || strcmp(options, 'avgTput')
    %Read the throughput every X packets
    StrimedStr = tempStr(Segment_idx(2):Segment_idx(3)); %Remove the last part
    idx = regexp(StrimedStr,'\n'); %Seperate each line
    
    indexAvg = 1;
    for i=5:3:(length(idx)-1) %Omit 3 first line
        temp = sscanf(StrimedStr(:,idx(i):idx(i+1)),'%f %f'); %Read line i+1
        TimelineAvg(indexAvg) = temp(1);
        ThroughputAvg(indexAvg) = temp(2);
        indexAvg = indexAvg + 1;
    end
    temp = sscanf(StrimedStr(:,idx(length(idx)-2):idx(length(idx)-1)),'%f %f'); %Read line i+1
    TimelineAvg(indexAvg) = temp(1);
    ThroughputAvg(indexAvg) = temp(2);
else
    TimelineAvg = 0;
    ThroughputAvg = 0;
end
%     plot(TimelineXp,ThroughputXp); hold all;

if strcmp(options, 'all')
    %Read the throughput every Y packets
    StrimedStr = tempStr(Segment_idx(3):Segment_idx(4)); %Remove the last part
    idx = regexp(StrimedStr,'\n'); %Seperate each line
    
    indexYp = 1;
    for i=4:(length(idx)-1) %Read the remained part
        temp = sscanf(StrimedStr(:,idx(i):idx(i+1)),'%f %f'); %Read line i+1
        TimelineYp(indexYp) = temp(1); %Store value i+1
        ThroughputYp(indexYp) = temp(2); %Store first value i+1
        indexYp = indexYp+1;
    end
else
    TimelineYp = 0;
    ThroughputYp = 0;
end
%figure(2);
%     plot(TimelineYp,ThroughputYp); hold all;

if strcmp(options, 'all')
    %Read the throughput every Z packets
    StrimedStr = tempStr(Segment_idx(4):Segment_idx(5)); %Remove the last part
    idx = regexp(StrimedStr,'\n'); %Seperate each line
    
    indexZp = 1;
    for i=3:(length(idx)-1) %Read the remained part
        temp = sscanf(StrimedStr(:,idx(i):idx(i+1)),'%f %f'); %Read line i+1
        TimelineZp(indexZp) = temp(1); %Store value i+1
        ThroughputZp(indexZp) = temp(2); %Store first value i+1
        indexZp = indexZp+1;
    end
else
    TimelineZp = 0;
    ThroughputZp = 0;
end
%     plot(TimelineZp,ThroughputZp); hold off;

end

