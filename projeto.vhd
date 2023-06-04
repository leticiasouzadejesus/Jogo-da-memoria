library ieee;
use ieee.std_logic_1164.all;

entity projeto is
  generic (freq: integer := 5); --50MHz = 50000000
  port (
    clock    : in   std_logic; --clock de 50MHz do FPGA
    reset    : in   std_logic; 
	 alavancas: in   std_logic_vector(9 downto 0); 
	 botoes   : in   std_logic_vector(3 downto 0);
	 LEDs     : out  std_logic_vector(3 downto 0);
	 estadoOut: out  std_logic_vector(3 downto 0); --debug
	 display1, display2, display3, display4, display5, display6: out std_logic_vector(7 downto 0)   
  );
end projeto;

architecture arch of projeto is

	component display is
	  port (
		 input: in   std_logic_vector(7 downto 0); -- ASCII 8 bits
		 output: out std_logic_vector(7 downto 0)  -- ponto + abcdefg
	  );
	end component;
	
	-- px = pausa
	-- nx = enesimo led aceso
	type tipo_estado is (inicial, p1, n1, p2, n2, p3, n3, p4, n4, p5, n5, p6, ganhou, perdeu);
	signal estado   : tipo_estado := inicial;
	
	signal count: integer range 0 to freq := 0; --50MHz
	signal clock2, encount, tick : std_logic := '0';

	signal start: std_logic := '0';
	
	type LED_array is array (4 downto 0) of integer range 0 to 3;
	signal LED_s: LED_array := (0,0,0,0,0); --sequencia de LEDs pra acender
	
	signal al_s: std_logic_vector(9 downto 0); -- alavancas acionadas
	
	type n_array is array (9 downto 0) of integer range 0 to 1;
	signal al_int_s: n_array := (0,0,0,0,0,0,0,0,0,0); -- alavancas acionadas convertido em integer
	
	signal respostas: LED_array := (0,0,0,0,0); -- sequencia de botoes pressionados pelo usuario
	signal indice: integer range 0 to 5 := 0 ; --contador de quantos botoes o usuario apertou
	signal pressionando, apertou: std_logic := '0'; -- sinal para que o sistema nao conte mais de 1 vez quando o usuario apertar o botao
	signal botaoPressionado: integer range 0 to 3;
	
	signal letra1, letra2, letra3, letra4, letra5, letra6, 
	digit_o1_inv, digit_o2_inv, digit_o3_inv, digit_o4_inv, digit_o5_inv, digit_o6_inv: std_logic_vector(7 downto 0) := (others => '0');
	
begin

	clock2 <= clock;
			
	process(clock2, encount)
	begin
		if encount = '0' then
			count	  <= 0;
		elsif clock2'event and clock2 = '1' then
			count <= count + 1;
			if count = freq then
				count <= 0;
			end if;
		end if;
	end process;
	
	tick <= '1' when count = freq else '0';
	
	start <= botoes(3) or botoes(2) or botoes(1) or botoes(0); 
	pressionando <= start;
	
	botaoPressionado <=  3 when botoes(3) = '1' else
								2 when botoes(2) = '1' else
								1 when botoes(1) = '1' else
								0 when botoes(0) = '1' else
								0;
	
	encount <= '0' when ((estado = inicial) or (estado = p6) or (estado = ganhou) or (estado = perdeu)) else
				  '1';

	process (clock2, reset) 
	begin
		if reset = '1' then
			estado <= inicial;
			
		elsif clock2'event and clock2 = '1' then
			case estado is
			
				when inicial => if start = '1' and apertou = '0' then 
										 apertou <= '1';
										 estado <= p1;
										 al_s <= alavancas;
									 elsif start = '0' then
										apertou <= '0';
									 else  estado <= inicial;
									 end if;
									 indice <= 0;
				
				when p1 =>   if tick = '1' then 
									estado <= n1;
								 else estado <= p1;
								 end if;
								 LEDs <= (others => '0');
				
				when n1 =>   if tick = '1' then 
									estado <= p2;
								 else estado <= n1;
								 end if;
								 LEDs <= (others => '0');
								 LEDs(LED_s(0)) <= '1';
				
				when p2 =>   if tick = '1' then 
									estado <= n2;
								 else estado <= p2;
								 end if;
								 LEDs <= (others => '0');
				
				when n2 =>   if tick = '1' then 
									estado <= p3;
								 else estado <= n2;
								 end if;
								 LEDs <= (others => '0');
								 LEDs(LED_s(1)) <= '1';
				
				when p3 =>   if tick = '1' then 
									estado <= n3;
								 else estado <= p3;
								 end if;
								 LEDs <= (others => '0');
				
				when n3 =>   if tick = '1' then 
									estado <= p4;
								 else estado <= n3;
								 end if;
								 LEDs <= (others => '0');
								 LEDs(LED_s(2)) <= '1';
				
				when p4 =>   if tick = '1' then 
									estado <= n4;
								 else estado <= p4;
								 end if;
								 LEDs <= (others => '0');
				
				when n4 =>   if tick = '1' then 
									estado <= p5;
								 else estado <= n4;
								 end if;
								 LEDs <= (others => '0');
								 LEDs(LED_s(3)) <= '1';
				
				when p5 =>   if tick = '1' then 
									estado <= n5;
								 else estado <= p5;
								 end if;
								 LEDs <= (others => '0');
				
				when n5 =>   if tick = '1' then 
									estado <= p6;
								 else estado <= n5;
								 end if;
								 LEDs <= (others => '0');
								 LEDs(LED_s(4)) <= '1';
				
				when p6 =>   if pressionando = '1' and apertou = '0' then
									apertou <= '1';
									respostas(indice) <= botaoPressionado;
									indice <= (indice + 1);
								 elsif pressionando = '0' then
									apertou <= '0';
								 end if;
								 if indice = 5 then
									if respostas = LED_s then
										estado <= ganhou;
									else
										estado <= perdeu;
									end if;
								 end if;
								 LEDs <= (others => '0');
								 
				when ganhou => if pressionando = '1' and apertou = '0' then
										estado <= inicial;
										apertou <= '1';
									elsif pressionando = '0' then
										apertou <= '0';
									else
										estado <= ganhou;
									end if;
				
				when perdeu => if pressionando = '1' and apertou = '0' then
										estado <= inicial;
										apertou <= '1';
									elsif pressionando = '0' then
										apertou <= '0';
									else
										estado <= perdeu;
									end if;				
				
				when others => estado <= inicial;
			end case;
		  end if;
		end process;
				
	
	

	estadoOut <= "0000" when estado = inicial else
					 "0001" when estado = p1      else
					 "0010" when estado = n1      else
					 "0011" when estado = p2      else
					 "0100" when estado = n2      else
					 "0101" when estado = p3      else
					 "0110" when estado = n3      else
					 "0111" when estado = p4      else
					 "1000" when estado = n4      else
					 "1001" when estado = p5      else
					 "1010" when estado = n5      else
					 "1011" when estado = p6      else
					 "1100" when estado = ganhou  else
					 "1101" when estado = perdeu    else
					 "1111";
					 		 
		

	al_int_s(0) <= 1 when al_s(0) = '1' else 0;
	al_int_s(1) <= 1 when al_s(1) = '1' else 0;
	al_int_s(2) <= 1 when al_s(2) = '1' else 0;
	al_int_s(3) <= 1 when al_s(3) = '1' else 0;
	al_int_s(4) <= 1 when al_s(4) = '1' else 0;
	al_int_s(5) <= 1 when al_s(5) = '1' else 0;
	al_int_s(6) <= 1 when al_s(6) = '1' else 0;
	al_int_s(7) <= 1 when al_s(7) = '1' else 0;
	al_int_s(8) <= 1 when al_s(8) = '1' else 0;
	al_int_s(9) <= 1 when al_s(9) = '1' else 0;
	

	LED_s <= (al_int_s(0)+al_int_s(1)+al_int_s(2)+al_int_s(3)+al_int_s(4) mod 4,
				 al_int_s(0)+al_int_s(2)+al_int_s(4)+al_int_s(6)+al_int_s(8) mod 4,
				 al_int_s(1)+al_int_s(3)+al_int_s(5)+al_int_s(7)+al_int_s(9) mod 4,
				 al_int_s(9)+al_int_s(8)+al_int_s(7)+al_int_s(6)+al_int_s(5) mod 4,
				 al_int_s(2)+al_int_s(3)+al_int_s(4)+al_int_s(5)+al_int_s(6) mod 4);
				 
				 
	--displays
	-- START, PERDEU, GANHOU
	
	letra1 <= "01010011" when estado = inicial else --S
				 "01010000" when estado = perdeu else --P
				 "01000111" when estado = ganhou else --G
				 "00000000" ;
	
	letra2 <= "01010100" when estado = inicial else --T
				 "01000101" when estado = perdeu else --E
				 "01000001" when estado = ganhou else --A
				 "00000000" ;
	
	letra3 <= "01000001" when estado = inicial else --A
				 "01010010" when estado = perdeu else --R
				 "01001110" when estado = ganhou else --N
				 "00000000" ;
	
	letra4 <= "01010010" when estado = inicial else --R
				 "01000100" when estado = perdeu else --D
				 "01001000" when estado = ganhou else --H
				 "00000000" ;
	
	letra5 <= "01010100" when estado = inicial else --T
				 "01000101" when estado = perdeu else --E
				 "01001111" when estado = ganhou else --O
				 "00000000" ;
	
	letra6 <= "00000000" when estado = inicial else --
				 "01010101" when estado = perdeu else --U
				 "01010101" when estado = ganhou else --U
				 "00000000" ;
				 
	
	disp1: display
	PORT MAP((letra1), digit_o1_inv);
	
	disp2: display
	PORT MAP((letra2), digit_o2_inv);
	
	disp3: display
	PORT MAP((letra3), digit_o3_inv);
	
	disp4: display
	PORT MAP((letra4), digit_o4_inv);
	
	disp5: display
	PORT MAP((letra5), digit_o5_inv);
	
	disp6: display
	PORT MAP((letra6), digit_o6_inv);
	
	display1 <= NOT digit_o1_inv;
	display2 <= NOT digit_o2_inv;
	display3 <= NOT digit_o3_inv;
	display4 <= NOT digit_o4_inv;
	display5 <= NOT digit_o5_inv;
	display6 <= NOT digit_o6_inv;
	
	
    
end architecture;