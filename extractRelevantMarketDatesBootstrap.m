function dates=extractRelevantMarketDatesBootstrap(filename, instruments)
% extractRelevantMarketDatesBootstrap: finds the relevant market dates used 
    % in the bootstrap 
    %
    % INPUTS:
    %  
    %  filename: name of the excel file
    %  instruments: struct with settlementDate, deposDates, futuresDates, swapDates
    %
    % OUTPUTS:
    % dates:  relevant market dates of the bootstrap 

datesSet=instruments.dates; 
% Build all the set of dates fron the market used in the bootstrap
start_futures = find(datesSet.depos > datesSet.futures(1,1), 1,'first');
num_fut=7;
instruments=readExcelsswapsmaturities(filename, instruments);
dates=[datesSet.depos(1:start_futures); datesSet.futures(1:num_fut, 2); instruments.dates.swaps.available_maturities_dates(2:end)'];
dates=busdate(dates-1, 'follow', eurCalendar);
end