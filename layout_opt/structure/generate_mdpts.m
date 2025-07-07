function [mdpts, users] = generate_mdpts(num_user)
%GENERATE_MDPTS  Generates all potential midpoints for N users.
%
%   [mdpts, users] = GENERATE_MDPTS(num_users)
%
%   DESCRIPTION:
%   Generate all midpoint of midpoints and users for a set of num_user
%   points. Outputs the list of midpoints of midpoints and what users are
%   contained in each midpoint.
%
%   INPUTS:
%       num_users   - Integer number of users to be considered.
%
%   OUTPUTS:
%       mdpts   - Matrix of midpoints described by row.
%       users   - Binary matrix of users in each midpoint.

%% Initialize Midpoints
num_user = uint32(num_user);
mdpts =uint32([(1:num_user)', zeros(num_user, num_user-1)]);
users = logical(eye(num_user));

%% Call recursion
idx_mdpt = uint32(2);
while idx_mdpt<length(users)
    users_in_mdpt = users(idx_mdpt,:);
    % If all users haven't been captured
    if any(users_in_mdpt==0)
        addpts_rc(users_in_mdpt,idx_mdpt,idx_mdpt)
    end
    idx_mdpt = idx_mdpt+1;
end

%% Add existing midpoints to midpoint
    function  addpts_rc(user_set_i,idx_mdpt1,idx_mdpt2)

    % find midpoints with no overlapping users
    idx_compatible = ~any(users(1:idx_mdpt2-1,:)&user_set_i,2);
    if any(idx_compatible)
        in_mdpt_list = find(idx_compatible);
        num_mdpt = numel(in_mdpt_list);

        % users in these new midpoints
        users_new = user_set_i|users(idx_compatible,:);
        users(end+1:end+size(users_new,1),:) = users_new;

        % midpoint described by previous rows of midpoint list
        mlist = [repelem(idx_mdpt1, num_mdpt,1), in_mdpt_list, zeros(num_mdpt,num_user-size(idx_mdpt1,2)-1)];
        mdpts(end+1:end+size(users_new,1),:) = mlist;

        % add additional feasible midpoints to the list
        for idx_list = num_mdpt:-1:2
            ui2 = user_set_i|users(in_mdpt_list(idx_list),:);
            addpts_rc(ui2,[idx_mdpt1 in_mdpt_list(idx_list)] ,in_mdpt_list(idx_list));
        end
    end
    end

end



