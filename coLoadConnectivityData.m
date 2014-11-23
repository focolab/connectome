function coStruct=coLoadConnectivityData(verboseFlag)


if nargin<1
    verboseFlag=0;
end
    
    
verblist={'syn','syp','gap'};

%load database
[num,txt,raw] = xlsread('NeuronConnect.xls','','','basic');

%preprocess database
txt(1,:)=[];  %delete header
numrows=size(num,1);
verb=zeros(numrows,1);
for i=1:numrows
    if strcmp(txt{i,3},'S')  
        verb(i)=1;
    elseif strcmp(txt{i,3},'Sp')
        verb(i)=2;
    elseif strcmp(txt{i,3} ,'EJ')
        verb(i)=3;
    end
end

reverb=zeros(numrows,1);
for i=1:numrows
    if strcmp(txt{i,3},'R')  
        reverb(i)=1;
    elseif strcmp(txt{i,3},'Rp')
        reverb(i)=2;
    elseif strcmp(txt{i,3} ,'EJ')
        reverb(i)=3;
    end
end

coStruct.verb=verb;
coStruct.reverb=reverb;
coStruct.num=num;
coStruct.txt=txt;


end

