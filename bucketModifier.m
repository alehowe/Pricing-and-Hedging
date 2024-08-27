function [datesSet, ratesSet]=bucketModifier(datesSet_old, ratesSet_old, index, shift)
% bucketModifier: Modifies the rates set based on the index and shift.

% INPUTS:
%  
%  datesSet_old: struct with settlementDate, deposDates, futuresDates, swapDates.
%  ratesSet_old: struct with deposRates, futuresRates, swapRates.
%  index: Index indicating the position to modify in the rates set.
%  shift: Shift value to be applied.

% OUTPUTS:
%  datesSet: Struct with settlementDate, deposDates, futuresDates, swapDates.
%  ratesSet: Modified struct with deposRates, futuresRates, swapRates.

num_fut=7;

% Insert the depos and future dates
start_futures = find(datesSet_old.depos > datesSet_old.futures(1,1), 1,'first');
ratesSet=ratesSet_old; 
datesSet=datesSet_old; 
% Modify the structure
if index<=start_futures
    ratesSet.depos(index, 1)=ratesSet_old.depos(index, 1)+shift;
    ratesSet.depos(index, 2)=ratesSet_old.depos(index, 2)+shift;
elseif index <= num_fut+start_futures
     ratesSet.futures(index-start_futures, 1)=ratesSet_old.futures(index-start_futures, 1)+shift; 
     ratesSet.futures(index-start_futures, 2)=ratesSet_old.futures(index-start_futures, 2)+shift;
elseif index<=num_fut+start_futures+length(ratesSet_old.swaps(:,1))-1
    ratesSet.swaps(index-num_fut-start_futures+1, 1)=ratesSet_old.swaps(index-num_fut-start_futures+1, 1)+shift;
    ratesSet.swaps(index-num_fut-start_futures+1, 2)=ratesSet_old.swaps(index-num_fut-start_futures+1, 2)+shift;

else
    error("Index is not in the data range")
end

end