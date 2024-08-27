function NPV=NPVswap(dates, discounts, today, maturity, s, notional)
% NPVswap: computes the NPV of a swap

%   Input:
%       dates:                  Vector of dates.
%       discounts:              Vector of discount factors corresponding to the dates.
%       today:                  Today's date.
%       maturity:               Maturity of the swap (in years)
%       s:                      Swap rate
%       notional:               Notional

%   Output:
%       NPV:                    Swap NPV


% Define different year-fraction computation methods
Act360=2;
Act365=3;
Eu30_360=6;

% Compute the payment dates of the fixed leg
year_dates=zeros(maturity+1, 1);
year_dates(1)=today;

for ii=1:length(year_dates)-1
    % Dates every year 
    year_dates(ii+1)=addtodate(today, ii, 'year');
end

% Consider only the business dates using Eurpean holidays in eurCalendar
% matlab file
year_dates=busdate(year_dates-1, 'follow', eurCalendar);

% Compute the year_fracs
deltas=yearfrac(year_dates(1:end-1), year_dates(2:end), Act360);

% Find the used discounts
used_discounts=find_discount(dates, discounts, year_dates(2:end));

% Compute the NPV of the floating leg
NPV_fl=1-used_discounts(end);

% Compute the NPV of the fixed leg
NPV_fixed=s*sum(deltas.*used_discounts);

% Compute the total NPV
NPV=notional*(NPV_fl-NPV_fixed);

end