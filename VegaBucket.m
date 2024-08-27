function V_buck=VegaBucket(dates, discounts, today, contract_maturities_time, matrix_data, CapVolSet, X, spolA, first_couponB, notional)

for ii=1:length(CapVolSet.spot_vols(:,1))

CapVolSet.spot_vols(ii,:)=CapVolSet.spot_vols(ii,:)+10^-4; 

V_buck(ii)=NPVcontract(dates, discounts, today, contract_maturities_time, matrix_data, CapVolSet, X, spolA, first_couponB, notional);

CapVolSet.spot_vols(ii,:)=CapVolSet.spot_vols(ii,:)-10^-4; 

end

V_buck=[CapVolSet.maturities';V_buck]; 