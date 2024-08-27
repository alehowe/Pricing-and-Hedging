function delta_course_grained_bucket_sensitivities_cap=computeDeltaCourseGrainedBucketSensitivitiesCap(instruments,instruments_complete, filename, macro_buckets, shift, today, cap_maturity,cap_strike)
                                                                                                        
% computeDeltaCourseGrainedBucketSensitivitiesCap: computes the delta course 
% grained bucket sensitivities of the cap

% INPUTS:
%  
%       instruments:            Information about the cap instruments.
%       instruments_complete:   Complete set of cap instruments.
%       filename:               Name of the Excel file containing relevant market dates.
%       macro_buckets:          Vector containing the macro-buckets (years).
%       shift:                  Shift to be applied to the bucket.
%       today:                  Today's date.
%       cap_maturity:           Maturity of the cap (in years).
%       cap_strike:             Strike of the cap.
%
% OUTPUTS:
%       delta_course_grained_bucket_sensitivities_cap:    Delta course grained bucket 
%                                                         sensitivities of the cap

% Extract the relevant dates used for the bootstrap
all_relevant_dates=extractRelevantMarketDatesBootstrap(filename, instruments_complete);

% Compute the set of weights (matrix containig the corresponding weights at
% each year for each macro-bucket)
weights=buildWeightsCourseGrainedBuckets(today, macro_buckets);
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
last_index=find(all_relevant_dates>year_dates(end), 1);
relevant_dates=all_relevant_dates(1:last_index-1);

% Initialize the vector of sensitivities
delta_course_grained_bucket_sensitivities_cap=zeros(length(weights(:,1)), 1);

% Compute NPV of the cap in the normal case

NPV_cap=priceCapBachelier(instruments_complete,instruments_complete.dates.today, cap_maturity, cap_strike);

% Compute the delta bucket sensitivities for each bucket until the cap's
% maturity

delta_bucket_sensitivities_caps=zeros(length(relevant_dates), 1);

% For each bucket perform the shift
for ii=1:length(relevant_dates)
 
    instruments_mod=instruments; 
    [instruments_mod.dates, instruments_mod.rates]=bucketModifier(instruments.dates, instruments.rates, ii, shift);   
    
    [instruments_mod_complete] = completeStructSwapModified('MktData_CurveBootstrap_20-2-24', instruments_mod);

    [instruments_mod_complete.bootstrap.dates, instruments_mod_complete.bootstrap.discounts]=bootstrap(instruments_mod_complete.dates, instruments_mod_complete.rates); 

    instruments_mod_complete.hedging=instruments_complete.hedging; 
    
   
    delta_bucket_sensitivities_caps(ii)= ...
        priceCapBachelier(instruments_mod_complete, instruments_complete.dates.today, cap_maturity, cap_strike)-...
        NPV_cap;    
end


% Find the index where to stop
index_to_stop=find(macro_buckets==cap_maturity);

% Compute the sensitivities for each bucket
for ii=1:index_to_stop
    weight_each_relevant_date=interp1(year_dates, weights(ii, :), relevant_dates, 'linear');
    delta_course_grained_bucket_sensitivities_cap(ii)=sum(weight_each_relevant_date.*delta_bucket_sensitivities_caps);
end

end