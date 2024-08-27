% runAssignment6
% group 9, AY2023-2024
% Hauser Cyril, Howe Alessandro John, Lacarpia Luigi

clear all;
close all;
clc;

%% Settings
formatData = 'dd/mm/yyyy'; % Pay attention to your computer settings

%% Read market data
% This function works on Windows OS. Pay attention to other OS.

[instruments.dates, instruments.rates] = readExcelData('MktData_CurveBootstrap_20-2-24', formatData);

%% Complete swap rates

[instruments_complete] =completeStructSwapModified('MktData_CurveBootstrap_20-2-24', instruments);

%% Bootstrap
% dates includes SettlementDate as the first date
 
[instruments_complete.bootstrap.dates, instruments_complete.bootstrap.discounts] = bootstrap(instruments_complete.dates, instruments_complete.rates); % To be continued

%% Extract the flat cap volatilities
instruments_complete.caps = extractCapsVolTable("Caps_vol_20-2-24");

instruments_complete.caps.dates = DateCaps(instruments_complete.caps.maturities, instruments_complete.bootstrap.dates); 

%% Calibrate
[instruments_complete.caps] = calibrateSpotVol(instruments_complete.bootstrap, instruments_complete.caps);

%% Plot the volatilities
figure;
[X, Y] = meshgrid(instruments_complete.caps.maturities, instruments_complete.caps.strikes);

surf(X', Y', instruments_complete.caps.spot_vols);

xlabel('Maturities');
ylabel('Strikes');
zlabel('Spot Vols');
title('Spot Volatilities');

figure;

surf(X', Y', instruments_complete.caps.flat_vols);

xlabel('Maturities');
ylabel('Strikes');
zlabel('Flat Vols');
title('Flat Volatilities');

clear X Y 

%% Price X

% Define the parameters
contract.start_date = datenum(2024, 2, 20); 
contract.notional = 5 * 10^7; 
contract.B.maturities = [5; 10; 15]; 
contract.B.last_coupons = [0.011, 0.043; 0.011, 0.046; 0.011, 0.051];
contract.B.first_coupon = 0.03; 
contract.A.spol = 0.02; 
% Compute the principal amount value imposing NPV of the contract to 0
X = fzero(@(X) NPVcontract(instruments_complete, contract, X), 0);
fprintf("------------------- Principal amount ---------------------------\n");
fprintf("Party B pays %.2f%% of the principal amount at the start date\n", abs(X * 100));
%% Compute delta bucket sensitivities
shift = 10^(-4);
numbuckets = 28;   % Modify from tomorrow to the swap rate at 15 years of the market, 
                   % so 4 (depos) + 7 (futures) + 14 (swaps), excluding the first year
instruments.caps=instruments_complete.caps; 

[delta_bucket_sensitivities] = computeDeltaBucketSensitivities(contract, instruments,instruments_complete, 'MktData_CurveBootstrap_20-2-24', shift, numbuckets, X); 

fprintf('---------------------Delta Bucket Sensitivities-----------------\n')
fprintf('%f\n', delta_bucket_sensitivities);
sum(delta_bucket_sensitivities)
%% Compute delta course grained bucket sensitivities
macro_buckets = [2, 5, 10, 15];
shift = 10^(-4);

delta_course_grained_bucket_sensitivities = computeDeltaCourseGrainedBucketSensitivities(contract, instruments,instruments_complete, 'MktData_CurveBootstrap_20-2-24', ...
    macro_buckets, shift, X);

fprintf('---------------------Delta course grained Bucket Sensitivities-----------------\n')
for i = 1:length(macro_buckets)
    fprintf('Delta course-grained sensitivity for bucket %dy: %f\n', macro_buckets(i), delta_course_grained_bucket_sensitivities(i));
end
sum(delta_bucket_sensitivities)
% delta_course_grained_bucket_sensitivities = computeDeltaCourseGrainedBucketSensitivitiesOldVersion('MktData_CurveBootstrap_20-2-24', datesSet, ...
%     macro_buckets, ratesSet, shift, today, contract_maturities_time, matrix_data, CapVolSet, X, ...
%     spolA, first_couponB, notional);
% 
% fprintf('-------------------Delta course grained Bucket Sensitivities Old Version-----------------\n')
% for i = 1:length(macro_buckets)
%     fprintf('Delta course-grained sensitivity for bucket %dy: %f\n', macro_buckets(i), delta_course_grained_bucket_sensitivities(i));
% end


%% Hedging with swaps

% Select swap maturities
instruments_complete.hedging.swaps.maturities=[2,5,10,15];


% Mid bid-ask rate from excel file
instruments_complete.hedging.swaps.rates=[instruments_complete.rates.mid_swaps(2),instruments_complete.rates.mid_swaps(5), ...
           instruments_complete.rates.mid_swaps(10), instruments_complete.rates.mid_swaps(15)];

instruments_complete.hedging.swaps.notionals=hedgeDeltaRiskSwaps('MktData_CurveBootstrap_20-2-24', contract,instruments,instruments_complete, macro_buckets, shift, X);

fprintf('-------------------Swap notionals to hedge the position-----------------\n')
for i = 1:length(instruments_complete.hedging.swaps.maturities)
    fprintf('Notional of the swap at maturity: %d: %f\n', instruments_complete.hedging.swaps.maturities(i), instruments_complete.hedging.swaps.notionals(i));
end


%% Compute the total vega of the contract

total_vega=computeTotalVega(contract,instruments_complete, shift,X);

fprintf('-------------------Total Vega-----------------\n')

fprintf('Total vega sensitivity of the contract: %f\n', total_vega);


%% Compute Vega-bucket sensitivities

last_index=length(instruments_complete.caps.maturities);

vega_bucket_sensitivities=computeVegaBucketSensitivities(contract,instruments_complete,shift, ...
    X, last_index);

fprintf('-------------------Vega Bucket Sensitivities -----------------\n')
for i = 1:last_index
    fprintf('Vega sensitivity for bucket %dy: %f\n', instruments_complete.caps.maturities(i), vega_bucket_sensitivities(i));
end
sum(vega_bucket_sensitivities)
%% Hedge total vega with a cap

% Parameters
instruments_complete.hedging.caps.notional=1; 
cap_maturity=5;
cap_strike=instruments_complete.rates.mid_swaps(5);

cap_notional=hedgeTotalVegaRiskCap(contract,instruments_complete,shift, today, X, cap_maturity, cap_strike);

fprintf('-------------------Cap notional to hedge the total vega-----------------\n')
fprintf('Notional of the ATM cap with maturity %d to hedge the total vega: %f\n', cap_maturity, cap_notional);

%% Hedging vega course-grained buckets with caps

% Buckets
macro_buckets=[5, 15];
maturitiesCaps=[5,15];

% Select the ATM strike (swap rates as written in the text of assignement)
cap_strikes=[instruments_complete.rates.mid_swaps(5), instruments_complete.rates.mid_swaps(15)];


caps_notionals=-hedgeVegaRiskCaps(contract,instruments_complete, macro_buckets, shift, instruments_complete.bootstrap.dates(1), X,  maturitiesCaps,cap_strikes, vega_bucket_sensitivities); 

fprintf('-------------------Caps notionals to hedge the position-----------------\n')
for i = 1:length(maturitiesCaps )
    fprintf('Notional of the cap at maturity: %d: %f\n', maturitiesCaps(i), caps_notionals(i));
end

%% Hedge total vega with a cap and delta buckets

% Parameters
cap_maturity=5;
cap_strike=instruments_complete.rates.mid_swaps(5);
maturitiesSwaps=[2,5,10,15];
notionalContract=50*10^6;
macro_buckets=[2,5,10,15];
swap_rates=[instruments_complete.rates.mid_swaps(2), instruments_complete.rates.mid_swaps(5), ...
            instruments_complete.rates.mid_swaps(10), instruments_complete.rates.mid_swaps(15)];

instruments_complete.hedging.caps.notional=hedgeTotalVegaRiskCap(contract,instruments_complete, shift, instruments_complete.bootstrap.dates(1), X,  cap_maturity,cap_strike);

fprintf('-------------------Cap notional to hedge the total vega-----------------\n')
fprintf('Notional of the ATM cap (CAP payer) with maturity %d to hedge the total vega: %f\n', cap_maturity, cap_notional);


swaps_notionals=hedgeDeltaVegaRiskSwapsCaps(contract, instruments,instruments_complete,'MktData_CurveBootstrap_20-2-24', macro_buckets, shift, today, X, maturitiesSwaps, swap_rates,cap_maturity,cap_strike);

fprintf('------------------- Swaps notional to hedge the total vega-----------------\n')
for i = 1:length(maturitiesSwaps)
    fprintf('Notional of the swap (SWAP payer) at maturity: %d: %f\n', maturitiesSwaps(i), swaps_notionals(i));
end
