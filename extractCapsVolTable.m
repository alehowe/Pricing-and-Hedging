function CapVolSet=extractCapsVolTable(filename)
% extractCapsVolTable: extracts the cap table form the excel file storing
% the header row, the index columnn and the matrix value in the struct

% Inputs: 
% filename:         the name of the excel file

% Outputs:
% CapVolSet:        struct containing the flat volatilities


% Import data from Excel
[cap_data, ~] = xlsread(filename, 1, "F2:R17");
[strikes, ~] = xlsread(filename, 1, "F1:R1");
[~, maturities] = xlsread(filename, 1, "B2:B17");

% Neglect the 18 month data
cap_data=cap_data([1, 3:end], :)./(10^4);
strikes=strikes./100;
maturities=maturities([1, 3:end]);

% Neglect the "y" in the string
maturities=cellfun(@(x) str2double(strrep(x, 'y', '')), maturities);

% Store the extracted data in a struct
CapVolSet = struct(...
    'flat_vols', cap_data, ...
    'strikes', strikes, ...
    'maturities', maturities);
end