% Constructing the ds.samples matrix 
% from multiple cope files, 
% from both runs,
% from multiple subjects.
% and assigning sample attributes.

% Setting Home directory. 
% This dir includes the 'fMRI' folder, containing all subject folders.
home_dir = 'C:/Users/User/Desktop/HCP_WM_Datasets_2C';

% Setup area. Change to perform different analyses.
selected_copes = 1:4;
selected_runs = {'LR' 'RL'};

labels_dict  = dictionary( 1, 'Body'  , ...
                           2, 'Face'  , ...
                           3, 'Place' , ...
                           4, 'Tool' );

targets_dict = dictionary( 1, 1  , ...
                           2, 2  , ...
                           3, 3  , ...
                           4, 4 );

chunks_dict  = dictionary( 1, 1  , ... %chunk 1 is LR
                           2, 1  , ... %chunk 2 is RL
                           3, 1  , ... 
                           4, 1 );     

% Extract subjects list into output: "subj_list".
subj_dir_files = dir([home_dir '/fmri']);
subj_dir_files_count = numel(subj_dir_files);
subj_list = cell(1,subj_dir_files_count);
subj_count=0;

for flag=1:subj_dir_files_count
    % Condition for subj_dir_file to be a valid subj folder.
    % Checks if it contains any number in its name.
    subj_condition = (numel(regexp(subj_dir_files(flag).name,'\w\d'))~=0);    
    if subj_condition
        subj_list(subj_count + 1) = {subj_dir_files(flag).name};
        subj_count = subj_count + 1;
    end
end
subj_list = subj_list(~cellfun(@isempty,subj_list) == 1);

% Extract and add .sa to each cope.
selected_cope_count = numel(selected_copes);
run_count = numel(selected_runs);
cope_storage = cell((selected_cope_count*run_count),1);
cope_total_count = 0;

% Go through all subjects.
chunks_count = 0;
for subj_id = 1:subj_count
    % Outlier Subjects
    if (subj_id == 2) %|| (subj_id==20)
            continue
    end
    run_increment = 0;
    % Go through all chosen runs.
    for run_id = 1:run_count
        % Go through all chosen copes.
        for flag = 1:selected_cope_count
            cope_id = selected_copes(flag);
            % Read specific cope file.
            runspec = cell2mat(['/fmri/' subj_list(subj_id) '/tfMRI_WM_' selected_runs(run_id) '_analyzed.feat/stats']);
            filespec = ['/cope' num2str(cope_id) '.nii.gz'];
            ds_temp = cosmo_fmri_dataset( [home_dir runspec filespec] );

            % Set the sample attributes for chosen cope.
            ds_temp.sa.targets = targets_dict(cope_id);
            ds_temp.sa.labels  = labels_dict(cope_id);
            ds_temp.sa.chunks  = chunks_dict(cope_id) + run_increment + chunks_count;

            % Store data from each cope, seperately, in storage matrix.
            cope_storage{cope_total_count + 1} = ds_temp;
            cope_total_count = cope_total_count + 1;
        end
        run_increment = run_increment + 1;
    end
    chunks_count = chunks_count + run_count;
end

% Concatenate cope's into final dataset.
ds = cosmo_stack(cope_storage(1:cope_total_count));

% Display Data.
cosmo_disp(ds)

% Sanity checks.
% Regarding ds
assert(isequal(cosmo_check_dataset(ds),1))
assert(isequal(ds_temp.samples,ds.samples(size(ds.samples,1),:)))
% Regarding ds.sa - Works only for analyses inclusing all four targets.
target_count = numel(unique(ds.sa.targets));
if target_count == 4
    assert(isequal(ds.sa.labels,repmat(["Body";"Face";"Place";"Tool"],38,1)))
    assert(isequal(ds.sa.targets,repmat((1:4)',38,1)))
    %assert(isequal(ds.sa.chunks,repmat([1 1 1 1 2 2 2 2]', 20, 1)));
end

% Clear clutter variables.
clutter_vars = {'cope_id' 'ds_temp' 'filespec' 'run_id' 'run_increment' 'runspec' ...
                'subj_condition' 'subj_dir_files' 'subj_dir_files_count' 'subj_id' };
for flag=1:numel(clutter_vars) 
    clear(clutter_vars{flag})
end
clear flag; clear clutter_vars;