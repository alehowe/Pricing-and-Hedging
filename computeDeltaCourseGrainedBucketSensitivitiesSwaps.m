function [delta_course_grained_bucket_sensitivities_swap] = computeDeltaCourseGrainedBucketSensitivitiesSwaps(filename,instruments,instruments_complete, ...
    macro_buckets, shift, today, swap_rate, swap_maturity, swap_notional)
% computeDeltaCourseGrainedBucketSensitivitiesSwaps: computes the delta course 
    % grained bucket sensitivities
    %
    % INPUTS:
    %  
    %       filename: name of the excel file
    %       instruments: struct containing instrument details
    %       instruments_complete: struct containing complete instrument data
    %       macro_buckets: vector containing the macro-buckets (years)
    %       shift: shift to be applied to the bucket
    %       today: Today's date
    %       swap_rate: Rate of the swap
    %       swap_maturity: Maturity of the swap (in years)
    %       swap_notional: Notional of the swap
    %
    % OUTPUTS:
    %       delta_course_grained_bucket_sensitivities_swap: delta course grained bucket 
    %                                                      sensitivities of the swap


% Extract the relevant dates used for the bootstrap
relevant_dates=extractRelevantMarketDatesBootstrap(filename,instruments_complete);

% Compute the set of weights (matrix containig the corresponding weights at
% each year for each macro-bucket)
weights=buildWeightsCourseGrainedBuckets(instruments_complete.bootstrap.dates(1), macro_buckets);

% Initialize the vector of sensitivities
delta_course_grained_bucket_sensitivities=zeros(length(weights(:,1)), 1);

% Build the vector of year dates starting from today (the dates
% corresponding to the weights in the matrix)
year_dates=zeros(macro_buckets(end)+1, 1);
year_dates(1)=instruments_complete.bootstrap.dates(1);

for ii=1:length(year_dates)-1
    % Dates every year 
    year_dates(ii+1)=addtodate(today, ii, 'year');
end

% Consider only the business dates using Eurpean holidays in eurCalendar
% matlab file
year_dates=busdate(year_dates-1, 'follow', eurCalendar);


% Select only the relevant dates up to the maturity of the contact
last_index=find(relevant_dates>year_dates(end), 1);
relevant_dates=relevant_dates(1:last_index-1);


% Compute NPV of the swap in the normal case (which should be 0)
[instruments_complete] = completeStructSwapModified('MktData_CurveBootstrap_20-2-24', instruments);   
[dates, discounts]=bootstrap(instruments_complete.dates, instruments_complete.rates);

NPV_swaps=NPVswap(dates, discounts, today, swap_maturity, swap_rate, swap_notional);

% Compute the delta bucket sensitivities for each bucket until the swap's
% maturity
delta_bucket_sensitivities_swaps=zeros(length(relevant_dates), 1);

% For each bucket perform the shift 
for ii=1:length(relevant_dates)
    instruments_mod=instruments; 
    [instruments_mod.dates, instruments_mod.rates]=bucketModifier(instruments.dates, instruments.rates, ii, shift);   
    
    [instruments_mod_complete] = completeStructSwapModified('MktData_CurveBootstrap_20-2-24', instruments_mod);

    [~, discounts_mod]=bootstrap(instruments_mod_complete.dates, instruments_mod_complete.rates); 
    
    
    delta_bucket_sensitivities_swaps(ii)= ...
        NPVswap(dates, discounts_mod, today, swap_maturity, swap_rate, swap_notional)-...
        NPV_swaps;   
end


% Initialize the course-grained bucket sensitivities
delta_course_grained_bucket_sensitivities_swap=zeros(length(weights(:,1)),1);


% Compute the sensitivities for each bucket

for ii=1:length(macro_buckets)
    weight_each_relevant_date=interp1(year_dates, weights(ii, :), relevant_dates, 'linear');
    delta_course_grained_bucket_sensitivities_swap(ii)=sum(weight_each_relevant_date.*delta_bucket_sensitivities_swaps);
end

end




