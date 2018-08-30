function [row,col] = trivial_bot_V1(gameMap)

[arrHeight, arrWidth] = size(gameMap);

if sum(sum(gameMap))==(10*(arrHeight*arrWidth))
    row =randi(arrHeight,1);
    col =randi(arrWidth,1);

else 

% find all 10 locations
modgameMap=padarray(gameMap,[1,1],0);
probabmap=zeros(arrHeight+2,arrWidth+2);


for i = 2:(arrHeight)
    for j = 2:(arrWidth) 
        
        localarea=modgameMap((i-1):(i+1),(j-1):(j+1)); %open up local area
        any10s=find(localarea==10); %find all unopened
        
        if length(any10s)>0
            localarea(any10s)=zeros(1,length(any10s));
        else 
            any10s=1; 
        end 
        
        any9s=find(localarea==9);  %find all mines 
         
        if length(any9s)>0
            localarea(any9s)=zeros(1,length(any9s));
        end 
        
        
        
        probabmap((i-1):(i+1),(j-1):(j+1))=(localarea(2,2)*((length(any10s)-length(any9s))/(length(any10s)^2)))+probabmap((i-1):(i+1),(j-1):(j+1));
       
        probabmap(i,j)=probabmap(i,j)-(localarea(2,2)*((length(any10s)-length(any9s))/(length(any10s)^2)));
       
        
        
        
        %hard code conditional statements 
        if modgameMap(i,j)~=10
            probabmap(i,j)=-100;
        end 
        
        if modgameMap(i,j)==0
            probabmap(i,j)=-100; 
        end 
        
         if modgameMap(i,j)==9
            probabmap(i,j)=-100; 
         end 
   
         if length(find(localarea==1))>=5 && localarea(2,2)==10;
             probabmap(i,j)=100;
         end 
            
         
    end 
end 
 

%get largest probab

[rowi,colj]=find(probabmap==max(max(probabmap)));

if probabmap(rowi,colj)<=0.5; 
    [find10r,find10col]=find(gameMap==10);
    ind=randi(length(find10r));
    row=find10r(ind);
    col=find10col(ind);
end 

row=rowi(1)-1;
col=colj(1)-1; 

end 
end

