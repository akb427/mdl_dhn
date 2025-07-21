function [mdpts, users] = generate_mdpts(N)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%% Initialize Midpoints
N = uint32(N);
mdpts =uint32([(1:N)', zeros(N, N-1)]);
users = logical(eye(N));

%% Call recursion
i = uint32(2);
while i<length(users)
    u1 = users(i,:);
    if any(u1==0)
        addptsrc(u1,i,i)
    end
    i = i+1;
end

%% Recursive function
    function  addptsrc(ui,mi,i)
        idx = ~any(users(1:i-1,:)&ui,2);
        if any(idx)
            idxl = find(idx);
            nm = numel(idxl);
            ulist = ui|users(idx,:);
            users(end+1:end+size(ulist,1),:) = ulist;
            mlist = [repelem(mi, nm,1), idxl, zeros(nm,N-size(mi,2)-1)];
            mdpts(end+1:end+size(ulist,1),:) = mlist;
            for j = nm:-1:2
                ui2 = ui|users(idxl(j),:);
                addptsrc(ui2,[mi idxl(j)] ,idxl(j));
            end
        end
    end

end



