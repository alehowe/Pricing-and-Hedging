function [instruments]= completeStructSwapModified(filename, instruments)
% completeStructSwapModified: Completes dates and rates set from swaps maturities
%
% INPUTS:
%  filename: name of the Excel file
%  instruments: struct with dates and rates information
%
% OUTPUTS:
%  instruments: updated struct with completed dates and rates information

% Initialize day convention
Act365=3;

instruments=readExcelsswapsmaturities(filename, instruments); 

today=instruments.dates.settlement; 

available_swap_dates = instruments.dates.swaps.available_maturities_dates;
all_swap_dates = instruments.dates.swaps.all_maturities_dates;

% Compute the mean swaps
mid_swap_rates=mean(instruments.rates.swaps,2); 

% Spline interpolation of the mid swaps to find the missing ones
all_mid_swaps=interp1(yearfrac(today, available_swap_dates, Act365), mid_swap_rates, yearfrac(today, all_swap_dates, Act365), "spline");


% Return the updated ratesSet struct containing mid rates
mid_depos=mean(instruments.rates.depos, 2);
instruments.rates=rmfield(instruments.rates, "depos");
instruments.rates.mid_depos=mid_depos;

mid_futures=mean(instruments.rates.futures, 2);
instruments.rates=rmfield(instruments.rates, "futures");
instruments.rates.mid_futures=mid_futures;

instruments.rates=rmfield(instruments.rates, "swaps");
instruments.rates.mid_swaps=all_mid_swaps;

end

