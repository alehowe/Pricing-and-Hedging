function vega_bucket_sensitivities= computeVegaBucketSensitivities(contract,instruments_complete,shift, ...
    X, last_index)
% computeVegaBucketSensitivities: computes the vega bucket sensitivities
    %
    % INPUTS:
    % contract: contract details
    % instruments_complete: struct with complete instrument data
    % shift: shift to be applied to the bucket
    % X: Principal amount
    % last_index: Last index of the CapVolSet maturities up to which to vary the flat volatilities
    %
    % OUTPUTS:
    % vega_bucket_sensitivities: vega bucket sensitivities          

if last_index<=length(instruments_complete.caps.maturities)
    % Initialize the vector of sensitivities
    vega_bucket_sensitivities=zeros(last_index, 1);
    
    % Compute NPV of the cap in the normal case 
    NPV=NPVcontract(instruments_complete,contract,X);
    
    % Vary the flat volatilities of 1bp for every bucket and compute the delta
    % NPV
    CapVolSet_mod=instruments_complete.caps;
    
    for ii=1:last_index
    
        CapVolSet_mod.flat_vols(ii,:)=CapVolSet_mod.flat_vols(ii,:)+shift; 
    
        CapVolSet_mod=calibrateSpotVol(instruments_complete.bootstrap, CapVolSet_mod);

        instruments_complete_mod=instruments_complete; 

        instruments_complete_mod.caps=CapVolSet_mod; 

        vega_bucket_sensitivities(ii)=NPVcontract(instruments_complete_mod,contract,X)-NPV;
    
        CapVolSet_mod=instruments_complete.caps; 
    
    end
else
    error('Index out of bounds')
end

end