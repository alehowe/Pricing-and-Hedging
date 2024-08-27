function weights=buildWeightsCourseGrainedBuckets(today, macro_buckets)
% buildWeightsCourseGrainedBuckets: builds the weights to apply to course-
% grained buckets 

% Inputs:
% macro_buckets:        vector containing the macro-buckets (years)

% Outputs:
% weights:              matrix containing the weights relative to each year

% Build the dates vector up to the last year
year_dates=zeros(macro_buckets(end)+1, 1);
year_dates(1)=today;

for ii=1:length(year_dates)-1
    % Dates every year 
    year_dates(ii+1)=addtodate(today, ii, 'year');
end

% Consider only the business dates using Eurpean holidays in eurCalendar
% matlab file
year_dates=busdate(year_dates-1, 'follow', eurCalendar);

% Initialize the weights matrix
weights=zeros(length(macro_buckets), length(year_dates));

% Compute the case of the first weights

for ii=1:macro_buckets(1)+1
    weights(1,ii)=1;
end

for jj=macro_buckets(1)+2:macro_buckets(2)
   
    weights(1, jj)=interp1([year_dates(macro_buckets(1)+1), year_dates(macro_buckets(2)+1)], ...
        [1,0], year_dates(jj), 'linear');
end

% Compute the case of intermediate weights
for bucket=2:length(macro_buckets)-1
    weights(bucket, macro_buckets(bucket)+1)=1;
    for jj=macro_buckets(bucket-1)+2:macro_buckets(bucket)
        weights(bucket, jj)=interp1([year_dates(macro_buckets(bucket-1)+1), year_dates(macro_buckets(bucket)+1)], ...
            [0,1], year_dates(jj), 'linear');
    end

    for jj=macro_buckets(bucket)+2:macro_buckets(bucket+1)
        weights(bucket, jj)=interp1([year_dates(macro_buckets(bucket)+1), year_dates(macro_buckets(bucket+1)+1)], ...
            [1,0], year_dates(jj), 'linear');
    end
end

% Compute the case of last weights
for jj=macro_buckets(end-1)+2:macro_buckets(end)+1
    weights(end, jj)=interp1([year_dates(macro_buckets(end-1)+1), year_dates(macro_buckets(end)+1)], ...
        [0,1], year_dates(jj), 'linear');
end

end