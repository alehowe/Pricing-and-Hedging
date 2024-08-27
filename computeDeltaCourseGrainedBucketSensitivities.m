function [delta_course_grained_bucket_sensitivities] = computeDeltaCourseGrainedBucketSensitivities(contract,instruments,instruments_complete,filename, ...
    macro_buckets, shift, X)
 % computeDeltaCourseGrainedBucketSensitivities: computes the delta course 
    % grained bucket sensitivities
    %
    % INPUTS:
    % filename: name of the excel file
    % instruments: struct with instrument data before modification
    % instruments_complete: struct with complete instrument data before modification
    % macro_buckets: vector containing the macro-buckets (years)
    % shift: shift to be applied to the bucket
    % X: Principal amount
    %
    % OUTPUTS:
    % delta_course_grained_bucket_sensitivities: delta course grained bucket 
    % sensitivities


% Extract the relevant dates used for the bootstrap
relevant_dates=extractRelevantMarketDatesBootstrap(filename,instruments_complete);

today=instruments_complete.dates.today; 
% Compute the set of weights (matrix containig the corresponding weights at
% each year for each macro-bucket)
weights=buildWeightsCourseGrainedBuckets(today, macro_buckets);

% Initialize the vector of sensitivities
delta_course_grained_bucket_sensitivities=zeros(length(weights(:,1)), 1);

% Build the vector of year dates starting from today (the dates
% corresponding to the weights in the matrix)
year_dates=zeros(macro_buckets(end)+1, 1);
year_dates(1)=instruments_complete.dates.settlement; 

for ii=1:length(year_dates)-1
    % Dates every year 
    year_dates(ii+1)=addtodate(year_dates(1), ii, 'year');
end

% Consider only the business dates using Eurpean holidays in eurCalendar
% matlab file
year_dates=busdate(year_dates-1, 'follow', eurCalendar);


% Select only the relevant dates up to the maturity of the contact
last_index=find(relevant_dates>year_dates(end), 1);
relevant_dates=relevant_dates(1:last_index-1);

% Compute the bucket DV01s

[delta_bucket_sensitivities] = computeDeltaBucketSensitivities(contract,instruments,instruments_complete,filename, shift, length(relevant_dates),X);

% Compute the sensitivities for each bucket
for ii=1:length(delta_course_grained_bucket_sensitivities)
    weight_each_relevant_date=interp1(year_dates, weights(ii, :), relevant_dates, 'linear');

    delta_course_grained_bucket_sensitivities(ii)=sum(weight_each_relevant_date.*delta_bucket_sensitivities');
end

end

