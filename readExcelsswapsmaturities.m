function instruments=readExcelsswapsmaturities(filename, instruments)
% readExcelsswapsmaturities: reads the swap maturities from the excel file
% and creates the dates given the settlement
%
% INPUTS:
%  filename: excel file name where data are stored
%  datesSet: struct with settlementDate, deposDates, futuresDates, swapDates
% 
% OUTPUTS:
% available_swap_dates: swap dates

% Maturities related to swaps
[~, maturity_swaps] = xlsread(filename, 1, 'C39:C56');
numeric_maturities=cellfun(@(x) str2double(strrep(x, 'y', '')), maturity_swaps);
available_swap_dates=zeros(length(numeric_maturities), 1);

for ii=1:length(numeric_maturities)

    % Dates every year from now to expiry
   instruments.dates.swaps.available_maturities_dates(ii)=addtodate(instruments.dates.settlement, numeric_maturities(ii), 'year');
end
for ii=1:numeric_maturities(end)
   
instruments.dates.swaps.all_maturities_dates(ii)=addtodate(instruments.dates.settlement, ii, 'year'); 
end

% Consider only the business dates using Eurpean holidays in eurCalendar
% matlab file

instruments.dates.swaps.available_maturities_dates=busdate(instruments.dates.swaps.available_maturities_dates-1, 'follow', eurCalendar);
instruments.dates.swaps.all_maturities_dates=busdate(instruments.dates.swaps.all_maturities_dates-1, 'follow', eurCalendar);

end