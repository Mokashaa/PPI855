module fsm_report(y1, jmp,go, clk, rst_n,state);
output y1;
input jmp,go, clk, rst_n;
reg y1;
parameter [3:0]
S0 = 4'b0000,
S1 = 4'b0001,
S2 = 4'b0010,
S3 = 4'b0011, 
S4 = 4'b0100,
S5 = 4'b0101,
S6 = 4'b0110,
S7 = 4'b0111,
S8 = 4'b1000,
S9 = 4'b1001;

output reg [3:0] state;
reg [3:0]next;
always @(posedge clk or negedge rst_n)
if (!rst_n) state <= S0;
else state <= next;
always @(state or jmp or go) begin
next=4'b0000;
y1 <= 1'b0;
case (state)
S0 : 
if (go && !jmp) next <= S1;
else if(go && jmp) next <= S3; 
else  next <= S0;
S1: begin
if (!jmp) next <= S2;
else if(jmp) next <= S3; 
end
S2: begin
next <= S3;
end	
S3: begin
y1=1;
if (jmp) next <= S3;
else if(!jmp) next <= S4; 
end		
S4: begin
y1=0;
if (jmp) next <= S3;
else if(!jmp) next <= S5; 
end	
S5: begin
y1=0;
if (jmp) next = S3;
else if(!jmp) next = S6; 
end	
S6: begin
y1=0;
if (jmp) next = S3;
else if(!jmp) next = S7; 
end	 
S7: begin
y1=0;
if (jmp) next = S3;
else if(!jmp) next = S8; 
end	
S8: begin
y1=0;
if (jmp) next = S3;
else if(!jmp) next = S9; 
end	
S9: begin
y1=1;
if (jmp) next = S3;
else if(!jmp) next = S0; 
end
endcase
end
endmodule


module FSM_tb();
reg jmp,go, clk, rst_n;
wire y1;
wire [3:0]state;
fsm_report v(y1, jmp,go, clk, rst_n,state);
initial
begin
$monitor("go =%d , jmp =%d, y1=%d ,state=%d",go,jmp,y1,state);
clk = 0;
rst_n = 0;

#25 rst_n = 1;
#10
go<=1;
jmp<=0;
#10
jmp<=0;
#10
jmp<=0;
#10
jmp<=1;
#10
jmp<=0;
#10
jmp<=1;
#10
jmp<=0;
#10
jmp<=0;
#10
jmp<=0;
#10
jmp<=0;
#10
jmp<=0;

end
always 
	begin
#5 clk = !clk; 
end
//Rest of testbench code after this line

endmodule	   

	

