function nobj=coFindNeighbors(neuron,verboseFlag)
%COFINDNEIGHBORS(neuron1,verboseFlag)
%
%find all one-hop neighbors of neuron or cell array of neurons
%
%.if particular left or right suffix is not specified in neuron names,
%the search will be performed for all possible L/R combinations
%
%example: coFindNeighbors('ASH');
%will give pathways for ASHL->AWCL, ASHR->ASHR, ASHR->AWCL, and ASHL->AWCR
%
%.synapses can only be traversed in one direction, gap junctions in either
%
%.needs NeuronConnect.xls in same directory (get latest from WormAtlas.org)
%
%Saul Kato
%110531 first version
%


if nargin<2
    verboseFlag=true;
end

% if nargin<2 || isempty(max_hops)
 max_hops=1;
% end

if nargin<1
    neuron='AWCL';
end

neuron=upper(neuron);


verblist={'syn','syp','gap'};
%load database
[num,txt,raw] = xlsread('NeuronConnect.xls','','','basic');

if verboseFlag
    disp(' ');
    disp(['FINDING NEIGHBORS FOR ' neuron ', max ' num2str(max_hops) ' hops.']);
    disp('(syn=synapse, syp=polyadic synapse, gap=gap junction)');
    disp(' ');
end

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

neuron1L=[neuron 'L'];
neuron1R=[neuron 'R'];

for i=1:numrows
    if strcmp(txt(i,1),neuron)
        neuronList={neuron}; break;
    else
        neuronList={};
    end
end
        
t=0;
for i=1:numrows
    if strcmp(txt(i,1),neuron1L)
        neuronList={neuronList{:}, neuron1L}; break
    end
end

for i=1:numrows
     if strcmp(txt(i,1),neuron1R)
        neuronList={neuronList{:}, neuron1R}; break
    end
end   


for ii=1:length(neuronList)
        if verboseFlag
            disp(' ');
            disp('------------------------------');
            disp(['||       ' neuronList{ii} ]);
        end
        nobj(ii)=FindNeighborsOneNeuron(neuronList{ii},max_hops);
end

if ~exist('nobj') nobj=[]; end


%subfuncs

    function snobj=FindNeighborsOneNeuron(n1,maxhops)


    snobj.n=n1;
    
    m=1;
    
    if (verboseFlag) disp('one hop paths:'); end

    %find 1-hop paths
    for i=1:numrows
        if strcmp(n1,txt(i,1))
                if verb(i)~=0 && verb(i)~=3
                    %plot
                    p{m}=[txt{i,1} ' -' num2str(num(i)) verblist{verb(i)} '-> ' txt{i,2} ...
                      ];
                    numsyn(m)=num(i);
                    if verboseFlag disp(p{m}); end

                    %write into nobj
                    snobj.downNeighbor{m}=txt{i,2};
                    snobj.downJunction{m}=verblist{verb(i)};
                    snobj.downStrength(m)=num(i);

                    m=m+1;


                end
        end
    end

    if verboseFlag
        if (m==1) disp('none'); else disp([num2str(m-1) ' downstream neighbors found.']); end;
        disp('---');
    end

    m=1;
    for i=1:numrows
            if strcmp(n1,txt(i,2)) 
                if verb(i)~=0  && verb(i)~=3
                    p{m}=[txt{i,1} ' -' num2str(num(i)) verblist{verb(i)} '-> ' txt{i,2} ...
                      ];
                    numsyn(m)=num(i);
                    if verboseFlag disp(p{m}); end

                    %write into nobj
                    snobj.upNeighbor{m}=txt{i,1};
                    snobj.upJunction{m}=verblist{verb(i)};
                    snobj.upStrength(m)=num(i);


                    m=m+1;
                end
        end
    end

    if verboseFlag
        if (m==1) disp('none'); else disp([num2str(m-1) ' upstream neighbors found.']); end;
        disp('---GAP JUNCTIONS---');
    end

    %write out gap junctions
    m=1;
    for i=1:numrows
        if strcmp(n1,txt(i,2))
            if verb(i)==3

                p{m}=[txt{i,1} ' -' num2str(num(i)) verblist{verb(i)} '-> ' txt{i,2}];
                if verboseFlag disp(p{m}); end

                snobj.gapneighbor{m}=txt{i,1};
                snobj.gapstrength(m)=num(i);
          %  elseif strcmp(n1,txt(i,1))
          %      snobj.gapneighbor{m}=txt{i,2};
          %      snobj.gapstrength(m)=num(i);
                m=m+1;
            end

        end
    end

%multi-hop neighbors not yet implemented
%     %find 2-hop paths
% 
%     if maxhops>1  %2 hops
%         if verboseFlag
%             disp(' ');
%             disp('two hop paths:');
%         end
%         n=1;
%         for i=1:numrows
%             if strcmp(n1,txt(i,1))
%                 for j=1:numrows  
%                     if strcmp(n2,txt(j,2)) && strcmp(txt(j,1),txt(i,2))
%                         if verb(i)~=0 && verb(j)~=0
%                             pp{n}=[txt{i,1} ' -' num2str(num(i)) verblist{verb(i)} '-> '...
%                                 txt{i,2}  ' -' num2str(num(j)) verblist{verb(j)} '-> ' txt{j,2}];
%                             numpp1(n)=num(i);
%                             numpp2(n)=num(j);
%                             if verboseFlag disp(pp{n}); end
%                             n=n+1;
%                         end
%                     end
%                 end
%             end
%         end
%         if verboseFlag
%             if (n==1) disp('none');  else disp([num2str(n-1) ' 2-hop paths found.']); end;
%         end
%     end
% 
%     %find 3-hop paths
%     if maxhops>2 %3 hops
%         disp(' ');
%         disp('three hop paths:');
% 
%         c2=1;
%         for i=1:numrows
%             if strcmp(n1,txt(i,1))
%                 if verb(i)~=0
%                     ppp_2{c2}=txt(i,2);
%                     ppp_12{c2}=[num2str(num(i)) verblist{verb(i)}];
%                     c2=c2+1;
%                 end
%             end
%         end
% 
%         c3=1;
%         for i=1:numrows
%             if strcmp(n2,txt(i,2))
%                 if reverb(i)~=0
%                     ppp_3{c3}=txt(i,1);
%                     ppp_34{c3}=[num2str(num(i)) verblist{reverb(i)}];
%                     c3=c3+1;
%                 end
%             end
%         end
%        c2=c2-1;
%        c3=c3-1;
% 
%         q=1;
%         for c=1:c2
%             for cc=1:c3
%                 for i=1:numrows
%                     if strcmp(ppp_2{c},txt(i,1)) && strcmp(ppp_3{cc},txt(i,2))
%                         if verb(i)~=0
%                             ppp{q}=[n1 ' -' ppp_12{c} '-> ' txt{i,1} ...
%                                 ' -' num2str(num(i)) verblist{verb(i)} '-> ' txt{i,2} ...
%                                 ' -' ppp_34{cc} '-> ' n2];
% 
%                             if (verboseFlag) disp(ppp{q}); end
%                             q=q+1;
%                         end
%                     end
%                 end   
%             end
%         end
% 
%         if verboseFlag
%             if (q==1) disp('none'); else disp([num2str(q-1) ' 3-hop paths found.']); end;
%         end
%     end 
    
    end %FindPathsOneNeuron

end %findpaths