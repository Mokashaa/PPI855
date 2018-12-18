 module PPI8255 (PORTA,PORTB,PORTCU,PORTCL,PORTD,RD,WR,CS,A0,A1,Reset);

//Ports A,B,C, and Data bus D;
inout [7:0] PORTA;
inout [7:0] PORTB;
inout [3:0] PORTCU;
inout [3:0] PORTCL;
inout [7:0] PORTD;

//registers of the Ports and the data bus;
reg [7:0] A;
reg [7:0] B;
reg [7:0] C;
reg [7:0] D;
reg [7:0] DataBus;
reg [7:0] CNTRLREG;
reg [7:0] IOCNTRLREG;//to save the value of CNTRLREG when being in BSR mode


integer DoneRD=0;//flag to indicate that in an input is deliverd to data bus
integer RDnotWR=0;//to choose the direction of PORTD
//Control Pins;
input Reset, A0, A1, RD, WR, CS;

assign PORTA = ((IOCNTRLREG[4]==1'b0)&& (~Reset) && IOCNTRLREG[7]==1)? A : 8'bzzzzzzzz;
assign PORTB = ((IOCNTRLREG[1]==1'b0)&& (~Reset) && IOCNTRLREG[7]==1)? B : 8'bzzzzzzzz;
assign PORTCU = (((CNTRLREG[3]==1'b0 && CNTRLREG[0]==1'b0 && CNTRLREG[7]==1 )|| CNTRLREG[7]==0)&& (~Reset))? C[7:4] : (((CNTRLREG[3]==1'b0 &&  CNTRLREG[7]==1 )|| CNTRLREG[7]==0)&& (~Reset))? C[3:0] :8'bzzzzzzzz;
assign PORTCL = (((CNTRLREG[0]==1'b0 && CNTRLREG[3]==1'b0 && CNTRLREG[7]==1 )|| CNTRLREG[7]==0)&& (~Reset))? C[3:0] : (((CNTRLREG[0]==1'b0 &&  CNTRLREG[7]==1 )|| CNTRLREG[7]==0)&& (~Reset))? C[3:0] :8'bzzzzzzzz;
assign PORTD = (RDnotWR==1)? D : 8'bzzzzzzzz;




always @ (PORTA,PORTB,PORTCU,PORTCL,PORTD,RD,WR,CS,A0,A1,Reset)
begin
if(!CS)//1
begin
   if (!WR)//write case
   begin
   RDnotWR<=0;
   if ( (A0 == 1) && (A1 == 1) )//entering control word
   begin
   CNTRLREG<=PORTD;
   IOCNTRLREG<=(CNTRLREG[7])?CNTRLREG:IOCNTRLREG;
   end


   else 
   begin//outputting data on a port
   DataBus<=PORTD;

   if ( (A0 == 0) && (A1 == 0) && (IOCNTRLREG[4]==1'b0)  )//PORTA output
   begin
   A<=DataBus;

   end
   else if ( (A0 == 0) && (A1 == 1) && (IOCNTRLREG[1]==1'b0) )//PORTB output
   begin
   B<=DataBus;

   end
else if ( (A0 == 1) && (A1 == 0) &&(CNTRLREG[0]==1'b0) &&(CNTRLREG[3]==1'b0) )//PORTCU,L output
begin
C<=DataBus;

end
else if ( (A0 == 1) && (A1 == 0) &&(CNTRLREG[0]==1'b0) )//PORTCL output
begin
C<=DataBus;

end
else if ( (A0 == 1) && (A1 == 0) &&(CNTRLREG[3]==1'b0) )//PORTCU output
begin
C<=DataBus;

end

end
  

end//end of write case
else if ((!RD))//read case
begin
RDnotWR<=1;
if ( (A0 == 0) && (A1 == 0) && (IOCNTRLREG[4]==1'b1)  )//read from PORTA
begin
DataBus<=PORTA;
DoneRD<=1;
end
else if ( (A0 == 0) && (A1 == 1) && (IOCNTRLREG[1]==1'b1) )//read from PORTB
begin
DataBus<=PORTB;
DoneRD<=1;
end
else if ( (A0 == 1) && (A1 == 0) &&(CNTRLREG[0]==1'b1) &&(CNTRLREG[3]==1'b1) ) //read from PORTC
begin
DataBus<={PORTCU,PORTCL};
DoneRD<=1;
end
else if ( (A0 == 1) && (A1 == 0) &&(CNTRLREG[0]==1'b1) )//read from PORTCL
begin
DataBus<=PORTCL;
DoneRD<=1;
end
else if ( (A0 == 1) && (A1 == 0) &&(CNTRLREG[3]==1'b1) )//read from PORTCU
begin
DataBus<=PORTCU;
DoneRD<=1;
end

end//end of read case


end // 1
end //always block end
//this always block delivers inputs from data bus to PORTD when done reading is indicated
always @ (posedge DoneRD)
begin
D<=DataBus;
DoneRD<=0;
end
//RESET

always @ (posedge Reset )
begin
if(!CS)
begin

CNTRLREG<=8'b10011011;
IOCNTRLREG<=8'b10011011;

end
end
//BSR MODE
always @ (CNTRLREG)
begin
if(!CS)
begin
if(CNTRLREG[7]==0)
begin
casex (CNTRLREG)
8'bxxxx000x:C[0]<=CNTRLREG[0];
8'bxxxx001x:C[1]<=CNTRLREG[0];
8'bxxxx010x:C[2]<=CNTRLREG[0];
8'bxxxx011x:C[3]<=CNTRLREG[0];
8'bxxxx100x:C[4]<=CNTRLREG[0];
8'bxxxx101x:C[5]<=CNTRLREG[0];
8'bxxxx110x:C[6]<=CNTRLREG[0];
8'bxxxx111x:C[7]<=CNTRLREG[0];

endcase
end
end

end



endmodule 


module tb_ppi_ic;
//input/output ports
wire [7:0] PORTA;
wire [7:0] PORTB;
wire [3:0] PORTCU;
wire [3:0] PORTCL;
wire [7:0] DataBus;
//registers for each port
reg [7:0] D_control;
reg [7:0] D_data;
reg [7:0] A;
reg [7:0] B;
reg [3:0] CU;
reg [3:0] CL;
//selection ports
reg CS, RD, WR,A1,A0, Reset;


assign DataBus = (A0==1&&A1==1&& WR == 0 && ~Reset)? D_control : (WR==0 && ~Reset)? D_data : 8'bzzzzzzzz;
assign PORTA = (RD==0 && D_control[4] == 1)? A : 8'bzzzzzzzz;
assign PORTB = (RD==0 && D_control[1] == 1)? B : 8'bzzzzzzzz;
assign PORTCU = (RD==0 && D_control[3] == 1)? CU : 4'bzzzz;
assign PORTCL = (RD==0 && D_control[0] == 1)? CL : 4'bzzzz;

initial
begin
Reset=0;
$monitor($time ,,,"Reset = %b  CS = %b  RD = %b  WR = %b  A0 = %b A1 = %b  PORTA = %b  PORTB = %b  PORTCU = %b  PORTCL = %b  DataBus = %b \n",Reset, CS, RD, WR, A1,A0,PORTA,PORTB,PORTCU,PORTCL,DataBus);
//Mode 0 basic Input:

//Case 0: PORTA:Output, PORTB:Output, PORTCU:Output, PORTCL:Output
//Control Word Cycle: time = 0
#5
$display("CASE0\n");
Reset = 0;
CS = 0;
A1 = 1;
A0 = 1;
RD = 1;
WR = 0;
D_control = 8'b10000000;
#5 CS=0; #5 
//Selecting PORT A to be Output
Reset = 0;
CS = 0;
A1 = 0;
A0 = 0;
RD = 1;
WR = 0;
D_data = 8'b11111111;
#5 CS=0; #5
//Selecting PORT B to be Output
Reset = 0;
CS = 0;
A1 = 0;
A0 = 1;
RD = 1;
WR = 0;
D_data = 8'b11110111;
#5 CS=0; #5
//Selecting PORTCU and PORTCL to be Output
Reset = 0;
CS = 0;
A1 = 1;
A0 = 0;
RD = 1;
WR = 0;
D_data = 8'b00001111;
#5 CS=0; #5

//Case 1: PORTA:Output, PORTB:Output, PORTCU:Output, PORTCL:Input:
//Control Word Cycle
$display("CASE1\n");
Reset = 0;
CS = 0;
A1 = 1;
A0 = 1;
RD = 1;
WR = 0;
D_control = 8'b10000001;
#5 CS=0; #5
//Selecting PORTCL to be Input
Reset = 0;
CS = 0;
A1 = 1;
A0 = 0;
RD = 0;
WR = 1;
CL = 4'b1001;
#5 CS=0; #5
//NOTICE THAT: we haven't changed the output on PORTS A,B,CU to show you that the output is latched :'D

//Case 2: PORTA:Output, PORTB:Input, PORTCU:Output, PORTCL:Output
//Control Word Cycle
$display("CASE2\n");
Reset = 0;
CS = 0;
A1 = 1;
A0 = 1;
RD = 1;
WR = 0;
D_control = 8'b10000010;
#5 CS=0; #5
//Selecting PORTA to be Output
Reset = 0;
CS = 0;
A1 = 0;
A0 = 0;
RD = 1;
WR = 0;
D_data = 8'b10101010;
#5 CS=0; #5
//Selecting PORTB to be Input
Reset = 0;
CS = 0;
A1 = 0;
A0 = 1;
RD = 0;
WR = 1;
B = 8'b11001100;
#5 CS=0; #5
//Selecting PORTC to be Output
Reset = 0;
CS = 0;
A1 = 1;
A0 = 0;
RD = 1;
WR = 0;
D_data = 8'b10011001;
#5 CS=0; #5
//NOTICE THAT:  in 6,7, and 9; PORTB has a high impedance because the input is NOT latched :'D

//Case 3: PORTA:Output, PORTB:Input, PORTCU:Output, PORTCL:Input
//Control Word Cycle
$display("CASE3\n");
Reset = 0;
CS = 0;
A1 = 1;
A0 = 1;
RD = 1;
WR = 0;
D_control = 8'b10000011;
#5 CS=0; #5
//Selecting PORTA to be Output
Reset = 0;
CS = 0;
A1 = 0;
A0 = 0;
RD = 1;
WR = 0;
D_data = 8'b11111111;
#5 CS=0; #5
//Selecting PORTB to be Input
Reset = 0;
CS = 0;
A1 = 0;
A0 = 1;
RD = 0;
WR = 1;
B = 8'b11001100;
#5 CS=0; #5
//Selecting PORTCL to be Input
Reset = 0;
CS = 0;
A1 = 1;
A0 = 0;
RD = 0;
WR = 1;
CL = 4'b1100;
#5 CS=0; #5
//Selecting PORTCU to be Output
Reset = 0;
CS = 0;
A1 = 1;
A0 = 0;
RD = 1;
WR = 0;
D_data = 8'b11110101;
#5 CS=0; #5

//Case 4: PORTA:Output, PORTB:Output, PORTCU:Input, PORTCL:Output:
//Control Word Cycle
$display("CASE4\n");
Reset = 0;
CS = 0;
A1 = 1;
A0 = 1;
RD = 1;
WR = 0;
D_control = 8'b10001000;
#5 CS=0; #5
//NOTICE THAT: we'll leave the output same as it is on PORTA (Latched)
//Setting PORTB to be Output
Reset = 0;
CS = 0;
A1 = 0;
A0 = 1;
RD = 1;
WR = 0;
D_data = 8'b00001111;
#5 CS=0; #5
//Setting PORTCL to be Output
Reset = 0;
CS = 0;
A1 = 1;
A0 = 0;
RD = 1;
WR = 0;
D_data = 8'b00001101;
#5 CS=0; #5
//Setting PORTCU to be Input
Reset = 0;
CS = 0;
A1 = 1;
A0 = 0;
RD = 0;
WR = 1;
CU = 4'b1111;
#5 CS=0; #5

//Case 5: PORTA:Output, PORTB:Output, PORTC:Input
//Control Word Cycle
$display("CASE5\n");
Reset = 0;
CS = 0;
A1 = 1;
A0 = 1;
RD = 1;
WR = 0;
D_control = 8'b10001001;
#5 CS=0; #5
//NOTICE THAT: we'll leave the output same as it is on PORTA and PORTB (latched)
//Setting PORTC to be Input
Reset = 0;
CS = 0;
A1 = 1;
A0 = 0;
RD = 0;
WR = 1;
CU = 4'b1010;
CL = 4'b1010;
#5 CS=0; #5

//Case 6: PORTA:Output, PORTB:Input, PORTCL:Output, PORTCU:Input
//Control Word Cycle
$display("CASE6\n");
Reset = 0;
CS = 0;
A1 = 1;
A0 = 1;
RD = 1;
WR = 0;
D_control = 8'b10001010;
#5 CS=0; #5
//Setting PORTB to be Input
Reset = 0;
CS = 0;
A1 = 0;
A0 = 1;
RD = 0;
WR = 1;
B = 8'b11110000;
#5 CS=0; #5
//Setting PORTCL to be Output
Reset = 0;
CS = 0;
A1 = 1;
A0 = 0;
RD = 1;
WR = 0;
D_data = 8'b11111000;
#5 CS=0; #5
//Setting PORTCU to be Input
Reset = 0;
CS = 0;
A1 = 1;
A0 = 0;
RD = 0;
WR = 1;
CU = 4'b0000;
#5 CS=0; #5

//Case 7: PORTA:Output, PORTB:Input, PORTC:Input
//Control Word Cycle
$display("CASE7\n");
Reset = 0;
CS = 0;
A1 = 1;
A0 = 1;
RD = 1;
WR = 0;
D_control = 8'b10001011;
#5 CS=0; #5
//Setting PORTB to be input
Reset = 0;
CS = 0;
A1 = 0;
A0 = 1;
RD = 0;
WR = 1;
B = 8'b11110000;
#5 CS=0; #5
//Setting PORTC to be input
Reset = 0;
CS = 0;
A1 = 1;
A0 = 0;
RD = 0;
WR = 1;
CU = 4'b1010;
CL = 4'b1010;
#5 CS=0; #5

//case 8
$display("CASE8\n");
//Control Word Cycle:
CS = 0;
A1=1;
A0=1;
RD = 1;
WR = 0;
D_control = 8'b10010000;
#5 CS=0; #5
//Inputting Data Cycle:PORTA
CS = 0;
A1=0;
A0=0;
RD = 0;
WR = 1;
A = 8'b11111111;
#5 CS=0; #5
//Outputting Data Cycle:PORTB
CS = 0;
A1=0;
A0=1;
RD = 1;
WR = 0;
D_data= 8'b00000000;
#5 CS=0; #5

//Outputting Data Cycle:PORTCL
CS = 0;
A1=1;
A0=0;
RD = 1;
WR = 0;
D_data= 8'b00000000;
#5 CS=0; #5
//Outputting Data Cycle:PORTCU
CS = 0;
A1=1;
A0=0;
RD = 1;
WR = 0;
D_data= 8'b00000000;
#5 CS=0; #5
//case 9
$display("CASE9\n");
//Control Word Cycle:
CS = 0;
A1=1;
A0=1;
RD = 1;
WR = 0;
D_control = 8'b10010001;
#5 CS=0; #5
//Inputting Data Cycle:PORTCL
CS = 0;
A1=1;
A0=0;
RD = 0;
WR = 1;
CL = 8'b11111111;
#5 CS=0; #5
//case10
$display("CASE10\n");
//Control Word Cycle:
CS = 0;
A1=1;
A0=1;
RD = 1;
WR = 0;
D_control = 8'b10010010;
#5 CS=0; #5
//Inputting Data Cycle:PORTB
CS = 0;
A1=0;
A0=1;
RD = 0;
WR = 1;
B = 8'b11111111;
#5 CS=0; #5
//Outputting Data Cycle:PORTCL
CS = 0;
A1=1;
A0=0;
RD = 1;
WR = 0;
D_data= 8'b00000000;
#5 CS=0; #5
//case11
$display("CASE11\n");
//Control Word Cycle:
CS = 0;
A1=1;
A0=1;
RD = 1;
WR = 0;
D_control = 8'b10010011;
#5 CS=0; #5
//Inputting Data Cycle:PORTCL
CS = 0;
A1=1;
A0=0;
RD = 0;
WR = 1;
CL = 8'b11111111;
#5 CS=0; #5
//case12
$display("CASE12\n");
//Control Word Cycle:
CS = 0;
A1=1;
A0=1;
RD = 1;
WR = 0;
D_control = 8'b10011000;
#5 CS=0; #5
//Inputting Data Cycle:PORTCU
CS = 0;
A1=1;
A0=0;
RD = 0;
WR = 1;
CU = 8'b11111111;
#5 CS=0; #5
//Outputting Data Cycle:PORTB
CS = 0;
A1=0;
A0=1;
RD = 1;
WR = 0;
D_data= 8'b00000000;
#5 CS=0; #5
//Outputting Data Cycle:PORTCL
CS = 0;
A1=1;
A0=0;
RD = 1;
WR = 0;
D_data= 8'b00000000;
#5 CS=0; #5

//Case 13: PORTA:Input, PORTB:Output, PORTCU:Input, PORTCL:Input
//Control Word Cycle
$display("CASE13\n");
Reset = 0;
CS = 0;
A1 = 1;
A0 = 1;
RD = 1;
WR = 0;
D_control = 8'b10011001;
#5 CS=0; #5
//Selecting PORT A to be input
Reset = 0;
CS = 0;
A1 = 0;
A0 = 0;
RD = 0;
WR = 1;
A = 8'b11111111;
#5 CS=0; #5
//Selecting PORTB to be Output
Reset = 0;
CS = 0;
A1 = 0;
A0 = 1;
RD = 1;
WR = 0;
D_data = 8'b11110111;
#5 CS=0; #5
//Selecting PORTCU and PORTCL to be input
Reset = 0;
CS = 0;
A1 = 1;
A0 = 0;
RD = 0;
WR = 1;
CL = 4'b1111;
CU = 4'b0000;
#5 CS=0; #5

//Case 14: PORTA:Input, PORTB:Input, PORTCU:Input, PORTCL:Output
//Control Word Cycle
$display("CASE14\n");
Reset = 0;
CS = 0;
A1 = 1;
A0 = 1;
RD = 1;
WR = 0;
D_control = 8'b10011010;
#5 CS=0; #5
//Selecting PORTA to be input
Reset = 0;
CS = 0;
A1 = 0;
A0 = 0;
RD = 0;
WR = 1;
A = 8'b11111111;
#5 CS=0; #5
//Selecting PORTB to be input
Reset = 0;
CS = 0;
A1 = 0;
A0 = 1;
RD = 0;
WR = 1;
B = 8'b11110111;
#5 CS=0; #5
//Selecting PORTCU to be input
Reset = 0;
CS = 0;
A1 = 1;
A0 = 0;
RD = 0;
WR = 1;
CU = 4'b0000;
#5 CS=0; #5
//Selecting PORTCL to be Output
Reset = 0;
CS = 0;
A1 = 1;
A0 = 0;
RD = 1;
WR = 0;
D_data = 4'b0000;
#5 CS=0; #5

//Case 15: PORTA:Input, PORTB:Input, PORTCU:Input, PORTCL:Input
//Control Word Cycle
$display("CASE15\n");
Reset = 0;
CS = 0;
A1 = 1;
A0 = 1;
RD = 1;
WR = 0;
D_control = 8'b10011011;
#5 CS=0; #5
//Selecting PORTA to be input
Reset = 0;
CS = 0;
A1 = 0;
A0 = 0;
RD = 0;
WR = 1;
A = 8'b11111111;
#5 CS=0; #5
//Selecting PORTB to be input
Reset = 0;
CS = 0;
A1 = 0;
A0 = 1;
RD = 0;
WR = 1;
B = 8'b11110111;
#5 CS=0; #5
//Selecting PORTCU and PORTCL to be input
Reset = 0;
CS = 0;
A1 = 1;
A0 = 0;
RD = 0;
WR = 1;
CU = 4'b1111;
CL = 4'b0000;
#5 CS=0; #5
//BSR Mode
$display("BSR MODE");
//NOTICE THAT: we're entering BSR mode and PORTA,PORTB were inputs, so they shall remain inputs as they are
//Setting bit 3 in PORTC
//Control Word Cycle
Reset =0;
CS = 0;
A0 = 1;
A1 = 1;
RD = 1;
WR = 0;
D_control = 8'b00000111;
#5 CS=0; #5
//Resetting bit 7 in PORTC
//Control Word Cycle
Reset =0;
CS = 0;
A0 = 1;
A1 = 1;
RD = 1;
WR = 0;
D_control = 8'b00001110;
#5 CS=0; #5
//Setting bit 4 in PORTC
//Control Word Cycle
Reset = 0;
CS = 0;
A0 = 1;
A1 = 1;
RD = 1;
WR = 0;
D_control = 8'b00001001;
#5 CS=0; #5
//Resetting bit 6 in PORTC
//Control Word Cycle
Reset = 0;
CS = 0;
A0 = 1;
A1 = 1;
RD = 1;
WR = 0;
D_control = 8'b00001100;
#5 CS=0; #5
//Using PORTA as Input
Reset = 0;
CS = 0;
A0 = 0;
A1 = 0;
RD = 0;
WR = 1;
A = 8'b10001000;
#5 CS=0; #5
//Using PORTB as Input: time = 46
Reset = 0;
CS = 0;
A1 = 0;
A0 = 1;
RD = 0;
WR = 1;
B = 8'b01110111;
#5 CS=0; #5
//NOTICE THAT: we'll change PORTA, and PORTB to be Outputs and we'll enter BSR mode and check that they stay Outputs as they are:
//Control word cycle
Reset = 0;
CS = 0;
A1 = 1;
A0 = 1;
RD = 1;
WR = 0;
D_control = 8'b10000000;
#5 CS=0; #5
//Selecting PORTA to be Output
Reset = 0;
CS = 0;
A1 = 0;
A0 = 0;
RD = 1;
WR = 0;
D_data = 8'b10101111;
#5 CS=0; #5
//Selecting PORTB to be Output
Reset = 0;
CS = 0;
A1 = 0;
A0 = 1;
RD = 1;
WR = 0;
D_data = 8'b11111111;
#5 CS=0; #5
//Selecting PORTCU,L to be Output
Reset = 0;
CS = 0;
A1 = 1;
A0 = 0;
RD = 1;
WR = 0;
D_data = 8'b11001110;
#5 CS=0; #5
//Control Word Cycle: BSR MODE
//Setting Bit 0 in PORTC:
Reset = 0;
CS = 0;
A1 = 1;
A0 = 1;
RD = 1;
WR = 0;
D_control = 8'b00000001;
#5 CS=0; #5
//Resetting bit 1 in PORTC
Reset = 0;
CS = 0;
A1 = 1;
A0 = 1;
RD = 1;
WR = 0;
D_control = 8'b00000010;
#5 CS=0; #5
//NOTICE THAT: The Outputs on PORTA and PORTB are the same.

//RESET Test
//Reset Puts all Ports in Input mode and clears the data bus
Reset = 1;



end


PPI8255 X(PORTA,PORTB,PORTCU,PORTCL,DataBus,RD,WR,CS,A1,A0,Reset);
endmodule



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

	


