function fullNetwork=coBuildConnectivityMatrices

%load neuron names

    fullNetwork.neuronNames=LoadGlobalNeuronIDs;
     

    fullNetwork.nn=length(fullNetwork.neuronNames);

    fullNetwork.synapseMatrix=zeros(length(neuronNames));
    
    fullNetwork.gapJunctionMatrix=zeros(length(neuronNames));

%load connectivity database
    
    verblist={'syn','syp','gap'};
    
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

    
for i=1:length(fullNetwork.neuronNames)

    
   fno=findneighbors(fullNetwork.neuronNames{i});  %function from MATLAB/CircuitDiagram
   
   if isfield(fno,'downstream')
      for j=1:length(fno.downstream)
          if ismember(fno.downstream{j},fullNetwork.neuronNames)   
               downNumber=find(ismember(fullNetwork.neuronNames,fno.downstream{j}));
               fullNetwork.synapseMatrix(i,downNumber)=fno.downstrength(j);
          end
      end
  end

  if isfield(fno,'gapneighbor')
      for j=1:length(fno.gapneighbor)              
          if ismember(fno.gapneighbor{j},fullNetwork.neuronNames)   
              gapNumber=find(ismember(fullNetwork.neuronNames,fno.gapneighbor{j}));
              fullNetwork.gapJunctionMatrix(i,gapNumber)=fno.gapstrength(j);
          end
      end
  end
          
end
    

save('wbFullNetwork.mat','-struct','fullNetwork');
    