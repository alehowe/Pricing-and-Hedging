function datesCap=DateCaps(maturities,discountDates)
 % DateCaps: Generates caplet start and end dates based on maturities and discount dates
    %
    % Inputs:
    % maturities: vector of caplet maturities (in years)
    % discountDates: vector of discount curve dates
    %
    % Outputs:
    % datesCap: struct containing caplet settlement and maturity dates
    
aux_vector=zeros(maturities(end)*4, 1);

for ii=1:maturities(end)*4
    % Dates every year from now to expiry
    aux_vector(ii)=addtodate(discountDates(1), 3*ii, 'month');
end

% Consider only the business dates using Eurpean holidays in eurCalendar
% matlab file
aux_vector=busdate(aux_vector-1, 'follow', eurCalendar);

% Build the start dates and maturity vectors (neglecting the first caplet)

datesCap.dte_start=aux_vector(1:end-1);
datesCap.dte_end=aux_vector(2:end);

end
