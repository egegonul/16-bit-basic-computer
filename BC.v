module BC( CLK,SC,AR,PC,DR,AC,IR,E);
input CLK;
output reg [11:0] AR;
output reg [11:0] PC;
output reg [15:0] IR;
reg [15:0] TR;
output reg [15:0] DR;
output reg [15:0] AC;
output reg [3:0] SC;
reg [15:0] M [4095:0]; //the memory (4096 words, 16 bits)
output reg E;
reg I,S;
wire D[7:0];
wire T[7:0];

//DECODE OPR
//decoder3(IR[14:12],D);
//DECODE SC
//decoder3(SC,T);
initial begin
//start the computer
S<=1; 
//random PC initialization
PC<=12'h100;
//random initial AC
AC<=16'h3625;
//some memory initialization containing instructions
M[12'h100]<=16'h0600;
M[12'h101]<=16'h7002;
M[12'h102]<=16'h1600;
M[12'h103]<=16'h2700;
M[12'h104]<=16'h7010;
M[12'h105]<=16'h6323;
M[12'h106]<=16'h7040;

//some memory initialization containing operands
M[12'h600]<=16'h7653;
M[12'h700]<=16'h7439;
end


always @(posedge CLK)
begin
if(S) begin
	SC<=SC+1;
		case(SC)
		// FETCH CYCLE
			0: AR<=PC;
			1:begin IR<=M[AR]; PC<=PC+1; end
			2:begin AR<=IR[11:0]; I<=IR[15]; end
			3: if(IR[14:12]!=7&I)
					AR<=M[AR];
			endcase
		//EXECUTION CYCLE
		if(~(IR[14:12]==7)) begin
			//Memory Reference Instructions
			casex(IR[14:12])
				//AND
				0:begin
					if(SC==4) DR<=M[AR];
					else if(SC==5)begin AC<=AC&DR;SC<=0; end
					end
				//ADD
				1:begin
					if(SC==4) DR<=M[AR];
					else if(SC==5) begin {E,AC}<=AC+DR; SC<=0; end 
					end
				// LDA
				2:begin
					if(SC==4) DR<=M[AR];
					else if(SC==5) begin AC<=DR; SC<=0; end
					end
				//STA
				3: if(SC==4) begin M[AR]<=AC; SC<=0; end
				//BUN
				4: if(SC==4) begin PC<=AR; SC<=0; end
				//BSA
				5:begin
					if(SC==4) begin M[AR]<=PC; AR<=AR+1; end
					else if(SC==5) begin PC<=AR; SC<=0; end
					end
				//ISZ
				6:begin
					if(SC==4) DR<=M[AR];
					if(SC==5) DR<=DR+1;
					if(SC==6) begin
						M[AR]<=DR;
						if(DR==0)
							PC<=PC+1;
						SC<=0;
					end
				  end
			endcase
		end
			else if((IR[15:12]==7)&(SC==4)) begin
			//Register Reference Instructions
				casex(IR[11:0])
				12'h001:S<=0; //HLT
				12'h002:if(~E) PC<=PC+1; //SZE
				12'h004:if(AC==0) PC<=PC+1; //SZA
				12'h008:if(AC[15]) PC<=PC+1; //SNA
				12'b000000010000:if(~AC[15]) PC<=PC+1; //SPA
				12'b000000100000:begin AC<=AC+1; if(AC==16'hFFFF) E<=1; end  //INC
				12'b000001000000:begin AC<={AC[14:0],E}; E<=AC[15]; end //SHL
				12'b000010000000:begin AC<={E,AC[15:1]}; E<=AC[0]; end  //SHR
				12'b000100000000:E<=~E;  //CME
				12'b001000000000:AC<=~AC;  //CMA
				12'b010000000000:E<=0;  //CLE
				12'b100000000000:AC<=0;  //CLA
				endcase
				SC<=0;
			end
				
end	
				
end

			
 			
			
endmodule	