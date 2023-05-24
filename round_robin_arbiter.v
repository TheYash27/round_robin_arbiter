module round_robin_arbiter (
  clock,    
  reset,    
  req3,   
  req2,   
  req1,   
  req0,   
  gra3,   
  gra2,   
  gra1,   
  gra0   
);
// PORT DECLARATION
input clock, reset;    //CLOCK
input req3;   //REQUEST SIGNALS
input req2;   
input req1;   
input req0;   
output gra3;   //GRANT SIGNALS
output gra2;   
output gra1;   
output gra0;   

//INTERNAL REGISTERS
wire [1:0] gra;   
wire comreq;    
wire beg;   // BEGIN SIGNAL
wire [1:0] latgra;  // LATCHED ENCODED GRANT
wire lcomreq;  // BUS STATUS
reg  latgra0;  // LATCHED GRANTS
reg  latgra1;
reg  latgra2;
reg  latgra3;
reg  masena;
reg  latmas0;
reg  latmas1;

always @(posedge clock)
  if (reset) begin
    latgra0 <= 0;
    latgra1 <= 0;
    latgra2 <= 0;
    latgra3 <= 0;
  end 
  else begin                                     
    latgra0 <=(~lcomreq & ~latmas1 & ~latmas0 & ~req3 & ~req2 & ~req1 & req0)
            | (~lcomreq & ~latmas1 &  latmas0 & ~req3 & ~req2 &  req0)
            | (~lcomreq &  latmas1 & ~latmas0 & ~req3 &  req0)
            | (~lcomreq &  latmas1 &  latmas0 & req0  )
            | ( lcomreq & latgra0 );
        
    latgra1 <=(~lcomreq & ~latmas1 & ~latmas0 &  req1)
            | (~lcomreq & ~latmas1 &  latmas0 & ~req3 & ~req2 &  req1 & ~req0)
            | (~lcomreq &  latmas1 & ~latmas0 & ~req3 &  req1 & ~req0)
            | (~lcomreq &  latmas1 &  latmas0 &  req1 & ~req0)
            | ( lcomreq &  latgra1);
        
    latgra2 <=(~lcomreq & ~latmas1 & ~latmas0 &  req2  & ~req1)
            | (~lcomreq & ~latmas1 &  latmas0 &  req2)
            | (~lcomreq &  latmas1 & ~latmas0 & ~req3 &  req2  & ~req1 & ~req0)
            | (~lcomreq &  latmas1 &  latmas0 &  req2 & ~req1 & ~req0)
            | ( lcomreq &  latgra2);
        
    latgra3 <=(~lcomreq & ~latmas1 & ~latmas0 & req3  & ~req2 & ~req1)
            | (~lcomreq & ~latmas1 &  latmas0 & req3  & ~req2)
            | (~lcomreq &  latmas1 & ~latmas0 & req3)
            | (~lcomreq &  latmas1 &  latmas0 & req3  & ~req2 & ~req1 & ~req0)
            | ( lcomreq & latgra3);
  end 

assign beg = (req3 | req2 | req1 | req0) & ~lcomreq; 

assign lcomreq = ( req3 & latgra3 ) | ( req2 & latgra2 ) | ( req1 & latgra1 ) | ( req0 & latgra0 );

assign  latgra =  {(latgra3 | latgra2), (latgra3 | latgra1)};

always @(posedge clock)
    if( reset ) begin
        latmas1 <= 0;
        latmas0 <= 0;
    end 
    else if(masena) begin
        latmas1 <= latgra[1];
        latmas0 <= latgra[0];
    end 
    else begin
        latmas1 <= latmas1;
        latmas0 <= latmas0;
    end 

    assign comreq = lcomreq;
    assign gra    = latgra;

    assign gra3   = latgra3;
    assign gra2   = latgra2;
    assign gra1   = latgra1;
    assign gra0   = latgra0;

endmodule

module Round_Robin_Arbiter_Test_Bench ();

reg clock;    
reg reset;    
reg req3;   
reg req2;   
reg req1;   
reg req0;   
wire gra3;   
wire gra2;   
wire gra1;   
wire gra0;  

// Clock generator
always #1 clock = ~clock;

initial begin
  $dumpfile ("round_robin_arbiter.vcd");
  $dumpvars();
  clock = 0; reset = 1; req0 = 0; req1 = 0; req2 = 0; req3 = 0;
  #10 reset = 0;
  repeat (1) @(posedge clock);
  req0 <= 0;
  req1 <= 0;
  req2 <= 0;
  req3 <= 1;
  repeat (1) @(posedge clock);
  req0 <= 0;
  req1 <= 0;
  req2 <= 1;
  req3 <= 1;
  repeat (1) @(posedge clock);
  req0 <= 0;
  req1 <= 1;
  req2 <= 1;
  req3 <= 1;
  repeat (1) @(posedge clock);
  req0 <= 1;
  req1 <= 1;
  req2 <= 1;
  req3 <= 1;
  repeat (1) @(posedge clock);
  req0 <= 1;
  req1 <= 1;
  req2 <= 1;
  req3 <= 0;
  repeat (1) @(posedge clock);
  req0 <= 1;
  req1 <= 1;
  req2 <= 0;
  req3 <= 0;
  repeat (1) @(posedge clock);
  req0 <= 1;
  req1 <= 0;
  req2 <= 0;
  req3 <= 0;
  repeat (1) @(posedge clock)
  req0 <= 0;
  req1 <= 0;
  req2 <= 0;
  req3 <= 0;
  repeat (1) @(posedge clock)
  #10 $finish;
end 

// Connect the DUT
round_robin_arbiter dut (
    clock,    
    reset,    
    req3,   
    req2,   
    req1,   
    req0,   
    gra3,   
    gra2,   
    gra1,   
    gra0   
);

endmodule