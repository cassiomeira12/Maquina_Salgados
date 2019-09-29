--Projeto de Circuitos Digitais
--Alunos: Cassio Meira Silva
--		  	 Dionleno Silva Oliveira
--Inicio  30/10/17
--Termino 24/11/17


library IEEE; --Adicionadno Biblioteca IEEE
use IEEE.std_logic_1164.all; --Incluindo toda a biblioteca do padrao 1164


entity Maquina is --Declaracao da Entidade
port (
		liberar: in std_logic; 		  --Libera o salgado no estado_final
		
		--Entradas do Programa
		clk: in std_logic;     --Entrada de Clock de 27MHz
		iniciar: in std_logic; --Inicia a maquina
		reset: in std_logic;   --Resetar maquina e voltar para estado inicial
		contador: in std_logic;          --Entrada para escolher o salgado desejado
		confirmar_salgado: in std_logic; --Entrada para confirmar o salgado escolhido
		moedas: in std_logic_vector(1 downto 0); --Vetor do tipo da moeda
		confirmar_moeda: in std_logic;           --Entrada para confirmar uma moeda adicionada
		
		saldo_dinheiro: buffer integer range 0 to 999 := 0; --Saldo do dinheiro colocado pelo cliente
		valor_salgado: buffer integer range 0 to 999 := 0;  --Valor do Salgado selecionado pelo cliente 
		estado: out std_logic_vector(2 downto 0);           --Vetor que mostra os estados da maquina
		
		--Saida do Programa
		display_salgado: out std_logic_vector(6 downto 0);          --Saida para o Display Opcao Salgado
		display_dinheiro_centena: out std_logic_vector(6 downto 0); --Saida para o Display Dinheiro Centena
		display_dinheiro_dezena: out std_logic_vector(6 downto 0);  --Saida para o Display Dinehrio Dezena
		display_dinheiro_unidade: out std_logic_vector(6 downto 0); --Saida para o Display Dinheiro Unidade
		
		led_vermelho: out std_logic; --Leds Vermelhos da Placa
		led_verde: out std_logic     --Leds Verdes da Placa
	);
end Maquina; --Fim da declaracao da Entidade




architecture hardware of Maquina is --Declaracao da Arquitetura
	
	signal salgado_selecionado: integer range 1 to 6 := 1; --Tipo do salgado selecionado pelo cliente
	signal troco: integer range 0 to 999 :=0;              --Valor do troco do cliente
	
	
	--estados da Maquina de vender Salgados
	type estados is (estado_inicial, estado_salgado, estado_estoque, estado_moeda, estado_final, estado_reiniciar);
    signal estado_atual, proximo_estado: estados;--Estado atual e proximo da maquina
    
    signal estoque_salgado1: integer range 0 to 10 := 1; --Estoque do Salgado 1
	signal estoque_salgado2: integer range 0 to 10 := 5; --Estoque do Salgado 2
	signal estoque_salgado3: integer range 0 to 10 := 5; --Estoque do Salgado 3
	signal estoque_salgado4: integer range 0 to 10 := 1; --Estoque do Salgado 4
	signal estoque_salgado5: integer range 0 to 10 := 5; --Estoque do Salgado 5

    
    --Funcao para converter Numero Inteiro para Vetor de Saida do Display de 7 seg
	function converterDisplay7 (numero: integer) return std_logic_vector is --Funcao recebe um numero inteiro
		variable saida: std_logic_vector(6 downto 0); --Vetor de 7 bits para saida do Display
	begin --Inicio da Funcao
		case (numero) is
			when 0 => saida := "1000000"; --Saida recebe o numero 0 na Cod. do Display de 7 Seg
			when 1 => saida := "1111001"; --Saida recebe o numero 1 na Cod. do Display de 7 Seg
			when 2 => saida := "0100100"; --Saida recebe o numero 2 na Cod. do Display de 7 Seg
			when 3 => saida := "0110000"; --Saida recebe o numero 3 na Cod. do Display de 7 Seg
			when 4 => saida := "0011001"; --Saida recebe o numero 4 na Cod. do Display de 7 Seg
			when 5 => saida := "0010010"; --Saida recebe o numero 5 na Cod. do Display de 7 Seg
			when 6 => saida := "0000010"; --Saida recebe o numero 6 na Cod. do Display de 7 Seg
			when 7 => saida := "1111000"; --Saida recebe o numero 7 na Cod. do Display de 7 Seg
			when 8 => saida := "0000000"; --Saida recebe o numero 8 na Cod. do Display de 7 Seg		   
			when 9 => saida := "0010000"; --Saida recebe o numero 9 na Cod. do Display de 7 Seg       
			when others =>
		end case;
	return saida; --Retornando o vetor de Saida
	end converterDisplay7; --Fim da funcao



begin --Inicio da descricao da Arquitetura Hardware



	--Processo para usar no SIMULADOR
	process(clk)
	begin
		if (clk'event and clk = '1') then
			estado_atual <= proximo_estado;
		end if;
	end process;
	
	
	
	--Contador para alterar as opcoes de Salgados disponivel
	selecionar_salgado: process (clk, contador)
		variable numero : integer range 1 to 6 := 1;
	begin
		if (clk = '1' and estado_atual = estado_inicial) then
			numero := 1;
			salgado_selecionado <= 1;
		elsif ((contador'event and contador = '0') and estado_atual = estado_salgado) then
			numero := numero + 1; --Soma 1 ao numero toda vez que o contador for pressionado
			if (numero = 6) then --Quando chegar em 6 deve retornar para 1
				numero := 1; --Alterando valor para 1
			end if;
			salgado_selecionado <= numero; --Atribuindo o tipo do salgado ao salgado_selecionado
		end if;
	end process;
	
	
	
	--Somador de moedas colocadas pelo cliente
	somar_moedas: process (clk, moedas, confirmar_moeda)
	begin
		if (clk = '1' and estado_atual = estado_inicial) then
			saldo_dinheiro <= 0;
		elsif ((confirmar_moeda'event and confirmar_moeda = '0') and estado_atual = estado_moeda) then
			case (moedas) is
				when "01" => saldo_dinheiro <= saldo_dinheiro + 25; --Somando moeda 0.25
				when "10" => saldo_dinheiro <= saldo_dinheiro + 50; --Somando moeda 0.50
				when "11" => saldo_dinheiro <= saldo_dinheiro + 100;--Somando moeda 1.00
				when others =>
			end case;
		end if;
	end process;



	--Processo que controla a maquina de estados
	maquina_estados: process (clk, reset)
	begin
	if (clk'event and clk = '1') then
		
		case (estado_atual) is
			when estado_inicial =>
				estado <= "001"; 		--Codificacao do estado de escolha do salgado
				led_vermelho <= '1'; --Led Vermelho - Ligado
				led_verde    <= '1'; --Led Verde    - Ligado
				
				if (iniciar = '1') then
					proximo_estado <= estado_salgado;
				end if;
				
			when estado_salgado =>
				estado <= "010"; 		--Codificacao do estado de escolha do salgado
				led_vermelho <= '0'; --Led Vermelho - Desligado
				led_verde    <= '1'; --Led Verde    - Ligado
				
				if (confirmar_salgado = '0') then
					proximo_estado <= estado_estoque;
				elsif (reset = '0') then
					proximo_estado <= estado_reiniciar;
				end if;
			
			when estado_estoque =>
				estado <= "011"; 		--Codificacao do estado de escolha do salga
				led_vermelho <= '0'; --Led Vermelho - Desligado
				led_verde    <= '0'; --Led Verde    - Desligado
				
				case (salgado_selecionado) is
					when 1 =>
						if (estoque_salgado1 > 0) then
							proximo_estado <= estado_moeda;
						else
							proximo_estado <= estado_reiniciar;
						end if;
					when 2 =>
						if (estoque_salgado2 > 0) then
							proximo_estado <= estado_moeda;
						else
							proximo_estado <= estado_reiniciar;
						end if;
					when 3 =>
						if (estoque_salgado3 > 0) then
							proximo_estado <= estado_moeda;
						else
							proximo_estado <= estado_reiniciar;
						end if;
					when 4 =>
						if (estoque_salgado4 > 0) then
							proximo_estado <= estado_moeda;
						else
							proximo_estado <= estado_reiniciar;
						end if;
					when 5 =>
						if (estoque_salgado5 > 0) then
							proximo_estado <= estado_moeda;
						else
							proximo_estado <= estado_reiniciar;
						end if;
					
					when others =>
				end case;
			
			when estado_moeda =>
				estado <= "100"; 		--Codificacao do estado de escolha do salgado
				led_vermelho <= '0'; --Led Vermelho - Desligado
				led_verde    <= '1'; --Led Verde    - Ligado

				if (saldo_dinheiro >= valor_salgado) then
					proximo_estado <= estado_final;
				elsif (reset = '0') then
					proximo_estado <= estado_reiniciar;
				end if;
				
			when estado_final =>
				estado <= "101"; 		--Codificacao do estado de escolha do salgado
				led_vermelho <= '0'; --Led Vermelho - Desligado
				led_verde    <= '0'; --Led Verde    - Desligado
				
				if (liberar = '1') then
					case (salgado_selecionado) is
						--Reduzindo uma unidade no estoque do salgado
						when 1 =>
							estoque_salgado1 <= estoque_salgado1 - 1; --Reduzindo 1 item no estoque
							proximo_estado <= estado_reiniciar;       --Passando para estado de Reinicio
						when 2 =>
							estoque_salgado2 <= estoque_salgado2 - 1; --Reduzindo 1 item no estoque
							proximo_estado <= estado_reiniciar;       --Passando para estado de Reinicio
						when 3 =>
							estoque_salgado3 <= estoque_salgado3 - 1; --Reduzindo 1 item no estoque
							proximo_estado <= estado_reiniciar;       --Passando para estado de Reinicio
						when 4 =>
							estoque_salgado4 <= estoque_salgado4 - 1; --Reduzindo 1 item no estoque
							proximo_estado <= estado_reiniciar;       --Passando para estado de Reinicio
						when 5 =>
							estoque_salgado5 <= estoque_salgado5 - 1; --Reduzindo 1 item no estoque
							proximo_estado <= estado_reiniciar;       --Passando para estado de Reinicio
						when others =>
					end case;
				end if;
				
			when estado_reiniciar =>
				estado <= "000"; 		--Codificacao do estado de escolha do salgado
				led_vermelho <= '1'; --Led Vermelho - Ligado
				led_verde    <= '0'; --Led Verde    - Desligado
				proximo_estado <= estado_inicial; --Maquina volta para Estado Inicial
			
			when others =>
		end case;
		
	end if;
	end process; --Fim do processo
	
	
	
	--Processo para Atualizar os Displays de 7 seg
	atualizar_display: process(clk)
		variable centena, dezena, unidade : integer range 0 to 999;--Variaveis para realizar calculo
	begin
	if (clk'event and clk = '1') then
	
		case (estado_atual) is
			when estado_inicial =>
				display_salgado          <= "1111111"; --Desligando Display
				display_dinheiro_centena <= "1111111"; --Desligando Display
				display_dinheiro_dezena  <= "1111111"; --Desligando Display
				display_dinheiro_unidade <= "1111111"; --Desligando Display
				
			when estado_salgado =>
				display_salgado <= converterDisplay7(salgado_selecionado); --Mostra a opcao do Salgado
				
				case (salgado_selecionado) is
					when 1 => --Salgado 1 valor (2.50)
						valor_salgado <= 250; --Atribui o valor do Salgado selecionado
						display_dinheiro_centena <= converterDisplay7(2); --Mostra o valor no Display Centena
						display_dinheiro_dezena  <= converterDisplay7(5); --Mostra o valor no Display Dezena
						display_dinheiro_unidade <= converterDisplay7(0); --Mostra o valor no Display Unidade
						
					when 2 => --Salgado 2 valor (1.50)
						valor_salgado <= 150; --Atribui o valor do Salgado selecionado
						display_dinheiro_centena <= converterDisplay7(1); --Mostra o valor no Display Centena
						display_dinheiro_dezena  <= converterDisplay7(5); --Mostra o valor no Display Dezena
						display_dinheiro_unidade <= converterDisplay7(0); --Mostra o valor no Display Unidade
						
					when 3 => --Salgado 3 valor (0.75)
						valor_salgado <= 75; --Atribui o valor do Salgado selecionado
						display_dinheiro_centena <= converterDisplay7(0); --Mostra o valor no Display Centena
						display_dinheiro_dezena  <= converterDisplay7(7); --Mostra o valor no Display Dezena
						display_dinheiro_unidade <= converterDisplay7(5); --Mostra o valor no Display Unidade
						
					when 4 => --Salgado 4 valor (3.50)
						valor_salgado <= 350; --Atribui o valor do Salgado selecionado
						display_dinheiro_centena <= converterDisplay7(3); --Mostra o valor no Display Centena
						display_dinheiro_dezena  <= converterDisplay7(5); --Mostra o valor no Display Dezena
						display_dinheiro_unidade <= converterDisplay7(0); --Mostra o valor no Display Unidade
						
					when 5 => --Salgado 5 valor (2.00)
						valor_salgado <= 200; --Atribui o valor do Salgado selecionado
						display_dinheiro_centena <= converterDisplay7(2); --Mostra o valor no Display Centena
						display_dinheiro_dezena  <= converterDisplay7(0); --Mostra o valor no Display Dezena
						display_dinheiro_unidade <= converterDisplay7(0); --Mostra o valor no Display Unidade
					
					when others =>
				end case;
			
			when estado_moeda   =>
				--Mostra nos Display o Saldo atual do Cliente ao adicionar moedas
				unidade := (saldo_dinheiro mod 10);
				dezena := (saldo_dinheiro - unidade)/10;
				dezena := (dezena mod 10);
				centena := (saldo_dinheiro - unidade)/10;
				centena := (centena - dezena)/10;

				display_dinheiro_centena <= converterDisplay7(centena); --Display que mostra a Centena
				display_dinheiro_dezena  <= converterDisplay7(dezena);  --Display que mostra a Dezena
				display_dinheiro_unidade <= converterDisplay7(unidade); --Display que mostra a Unidade
			
			when estado_final   =>
				--Mostrar nos Display o valor do Troco do Cliente
				troco <= saldo_dinheiro - valor_salgado;
				unidade := (troco mod 10);
				dezena := (troco - unidade)/10;
				dezena := (dezena mod 10);
				centena := (troco - unidade)/10;
				centena := (centena - dezena)/10;

				display_dinheiro_centena <= converterDisplay7(centena); --Display que mostra a Centena
				display_dinheiro_dezena  <= converterDisplay7(dezena);  --Display que mostra a Dezena
				display_dinheiro_unidade <= converterDisplay7(unidade); --Display que mostra a Unidade
			
			when estado_reiniciar =>
				display_salgado          <= converterDisplay7(0); --Mostra 0 no Display, liberando Salgado
				display_dinheiro_centena <= converterDisplay7(0); --Mostra 0 no Display, liberando Troco
				display_dinheiro_dezena  <= converterDisplay7(0); --Mostra 0 no Display, liberando Troco
				display_dinheiro_unidade <= converterDisplay7(0); --Mostra 0 no Display, liberando Troco
			
			when others =>
		end case;
		
	end if;
	end process; --Fim do Processo
	


end hardware; --Final da Arquitetura
