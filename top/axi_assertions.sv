//=============================================================================================
// Module: axi_assertions
// Description: AXI assertion module for formal verification of the AXI protocol.
//              Utilizes the complete AXI interface instead of individual port connections.
//              Implements a limited set of assertions for testing.
//              For additional AXI assertions, refer to: developer.arm.com
//=============================================================================================
module axi_assertions(axi_intf pif);
    
    //----> Write Address Handshaking Property
    //      Ensures AWVALID is followed by AWREADY within 0 to 3 clock cycles
    property WA_HSK_PROP;
        @(posedge pif.aclk) pif.awvalid |-> ##[0:3] pif.awready==1;
    endproperty

    //----> Write Response Handshaking Property
    //      Ensures BVALID is followed by BREADY within 0 to 3 clock cycles
    property WR_HSK_PROP;
        @(posedge pif.aclk) pif.bvalid |-> ##[0:3] pif.bready==1;
    endproperty

    //----> AWID Stability Property
    //      Verifies AWID remains stable when AWVALID is LOW
    property AWID_STABLE_PROP;
        @(posedge pif.aclk) !pif.awvalid |-> $stable(pif.awid);
    endproperty
    
    //----> AWID Validity Property
    //      Ensures AWID is not unknown (X) when AWVALID is HIGH
    property AWID_NOT_X;
        @(posedge pif.aclk) pif.awvalid |-> !$isunknown(pif.awid);
    endproperty
    
    //-----------------< Assert Property >-------------------------
    //      Asserts for verifying the defined properties
    WA_HSK_CHECK : assert property (WA_HSK_PROP);
    WR_HSK_CHECK : assert property (WR_HSK_PROP);
    AWID_STABLE_CHECK : assert property (AWID_STABLE_PROP);
    AWID_NOT_X_CHECK : assert property (AWID_NOT_X);

    //-----------------< Cover Property >--------------------------
    //      Coverage points for the defined properties
    cover property (WA_HSK_PROP);
    cover property (WR_HSK_PROP);
    cover property (AWID_STABLE_PROP);
    cover property (AWID_NOT_X);
  
endmodule
//=============================================================================================
