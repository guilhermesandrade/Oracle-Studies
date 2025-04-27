--Criando tabelas etc...
SHOW USER;

@c:\temp\cenario_plsql.sql;

ROLLBACK;

SELECT *
FROM tb_empregado;
--------------------------------------------------------------------------------
--slide + - 112
--PLSQL é o mecanismo mais agil de ser realizar manipulação dos dados em um BD Oracle
--Beneficios:   Integração de isntruções procedurais com instruções SQL , 
--              Performance (diversas instruções podem ser executadas como uma unica transaction)
--              Modularização (organiza o codigo em blocos, blocos podem ser sninhados em outros blocos)
--              Integração com outros sistemas Oracle
--              Portabilidade
--              Tratamento de exceção
              
--PLSQL: estruturada em blocos, as unidades de programa podem ser blocos nomeados ou não
--Blocos não nomeados: Anônimos
--Blocos rotulados/nomeados: funções e procedimentos

--DECLARE (OPCIONAL): variaveis,cursores,exceções
--BEGIN (OBRIGATORIO): intrucoes sql e PL/SQL
--EXCEPTION (OPCIONAL): acoes a serem executadas na ocorrencia de erros
-- END; (OBRIGATORIO)

--Exemplo de primeiro bloco (slide 130):

SET serveroutput ON
DECLARE
    v_texto VARCHAR2(30) :='Programação com BD';
BEGIN
    dbms_output.put_line(v_texto);
END;

--EXEMPLO 03

SET serveroutput ON
DECLARE -- seção de declarações
    v_contador NUMBER;  --(declaração de variavel)
BEGIN  --seção executavel
    SELECT COUNT(1) INTO v_contador
    FROM tb_empregado; --intrução SQL
    
    IF v_contador = 0 THEN -- instrução procedural
        DBMS_OUTPUT.PUT_LINE('Nenhum funcionario cadastrado no esquema RH');
    
    ELSE
        DBMS_OUTPUT.PUT_LINE('Existem '|| to_char(v_contador)||
            ' funcionario(s) cadastrado(s) no esquema RH');
    END IF;
    
EXCEPTION --seção de tratamento de exceção
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;

--o aninhamento de blocos permite que uma seção executavel ou de tratamento de exceção inclua outros blocos PL/SQL
--(no mundo real, dificilmente faremos isso)

SET serveroutput ON
--inicio do bloco EXTERNO
DECLARE --seção declarativa
    v_contador NUMBER; --declaração de variavel
BEGIN --seção executavel
    --o bloco abaixo está aninhado dentro do bloco pai
    BEGIN --inicio do bloco INTERNO
        SELECT 1 INTO v_contador --instrução SQL
        FROM tb_empregado
        WHERE ROWNUM=1;
    
    EXCEPTION
        WHEN OTHERS THEN
        v_contador:=0;
    END; --termino do bloco INTERNO
    
    IF v_contador =0 THEN --instrução procedural
        DBMS_OUTPUT.PUT_LINE ('Nenhum funcionario cadastrado no esquema de RH');
        
    ELSE
        DBMS_OUTPUT.PUT_LINE('Existe '|| TO_CHAR(v_contador)||
            ' funcionario cadastrado no esquema RH');
    END IF;
    
EXCEPTION --seção de tratamento de exceção
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
--termino do bloco EXTERNO

--exemplo 2 (vai dar erro pois ele não consegue ir para linha 2 sem passar pela linha 1)
--ORA-01403: dados não encontrados

SET serveroutput ON
DECLARE  --seção declarativa 
    v_contador NUMBER; --declaração de variavel
BEGIN  --seção executavel
    SELECT 1 INTO v_contador  --instrução SQL
    FROM tb_empregado
    WHERE ROWNUM =2;
    
IF v_contador = 0 THEN  --Instrução procedural
    DBMS_OUTPUT.PUT_LINE('Nenhum funcionario cadastrado no esquema RH');
    
ELSE
    DBMS_OUTPUT.PUT_LINE('Existe(m)'||TO_CHAR(v_contador)||
            ' funcionarios(s) cadastrado(s) no esquema RH');
    END IF;

EXCEPTION  --seção de tratamento de esceção
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;

--tipos de bloco: anonimo, procedimento, função (slide 139)
--blocos podem ser segmentado em 2 tipos: anonimos (não possuem nome, nao sao armazenados no BD, sempre que executados sao compilados novamente)
--                                        nomeados/armazenados (possuem nomes/identificadores proprios,sao armazenados no BD, normalmente declarados como funcoes ou procedimentos, podem ser invocados por outros blocos,triggers ou ate intrucoes SQL)



--indicador de variavel hospede (:) procede um nome de identificador valido e designa aquela identificador como uma variavel nivel-sessão
--exemplo (execute 1 passo por vez):

VARIABLE v_minha_string VARCHAR2(30); -- executar passo 1 (declara variavel)

BEGIN -- executar passo 2 (define um valor pra ela)
    :v_minha_string := 'Um string literal';
END;

SET serveroutput ON --executar passo 3 (exibe o valor)
BEGIN
    DBMS_OUTPUT.PUT_LINE(:v_minha_string);
END;

--O indicador substituição (&) permite passar parametros reais para dentro dos programas de bloco anonimos PL/SQL

SET serveroutput ON
DECLARE
    v_minha_string VARCHAR2(30);
BEGIN
    v_minha_string := '&input';
    dbms_output.put_line('Testando: '|| v_minha_string);
END;


-- O indicador atributo (%) permite conectar um catalogo de BD, coluna, linha/tupla ou atributo cursor (%TYPE e %ROWTYPE)

SET serveroutput ON
DECLARE
v_id_emp        tb_empregado.id_empregado%TYPE; --NUMBER(6)
v_sobrenome     tb_empregado.sobrenome%TYPE; -- VARCHAR2(25)
BEGIN
    v_id_emp := 100301; --OK porque cabe em NUMBER(6)
    v_sobrenome := 'Silva'; -- OK porque cabe em VARCHAR2(25)
    dbms_output.put_line('ID: '|| v_id_emp);
    dbms_output.put_line('Sobrenome: '|| v_sobrenome);
END;



-- é como se fosse um vetor, porem pode armazenar datatypes diferentes

SET serveroutput ON
DECLARE
  v_emp_reg     tb_empregado%ROWTYPE;
BEGIN
  SELECT * INTO v_emp_reg 
  FROM tb_empregado
  WHERE id_empregado = 125;
  
  DBMS_OUTPUT.PUT_LINE('Nome: ' || v_emp_reg.nome || ' ' || v_emp_reg.sobrenome);
END;


--Componente 'selector', tem como objetivo 'colar' as referencias (um esquema e uma tabela)

--O delimitador identificador 'cotado' é um simbolo de aspas duplas.Permite acessar 'objetos' criados de forma case-sensitive
--nao aconselhavel utilizar (exemplo slide 155)

CREATE TABLE "tb_Demo"(
"id_Demo" NUMBER,
valor_demo VARCHAR2(20));

INSERT INTO "tb_Demo"
VALUES
(1,'Linha um apenas');

COMMIT;

--exemplo 2

SET serveroutput ON
BEGIN
    FOR i IN(SELECT "id_Demo",valor_demo
             FROM "tb_Demo") LOOP
        dbms_output.put_line(i."id_Demo");
        dbms_output.put_line(i.valor_demo);
    END LOOP;
END;


-- As Variaveis em PL/SQL são utilizadas para (slide 158):
--Armazenamento temporario de dados, manipulação de valores armazenados, reutilização, Facil manutenção
--deve-se declarar as variaveis na seção 'declarativa' (declare)
--declarações de variaveis validas e invalidas no slide 165

SET serveroutput ON
DECLARE
    v_nome VARCHAR2(50); --variaveis são insensitivel case
BEGIN
    V_NOME := 'Treinamento PL/SQL Essencial'; --variaveis são insensitivel case
    dbms_output.put_line('O conteudo eh: '|| v_nome);
END;

--exemplo

SET serveroutput ON
DECLARE
v_salario               NUMBER(6,2);
v_horas_trabalhada      NUMBER :=40;
v_valor_hora            NUMBER := 22.50;
v_bonus                 NUMBER := 150;
v_pais                  VARCHAR2(128);
v_contador              NUMBER :=0;
v_controle              BOOLEAN := FALSE;
v_id_validade           BOOLEAN;

BEGIN
    v_salario := (v_horas_trabalhada * v_valor_hora)+ v_bonus;
    v_pais := 'Brasil'; -- um string literal
    v_pais := UPPER ('Canada'); -- um string literal uppercase
    v_controle := (v_contador >100); --FALSE
    v_id_validade := TRUE; --BOOLEAN
END;

--EXEMPLO 4 (usando literais booleanos em PL/sql)

DECLARE
v_finalizado            BOOLEAN := TRUE;
v_completo              BOOLEAN;
v_true_or_false         BOOLEAN;
BEGIN
v_finalizado := FALSE; -- set para FALSE
v_completo := NULL; -- valor desocnhecido
v_true_or_false :=(3=4); -- set para FALSE
v_true_or_false := (3<4); -- set para TRUE
END;

--EXEMPLO 5 (declarando variaveis com a palavra-chave DEFAULT ou restrição NOT NULL)

DECLARE
    v_id_empregado          NUMBER(6);
    v_emp_ativo             BOOLEAN NOT NULL := TRUE;
    v_salario_mensal        NUMBER(6) NOT NULL := 2000;
    v_valor_diaria          NUMBER(6,2);
    v_media_dias_trab_mes   NUMBER(2) DEFAULT 21;
BEGIN
    NULL; --a intrução NULL nada faz
END;

--exemplo 6: é possivel declarar uma variavel usando o tipo de dado 'record' em ambos os programas(anonimos e nomeados)
-- aqui criamos o nosso proprio tipo (TYPE)

SET serveroutput ON
DECLARE
    TYPE registro_demo IS RECORD(
        id_aluno    NUMBER DEFAULT 1,
        nome        VARCHAR2(10) := 'Mário');
    reg_demo REGISTRO_DEMO;
BEGIN
    dbms_output.put_line('[' || reg_demo.id_aluno ||'][' || reg_demo.nome || ']');
END;

-- EXEMPLO 7: possibilidade de alojar registros (record).Para acessar os nomes dos registros alojados,utilize outro seletor(.)
-- um resgistro referenciando outro registro

SET serveroutput ON
DECLARE
    TYPE tp_full_name IS RECORD(
        nome        VARCHAR2(10) := 'Ricardo',
        sobrenome   VARCHAR2(10) := 'Vargas');
    
    TYPE tp_reg_aluno IS RECORD(
        id_aluno    NUMBER DEFAULT 1,
        nm_aluno    TP_FULL_NAME);
    reg_demo TP_REG_ALUNO;
BEGIN
    dbms_output.put_line('[' || reg_demo.id_aluno || ']');
    dbms_output.put_line('[' || reg_demo.nm_aluno.nome || ']');
    dbms_output.put_line('[' || reg_demo.nm_aluno.sobrenome || ']');
END;

--EXEMPLO 8: declaração de um VARRAY de variavel escalar

SET serveroutput ON
DECLARE
    TYPE varray_numerico IS VARRAY(5) OF NUMBER;
    v_lista VARRAY_NUMERICO := varray_numerico(1,2,3,NULL,NULL);
BEGIN
    FOR i IN 1 .. v_lista.LIMIT LOOP --ele vai de 1 em 1 até o final da lista(LIMIT LOOP)
        dbms_output.put('[' || v_lista(i) || ']'); -- o output.put vai imprimir todos em uma linha apenas
    END LOOP;
    dbms_output.new_line;
END;


--ESCOPO E VISIBILIDADE DE VARIAVEIS (slide 175)
--escopo de variavel corresponde ao local ou bloco PL/SQL a qual ela foi criada(declarada) e permanece acessivel
--Caso uma variavel seja declarada em um bloco interno, ela nao podera ser acessivel no bloco externo

--Se eventualmente um bloco PL/SQL conter um outro bloco aninhado, uma variavel podera ser utilizada com o mesmo
--identificador nos dois blocos,utilizando-se identificadores de blocos

SET serveroutput ON
<<outer>> --indentificador do bloco pai/externo
DECLARE 
    v_contador NUMBER;
BEGIN
    <<inner>> -- inicio do bloco filho/interno
    DECLARE
        v_contador NUMBER;
    BEGIN
        SELECT 1 INTO inner.v_contador
        FROM tb_empregado
        WHERE ROWNUM =1;
        outer.v_contador := inner.v_contador;
    EXCEPTION
        WHEN OTHERS THEN
            outer.v_contador := 0;
    END; -- FIM DO BLOCO FILHO/INTERNO
IF v_contador =0 THEN
    dbms_output.put_line('Nenhum registro no esquema RH');
ELSE
    dbms_output.put_line('Existe ' || to_char (outer.v_contador) || ' registro no esquema RH');
END IF;
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line(SQLERRM);
END;
    
--EXEMPLO 2 (é possivel declarar com mesmo nome em blocos diferentes pois usam memorias diferentes)

SET serveroutput ON
DECLARE
-- Variaveis Globais (BLOCO EXTERNO)
v_num1 NUMBER := 95;
v_num2 NUMBER := 85;
BEGIN
    dbms_output.put_line('Variavel global v_num1: ' || v_num1);
    dbms_output.put_line('Variavel global v_num2: ' || v_num2);
    
    DECLARE
    --variaveis locais (BLOCOS INTERNO)
    v_num1 NUMBER := 195;
    v_num2 NUMBER := 185;
    BEGIN
        dbms_output.put_line('Variavel local v_num1: ' || v_num1);
        dbms_output.put_line('Variavel local v_num2: ' || v_num2);
    END;
END;

-- CONSTANTES: os valores as constantes não podem ser modificados pelo coigo PL/SQL (após sua declaração)

--exemplo 1
SET serveroutput ON
DECLARE --seção declarativa
    c_identificador CONSTANT VARCHAR2(30) := 'PL/SQL Essencial';
BEGIN
    dbms_output.put_line('Conteúdo da constante: ' || c_identificador);
END;

--exemplo 2

SET serveroutput ON
DECLARE
--Declaração da Constante
    c_pi CONSTANT NUMBER := 3.141592654;
--Outras Declarações
v_raio              NUMBER(5,2);
v_diametro          NUMBER(5,2);
v_circunferencia    NUMBER (7,2);
v_area              NUMBER(10,2);
BEGIN
    v_raio := 9.5;
    v_diametro := v_raio*2;
    v_circunferencia := 2.0 * c_pi * v_raio;
    v_area := c_pi * v_raio * v_raio;
--saida
    dbms_output.put_line('Raio: '|| v_raio);
    dbms_output.put_line('Diametro: ' || v_diametro);
    dbms_output.put_line('Circunferencia: ' || v_circunferencia);
    dbms_output.put_line('Area: '|| v_area);
END;

--exemplo de INSTRUÇÕES SQL EM PL/SQL (slide 193)

SET serveroutput ON
DECLARE
    v_soma_salario      NUMBER(10,2);
    v_nome              tb_empregado.nome%TYPE;
    v_sobrenome         tb_empregado.sobrenome%TYPE;
BEGIN
    SELECT SUM(NVL(salario,0))INTO v_soma_salario
    FROM tb_empregado
    WHERE id_departamento =10;
    
    dbms_output.put_line('A soma dos salarios é: '|| v_soma_salario);
    
    SELECT nome,sobrenome INTO v_nome,v_sobrenome
    FROM tb_empregado
    WHERE id_empregado=100;
    
    dbms_output.put_line('O nome completo do empregado é: '|| v_nome ||' '|| v_sobrenome);
END;

-- as manipulações dos dados podem ser aplicadas com o uso das intruções INSERT, UPDATE,DELETE, MERGE em blocos PL/SQL
-- Há necessidade de gerenciar bloqueios de linhas
 
 -- exemplo 1

BEGIN
    INSERT INTO tb_empregado(id_empregado,nome,sobrenome,email,data_admissao,id_funcao,salario)
    VALUES(sq_empregado.NEXTVAL,
            'Geraldo','Henrique Neto', 'geraldohenrique@usp.br', SYSDATE,'IT_PROG',5000.00);
    COMMIT;
END;

SELECT *
FROM tb_empregado
WHERE nome='Geraldo'
AND sobrenome='Henrique Neto';

-- exemplo 2 (slide 202)

BEGIN 
    UPDATE tb_empregado
    SET salario=15000.00
    WHERE nome='Geraldo'
    AND sobrenome='Henrique Neto';
    
    COMMIT;
END;

SELECT *
FROM tb_empregado
WHERE nome='Geraldo'
AND sobrenome = 'Henrique Neto';

--EXEMPLO 3

DECLARE
    v_id_empregado NUMBER;
BEGIN
    SELECT sq_empregado.CURRVAL INTO v_id_empregado
    FROM dual;
    
    DELETE FROM tb_empregado
    WHERE id_empregado = v_id_empregado;
    COMMIT;
END;

SELECT *
FROM tb_empregado
WHERE nome='Geraldo'
AND sobrenome = 'Henrique Neto';



--Resolução de problemas..
-- 1-voce está interessado em criar um bloco de codigo PL/SQL executavel (slide 207 pode cair na prova)

-- 2-Voce quer executar um bloco de codigo PL/SQL dentro do utilitario de linha de comando SQL*Plus (slide 210)

-- 3- EM vez de digitar seu codigo PL/SQL no utilitario SQL*Plus a cada vez que voce desejar executa-lo, voce pode armazenar o codigo em um script executavel

-- 4-Voce armazenou um script PL/SQL para o seu sistema de arquivos e deseja executa-lo via SQL*Plus

-- 5-Voce deseja escrever um script que solicita ao usuario alguma entrada de dados, voce deseja que seu codigo PL/SQL posteriormente utilize essa entrada para gerar alguns resultados
--   Quantos empregados estão alocados em um departamento especifico (ID_DEPARTAMENTO será a variavel de entrada)

-- id pra teste 10:
SET serveroutput ON
DECLARE
    v_emp_count NUMBER;
BEGIN
    SELECT COUNT(1)INTO v_emp_count
    FROM tb_empregado
    WHERE id_departamento = &&id_departamento;
    
    DBMS_OUTPUT.PUT_LINE('A contagem de empregados eh: '|| v_emp_count || ' para o depto com o ID de: ' || &id_departamento);
END;

--EXEMPLO 2 (pra teste, valor: 60)

SET serveroutput ON
DECLARE
    v_id_depto      NUMBER(4) :=&id_depto;
    v_nm_depto      VARCHAR2(30);
    v_emp_count     NUMBER;

BEGIN
    SELECT COUNT(1) INTO v_emp_count
    FROM tb_empregado
    WHERE id_departamento = v_id_depto;
    
    SELECT nm_departamento INTO v_nm_depto
    FROM tb_departamento
    WHERE id_departamento = v_id_depto;
    
    DBMS_OUTPUT.PUT_LINE('Existe '|| v_emp_count || ' empregado(s) no departamento ' || v_nm_depto);
END;

--EXEMPLO 3

SET serveroutput ON
DECLARE
    v_nome          VARCHAR2(20);
    v_sobrenome     VARCHAR2(25);
    v_emp_sobre     VARCHAR2(25) := '&v_emp_sobre';
    v_emp_count     NUMBER;
BEGIN
    SELECT COUNT(1)INTO v_emp_count
    FROM tb_empregado
    WHERE sobrenome = v_emp_sobre;
    
    IF v_emp_count >1 THEN
        dbms_output.put_line('Existe mais de um empregado com o mesmo sobrenome');
    ELSE
        SELECT nome,sobrenome INTO v_nome,v_sobrenome
        FROM tb_empregado
        WHERE sobrenome=v_emp_sobre;
        
    DBMS_OUTPUT.PUT_LINE('Nome completo do empregado: '|| v_nome || ' ' || v_sobrenome);
    END IF;
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Por favor, entre com um sobrenome diferente');
END;

---------------------------------------------------

-- SLIDES 2

---------------------------------------------------

--INTRUÇÕES CONDICIONAIS : IF, CASE, Intruções de compilação condicionar
--INSTRUÇÕES ITERATIVAS: LOOP simples, WHILE, FOR

--A intrução IF associa um estado com uma sequencia de isntruções entre as palavras-chave THEN e END IF
--Se a condição for verdadeira, as declarações são executadas e se a condição for falsa ou NULL, então a intrução IF faz nada

--exemplo1

SET serveroutput ON
DECLARE
    v_a NUMBER(2) :=10;
BEGIN
    v_a := 10;
    --verifica a condição boolean usando a instrução IF
    IF(v_a <20)THEN --se a condição for verdadeira
        dbms_output.put_line('v_a é menor que 20');
    END IF;
    dbms_output.put_line('O valor de v_a é: '|| v_a);
END;

--exemplo 2

SET serveroutput ON
DECLARE
    v_contador NUMBER;
BEGIN
    SELECT COUNT(1)INTO v_contador
    FROM tb_empregado;
    
    IF v_contador = 0 THEN
        dbms_output.put_line('Não existe empregado cadastrado');
    END IF;
END;

--Exemplo 3

--script da tabela

CREATE TABLE tb_clientes(
id_cliente    INT NOT NULL, 
nm_cliente    VARCHAR2(20) NOT NULL, 
idade         INT NOT NULL, 
endereco      VARCHAR2(25), 
salario       DECIMAL (18,2), 
PRIMARY KEY (id_cliente)
);

INSERT INTO tb_clientes (id_cliente, nm_cliente, idade, endereco, salario) 
VALUES (1, 'Ramesh', 32, 'Ahmedabad', 2000.00 ); 

INSERT INTO tb_clientes (id_cliente, nm_cliente, idade, endereco, salario) 
VALUES (2, 'Khilan', 25, 'Delhi', 1500.00 ); 

INSERT INTO tb_clientes (id_cliente, nm_cliente, idade, endereco, salario)  
VALUES (3, 'kaushik', 23, 'Kota', 2000.00 ); 

INSERT INTO tb_clientes (id_cliente, nm_cliente, idade, endereco, salario) 
VALUES (4, 'Chaitali', 25, 'Mumbai', 6500.00 ); 

INSERT INTO tb_clientes (id_cliente, nm_cliente, idade, endereco, salario)  
VALUES (5, 'Hardik', 27, 'Bhopal', 8500.00 ); 

INSERT INTO tb_clientes (id_cliente, nm_cliente, idade, endereco, salario) 
VALUES (6, 'Komal', 22, 'MP', 4500.00 );

COMMIT;

-- exemplo

SET serveroutput ON
DECLARE
    c_id_cliente    tb_clientes.id_cliente%TYPE :=1;
    c_salario       tb_clientes.salario%TYPE;
BEGIN
    SELECT salario INTO c_salario
    FROM tb_clientes
    WHERE id_cliente = c_id_cliente;
    
    IF(c_salario <= 2000)THEN
        UPDATE tb_clientes SET salario = salario + 1000
        WHERE id_cliente = c_id_cliente;
        dbms_output.put_line('Salario alterado com exito');
    END IF;
END;

--
SELECT salario
FROM tb_clientes
WHERE id_cliente =1;

--***************************

--PERGUNTA DE AVALIAÇÃO

--o que ficou faltando no bloco anonimo em que diz respeito a update?
--nos omitimos ela (commit), ele vai executar mas não efetuamos o commit, logo a alteração só ira ficar em cache.

--***************************


--Uma sequencia de isntruções IF-THEN pode ser seguido por uma sequencia opcional de ELSE, que executam quando a condição for FALSE

--exemplo 1

SET serveroutput ON
DECLARE
    v_a NUMBER(3) := 100;
BEGIN
    IF(v_a <20)THEN
        dbms_output.put_line('v_a é menor que 20');
    ELSE
        dbms_output.put_line('v_a não é menor que 20');
    END IF;
    
    dbms_output.put_line('O valor de v_a é: ' || v_a);
END;

--exemplo 2

SET serveroutput ON
DECLARE
    v_contador NUMBER;
BEGIN
    SELECT COUNT(1) INTO v_contador
    FROM tb_empregado;
    
    IF v_contador = 0 THEN
        dbms_output.put_line('Não existe(m) empregado(s) cadastrado(s)');
    ELSE
        dbms_output.put_line('Existe(m) '|| TO_CHAR(v_contador)||' empregado(s) cadastrado(s)');
    END IF;
END;


--A intrução IF-THEN-ELSIF permite que voce esclha entre varias alternativas
-- Ao usar declarações IF-THEN-ELSIF, há alguns pontos:
--É ELSIF, não ELSEIF
--Uma instrução IF-THEN pode ter zero ou um outro ELSE devendo vir depois de qualquer ELSIF
--Uma instrução IF-THEN pode ter zero a diversos ELSIF devendo vir antes do ELSE
--Uma vez que um ELSIF for bem-sucedida, nenhum dos ELSIF ou ELSE restantes serão testados

SET serveroutput ON
DECLARE
    v_a NUMBER(3) := 100;
BEGIN
    IF(v_a = 10)THEN
        dbms_output.put_line('Valor de v_a é 10');
    ELSIF(v_a =20)THEN
        dbms_output.put_line('Valor de v_a é 20');
    ELSIF(v_a =30)THEN
        dbms_output.put_line('Valor de v_a é 30');
    ELSE
        dbms_output.put_line('Nenhuma correspondencia com os valores acima');
    END IF;
    dbms_output.put_line('O valor exato de v_a é: '|| v_a);
END;

--EXEMPLO 2

SET serveroutput ON
DECLARE
    v_contador NUMBER;
BEGIN
    SELECT COUNT(1)INTO v_contador
    FROM tb_empregado;
    
    IF v_contador = 0 THEN
        dbms_output.put_line('Não existe empregado cadastrado');
    ELSIF v_contador > 100 THEN
        dbms_output.put_line('Existem mais de 100 empregados cadastrados');
    ELSE
        dbms_output.put_line('Existe(m) '|| TO_CHAR(v_contador)||' empregado(s) cadastrado(s)');
    END IF;
END;


--semelhante a isntrução IF, a iinstrução CASE seleciona uma sequencia de instruções para executar
--No entranto para selecioanr essa sequencia a intrução CASE utiliza um seletor em vez de multiplas expressões booleanas
--Um seletor é uma expressão cujo valor é usado para selecionar uma das varias alternativas existentes

--exemplo 1

SET serveroutput ON
DECLARE
    v_grade CHAR(1) := 'A';
BEGIN
    CASE v_grade
        WHEN 'A' THEN dbms_output.put_line('Excelente');
        WHEN 'B' THEN dbms_output.put_line('Muito Bom');
        WHEN 'C' THEN dbms_output.put_line('Bom');
        WHEN 'D' THEN dbms_output.put_line('Reprovado');
        WHEN 'F' THEN dbms_output.put_line('Tente Novamente');
        ELSE dbms_output.put_line('Nenhuma classificação');
    END CASE;
END;

--exemplo 2

SET serveroutput ON
DECLARE
    v_contador      NUMBER;
    v_msg           VARCHAR2(100);
BEGIN
    SELECT COUNT(1) INTO v_contador
    FROM tb_empregado;
    
    CASE v_contador
        WHEN 0 THEN dbms_output.put_line('Nenhum empregado cadastrado');
        ELSE dbms_output.put_line('Existe(m) '|| TO_CHAR(v_contador)|| ' empregado(s) cadastrado(s)');
    END CASE;
END;

--A declaração CASE pesquisada não tem seletor e suas clausulas WHEN contem condições de pesquisa que resulta em valores booleanos

SET serveroutput ON
DECLARE
    v_grade CHAR(1) :='B';
BEGIN
    CASE    
        WHEN v_grade='A' THEN dbms_output.put_line('Excelente');
        WHEN v_grade='B' THEN dbms_output.put_line('Muito Bom');
        WHEN v_grade='C' THEN dbms_output.put_line('Bom');
        WHEN v_grade='D' THEN dbms_output.put_line('Reprovado');
        WHEN v_grade='E' THEN dbms_output.put_line('Tente Novamente');
        
        ELSE dbms_output.put_line('Nenhuma classificação');
    END CASE;
END;

--EXEMPLO 2

SET serveroutput ON
DECLARE
    v_contador  NUMBER;
    v_msg       VARCHAR2(100);
BEGIN
    SELECT COUNT(1) INTO v_contador
    FROM tb_empregado;
    
    v_msg := CASE
                WHEN v_contador = 0 THEN 'Nenhum empregado cadastrado'
                WHEN v_contador >100 THEN 'Existem mais de 100 empregados cadastrados'
                ELSE 'Existe(m) '|| TO_CHAR(v_contador)|| ' empregado(s) cadastrado(s)'
            END;
        dbms_output.put_line(v_msg);
END;

--Exemplo 3 (slide 30)

SELECT COUNT(CASE WHEN salario < 2000 THEN 1 ELSE NULL END) contador_1,
        COUNT(CASE WHEN salario BETWEEN 2001 AND 4000 THEN 1 ELSE NULL END)contador_2,
        COUNT(CASE WHEN salario>4000 THEN 1 ELSE NULL END)contador_3
FROM tb_empregado;

--desafio slide 31

SELECT COUNT(1)
FROM tb_empregado
WHERE salario <2000

UNION ALL

SELECT COUNT(1)
FROM tb_empregado
WHERE salario BETWEEN 2001 AND 4000

UNION ALL

SELECT COUNT(1)
FROM tb_empregado
WHERE salario > 4000;

--aninhamento if-then-else

SET serveroutput ON
DECLARE
    v_a NUMBER(3) :=100;
    v_b NUMBER(3) :=200;
BEGIN
    IF(v_a=100)THEN
        IF(v_b=200) THEN
            dbms_output.put_line('Valor de v_a é 100 e v_b é 200');
        END IF;
    END IF;
    dbms_output.put_line('Valor exato de v_a é: '|| v_a);
    dbms_output.put_line('Valor exato de v_b é: '||v_b);
END;


--tipos de LOOP:
--Loop basico: uma sequencia de intruções são inseridas entre o LOOP e END LOOP, cada iteração,a sequencia de instruções são executadas
--Loop While: Repete uma instrução ou grupo de instruções até que determinada condição torne-se verdadeira, o teste da condição é realizado antes de executar o corpo do loop
--Loop For: executa uma sequencia de comandos varias vezes baseando-se em um contador que não necessita ser declarado explicitamente(escopo apenas no bloco de loop)


--loop simples
--exemplo 1: uma isntrução EXIT ou uma instrução EXIT WHEN é necessario para encerrar o loop

SET serveroutput ON
DECLARE
    v_x NUMBER :=10;
BEGIN
    LOOP
        dbms_output.put_line(v_x);
        v_x := v_x+10;
        IF v_x > 50 THEN
            EXIT;
        END IF;
    END LOOP;
    dbms_output.put_line('Depois do EXIT v_x é: '|| v_x);
END;

--exemplo 2:

SET serveroutput ON
DECLARE
    v_x NUMBER := 10;
BEGIN
    LOOP
        dbms_output.put_line(v_x);
        v_x := v_x + 10;
        EXIT WHEN v_x > 50;
    END LOOP;
    dbms_output.put_line('Depois do EXIT v_x é: '|| v_x);
END;


--loop while
--exemplo 1

SET serveroutput ON
DECLARE 
    v_a NUMBER(2) :=10;
BEGIN 
    WHILE v_a <20 LOOP
        dbms_output.put_line('O valor de v_a: '||v_a);
        v_a := v_a+1;
    END LOOP;
END;


--Loop For
--exemplo 1

SET serveroutput ON
DECLARE
    v_a NUMBER(2);
BEGIN
    FOR v_a IN 10 .. 20 LOOP --para v_a de 10 a vinte, loop
        dbms_output.put_line('Valor de v_a: '|| v_a);
    END LOOP;
END;

--EXEMPLO 2

SET serveroutput ON
DECLARE
    v_contador NUMBER :=0;
BEGIN
    FOR i IN 1..100 LOOP
        v_contador := v_contador+1;
        dbms_output.put_line('O valor de v_contador: '|| v_contador);
    END LOOP;
    
    dbms_output.put_line('O valor da final de v_contador é: ' || v_contador);
END;

--EXEMPLO 3

SET serveroutput ON
DECLARE
    v_a NUMBER(2);
BEGIN
    FOR v_a IN REVERSE 10..20 LOOP
        dbms_output.put_line('Valor de v_a: '|| v_a);
    END LOOP;
END;


--aninhamento de Loops (é possivel adicionar Label nos loops)

SET serveroutput ON
DECLARE
    v_contador NUMBER := 1;
BEGIN
    <<loop_pai>>
    FOR i IN 1..1000 LOOP --loop pai
        <<loop_filho>>
        LOOP --loop filho
            EXIT loop_pai WHEN v_contador >10;
            EXIT loop_filho WHEN MOD(v_contador, 10) = 0;
            v_contador := v_contador+1;
        END LOOP loop_filho;
        v_contador := v_contador +1;
    END LOOP loop_pai;
    
    dbms_output.put_line('O valor de v_contador é: '|| v_contador);
END;


--controlando estrutura de repetição usando EXIT

SET serveroutput ON
DECLARE
    v_a NUMBER(2) := 10;
BEGIN
    WHILE v_a<20 LOOP
        dbms_output.put_line('Valor de v_a: '|| v_a);
        v_a := v_a + 1;
        IF v_a > 15 THEN
            --FINALIZANDO O LOOP COM O EXIT
            EXIT;
        END IF;
    END LOOP;
END;

--exemplo2

SET serveroutput ON
DECLARE
    v_a NUMBER(2) :=10;
BEGIN
    WHILE v_a <20 LOOP
        dbms_output.put_line('Valor de v_a: '|| v_a);
        v_a := v_a +1;
        --finalizando o loop usando a instrução EXIT WHEN
    EXIT WHEN v_a >15;
    END LOOP;
END;

--A intrução CONTINUE faz o loop pular o restante de seu coorpo e imediamente testar novamente sua condição antes de reiterar, basicamente: ele força a proximo iteração do loop,pulando qualquer codigo entre os dois

SET serveroutput ON
DECLARE
    v_a NUMBER(2) := 10;
BEGIN
    WHILE v_a <20 LOOP
        dbms_output.put_line('Valor de v_a: '|| v_a);
        v_a := v_a +1;
        IF v_a =15 THEN
            v_a := v_a +1;
            CONTINUE;
        END IF;
    END LOOP;
END;

-- GOTO (não aconselhamos o uso do GOTO)
-- A instrução GOTO promove um salto incondicional do GOTO para um determinado rotulo(label) no mesmo subprograma
--Obrigatorio usar label

--exemplo 1:

SET serveroutput ON 
DECLARE
    v_a NUMBER(2) := 10;
BEGIN
    <<inicio_loop>>
    WHILE v_a <20 LOOP
        dbms_output.put_line('Valor de v_a: '|| v_a);
        v_a := v_a+1;
        IF v_a = 15 THEN
            v_a :=v_a+1;
            GOTO inicio_loop;
        END IF;
    END LOOP;
END;



--VALORES NULOS, para evitar equivocos ao manipular valores nulos devemos nos atentar a alguns detalhes:
--comparações com valores nulos sempre resulta em valores nulos
--utilização do operador de negação (NOT) em valores nulos resultara em nulo

--exemplo 1

SET serveroutput ON
DECLARE
    v_resultado BOOLEAN;
    v_compare1 BOOLEAN;
    v_compare2 BOOLEAN;
BEGIN
    v_compare1 :=true;
    v_compare2 := true;
    v_resultado := v_compare1 AND v_compare2;
    dbms_output.put_line('O valor de v_resultado é: '|| CASE v_resultado WHEN TRUE THEN 'TRUE'
                                                                            WHEN FALSE THEN 'FALSE'
                                                                            ELSE 'NULL' 
                                                                            END);
END;

--EXEMPLO 2:


SET serveroutput ON
DECLARE
    v_resultado BOOLEAN;
    v_compare1 BOOLEAN;
    v_compare2 BOOLEAN;
BEGIN
    v_compare1 :=true;
    v_compare2 := false;
    v_resultado := v_compare1 AND v_compare2;
    dbms_output.put_line('O valor de v_resultado é: '|| CASE v_resultado WHEN TRUE THEN 'TRUE'
                                                                            WHEN FALSE THEN 'FALSE'
                                                                            ELSE 'NULL' 
                                                                            END);
END;

--exemplo 3


SET serveroutput ON
DECLARE
    v_resultado BOOLEAN;
    v_compare1 BOOLEAN;
    v_compare2 BOOLEAN;
BEGIN
    v_compare1 :=null;
    v_compare2 := true;
    v_resultado := v_compare1 AND v_compare2;
    dbms_output.put_line('O valor de v_resultado é: '|| CASE v_resultado WHEN TRUE THEN 'TRUE'
                                                                            WHEN FALSE THEN 'FALSE'
                                                                            ELSE 'NULL' 
                                                                            END);
END;

--exemplo 4


SET serveroutput ON
DECLARE
    v_resultado BOOLEAN;
    v_compare1 BOOLEAN;
    v_compare2 BOOLEAN;
BEGIN
    v_compare1 :=null;
    v_compare2 := false;
    v_resultado := v_compare1 AND v_compare2;
    dbms_output.put_line('O valor de v_resultado é: '|| CASE v_resultado WHEN TRUE THEN 'TRUE'
                                                                            WHEN FALSE THEN 'FALSE'
                                                                            ELSE 'NULL' 
                                                                            END);
END;

--exemplo 5


SET serveroutput ON
DECLARE
    v_resultado BOOLEAN;
    v_compare1 BOOLEAN;
    v_compare2 BOOLEAN;
BEGIN
    v_compare1 :=true;
    v_compare2 := true;
    v_resultado := v_compare1 OR v_compare2;
    dbms_output.put_line('O valor de v_resultado é: '|| CASE v_resultado WHEN TRUE THEN 'TRUE'
                                                                            WHEN FALSE THEN 'FALSE'
                                                                            ELSE 'NULL' 
                                                                            END);
END;


--exemplo 6


SET serveroutput ON
DECLARE
    v_resultado BOOLEAN;
    v_compare1 BOOLEAN;
    v_compare2 BOOLEAN;
BEGIN
    v_compare1 :=true;
    v_compare2 := false;
    v_resultado := v_compare1 OR v_compare2;
    dbms_output.put_line('O valor de v_resultado é: '|| CASE v_resultado WHEN TRUE THEN 'TRUE'
                                                                            WHEN FALSE THEN 'FALSE'
                                                                            ELSE 'NULL' 
                                                                            END);
END;

--exemplo 7


SET serveroutput ON
DECLARE
    v_resultado BOOLEAN;
    v_compare1 BOOLEAN;
    v_compare2 BOOLEAN;
BEGIN
    v_compare1 :=null;
    v_compare2 := true;
    v_resultado := v_compare1 OR v_compare2;
    dbms_output.put_line('O valor de v_resultado é: '|| CASE v_resultado WHEN TRUE THEN 'TRUE'
                                                                            WHEN FALSE THEN 'FALSE'
                                                                            ELSE 'NULL' 
                                                                            END);
END;

--exemplo 8


SET serveroutput ON
DECLARE
    v_resultado BOOLEAN;
    v_compare1 BOOLEAN;
    v_compare2 BOOLEAN;
BEGIN
    v_compare1 :=null;
    v_compare2 := false;
    v_resultado := v_compare1 OR v_compare2;
    dbms_output.put_line('O valor de v_resultado é: '|| CASE v_resultado WHEN TRUE THEN 'TRUE'
                                                                            WHEN FALSE THEN 'FALSE'
                                                                            ELSE 'NULL' 
                                                                            END);
END;


--slide 72
--UTILIZE a instrução CASE em blocos procedurais e intrução SQL (em blocos procedurais- evita erros/em instruções SQL auxilia na melhoria do desmepenho)
--Cautela ao efetuar comparações que utilizam variaveis ou objetos que, eventualmente, podem assumir valores nulos (use NVL)


--FUNÇÕES: blocos PL/SQL nomeados os quais permitem executar tarefas,retornando algo como resultado

--FUNÇÕES CONDICIONAIS: DECODE, CASE,NVL

--FUNÇÕES DE AGRUPAMENTO: AVG,MIN,MAX,COUNT,SUM

--FUNÇÕES DE CONVERSÃO: TO_CHAR,TO_DATE,TO_NUMBER

--OUTRAS FUNÇÕES: LENGTH,LOWER,UPPER,INITCAP,REPLACE,USER



--QUAL O DETALHE QUE TEM QUE TOMAR PARA USO DO NVL: devemos nos atentar ao valor esperado pela coluna que vamos retirar o valor null, se for esperado valores number, devemos substituir por um valor number e assim em diante. (unica forma de não respeitar isso, é fazendo o CASTING)



--COALESCE: retorna entre varios valores o primeiro valor não nulo

--exemplo 1: calcular comissao de 10% para quem não possui comissao maxima e nem comissao gravada na tb_empregado

ALTER TABLE tb_empregado
    ADD (percentual_comissao_maxima NUMBER);
    
    
SELECT percentual_comissao,
    COALESCE(percentual_comissao_maxima,percentual_comissao,0.1),
    COALESCE(percentual_comissao_maxima,percentual_comissao,0.1)*salario AS Valor_Comissao
FROM tb_empregado
WHERE id_departamento IN(70,80);



--TIPOS DE DADOS COMPOSTOS: Criar e manipular registros em PL/SQL definidos pela usuario
--Variaveis escalares: armazenam apenas um valor,ex: DATE,VARCHAR2,NUMBER...
--Variaveis Compostas: Armazenam multiplos valores,Normalmente são declaradas como Registros ou Coleções

--Registros: viabilizam o armazenamento de multiplos valores em um vetor
--suportam campos dos seguintes tipos: ESCALARES, RECORD, INDEX BY table

--exemplo 1 (slide 122)

SET serveroutput ON
DECLARE
    TYPE tipo_reg_emp IS RECORD(
        id_empregado    NUMBER(6),
        nome            VARCHAR2(20),
        sobrenome       VARCHAR2(25));
    registro_emp        tipo_reg_emp;
BEGIN
    SELECT id_empregado, nome, sobrenome
    INTO registro_emp
    FROM tb_empregado
    WHERE ROWNUM=1;
    
    dbms_output.put_line('O nome do empregado com ID '||registro_emp.id_empregado||' é '|| registro_emp.nome||' '||registro_emp.sobrenome);
END;


--%ROWTYPE: possibilita a criação de uma variavel contendo uma coleção de colunas de uma determinada tabela ou até mesmo de uma visão, quando utilizamos o atributo %ROWTYPE,tanto o nome da tabela e ou visão devem ser pré-determinados, sua principal vantagem é a possibilidade de ser utilizado dinamicamente

SET serveroutput ON
DECLARE
    registro_emp tb_empregado%ROWTYPE;
BEGIN
    SELECT * INTO registro_emp
    FROM tb_empregado
    WHERE ROWNUM =1;
    
    dbms_output.put_line('O nome do empregado com ID '|| registro_emp.id_empregado|| ' é '||registro_emp.nome||' '|| registro_emp.sobrenome);
END;

--slide 127
--COLEÇÕES: proporciona armazenar multiplos valores em uma matriz, Coleções são denominadas unidades logicas de multiplas ocorrencias(tuplas) e multiplos atributos,Eventualmente podem conter atributos de tipos de dados distinto
--São segmentadas em tres tipos: Index By Tables, Nested Tables, Varrays

--exemplo 1 NESTED TABLEs

SET serveroutput ON
DECLARE
    TYPE tipo_emp IS TABLE OF tb_empregado%ROWTYPE;
    registro_emp    tipo_emp;
BEGIN
    SELECT * BULK COLLECT INTO registro_emp --cria uma tabela virtual, para armazenar varios valores (fica em cache)
    FROM tb_empregado;
    --WHERE ROWNUM = 1;         --comentado para exibir todos os registros
    
    FOR i IN registro_emp.first .. registro_emp.last LOOP
        dbms_output.put_line('O nome do empregado com ID '|| registro_emp(i).id_empregado|| ' é '|| registro_emp(i).nome||' ' || registro_emp(i).sobrenome);
    END LOOP;
END;


--MÉTODOS: implementados para manipular coleções:
--          EXISTS= verifica a existencia de um determinado elemento
--          COUNT= retorna o total de elementos
--          LIMIT= retorna o limite do varray
--          FIRST e LAST= posiciona respectivamente o primeiro e o ultimo elemento
--          PRIOR e NEXT= posiciona respectivamente o elemento anterior e próximo
--          EXTEND= incrementa o tamanho
--          TRIM= reduz o tamanho
--          DELETE= remove elemento(s)


--EXEMPLO:

SET serveroutput ON
DECLARE
    TYPE tipo_emp IS TABLE OF tb_empregado%ROWTYPE;
    registro_emp    tipo_emp;
BEGIN
    SELECT * BULK COLLECT INTO registro_emp
    FROM tb_empregado;
   -- WHERE ROWNUM = 1;     --comentado para exibir todos os registros
    
    IF NOT registro_emp.EXISTS(10) THEN
        dbms_output.put_line('Não existe o 10* elemento na coleção');
    END IF;
    
    dbms_output.put_line('Existe(m) '|| TO_CHAR(registro_emp.COUNT)||' elemento(s) na coleção');
    
    registro_emp.DELETE;
    dbms_output.put_line('Após excluir todos os elementos, existe(m) '|| TO_CHAR(registro_emp.COUNT)|| ' elemento(s) na coleção');
END;

--OBSERVAÇÕS: dê preferencia a utilizar Coleções ao invés de Cursores(mais performance)(OBS.Geraldo prefere Cursores). No que se refere a manipulação de conjuntos de dados provenientes de tabelas do BD, utilize NESTED TABLEs. Evite manutenções posteriores e possiveis erros nas aplicações declarando registros por meio do atributo %ROWTYPE

--Resolução de problemas

--1)Necessidade de exibir o nome e sobrenome do empregado cujo email corresponda a VJONES

--Solução= Utilize dbms_output.put_line para exibir o string contendo o nome e sobrenome

SET serveroutput ON
DECLARE
    v_nome      VARCHAR2(20);
    v_sobrenome VARCHAR2(25);
BEGIN
    SELECT nome,sobrenome INTO v_nome,v_sobrenome
    FROM tb_empregado
    WHERE email='VJONES';
    
    dbms_output.put_line(v_nome||' '||v_sobrenome);
END;


--2) Necessidade de referenciar um bloco de código dentro de um segmento de código,esse presente em seu programa

--Solução= Atribua um rótulo para o bloco de codigo que voce deseja fazer referencia. Uma etiqueta PL/SQL consiste de um identificador unico entre colchetes angulares duplos <<>>
--exmeplo1:

SET serveroutput ON
<<depto_block>>
DECLARE
    v_nm_depto VARCHAR2(30);
BEGIN
    SELECT nm_departamento 
    INTO v_nm_depto
    FROM tb_departamento
    WHERE id_departamento = 230;
    
    dbms_output.put_line('Nome depto '||v_nm_depto);
END depto_block;


-- exemplo 2

SET serveroutput ON
<<outer_block>>
DECLARE
    v_id_gerente        NUMBER(6) := '&id_gerente_atual';
    v_contador_depto        NUMBER:= 0;
BEGIN
    SELECT COUNT(*) INTO v_contador_depto
    FROM tb_departamento
    WHERE id_gerente = outer_block.v_id_gerente;
    
    IF v_contador_depto>0 THEN
        <<inner_block>>
        DECLARE
            v_nm_depto  VARCHAR2(30);
            v_id_gerente    NUMBER(6) := '&novo_id_gerente';
        BEGIN
            SELECT nm_departamento INTO v_nm_depto
            FROM tb_departamento
            WHERE id_gerente = outer_block.v_id_gerente;
            
            UPDATE tb_departamento
                SET id_gerente = inner_block.v_id_gerente
            WHERE id_gerente = outer_block.v_id_gerente;
            
            DBMS_OUTPUT.PUT_LINE('ID do gerente do Depto '|| v_nm_depto||' foi alterado!');
        END inner_block;
        
        ELSE 
            DBMS_OUTPUT.PUT_LINE('Nenhum depto selecionado para o gerente');
            
        END IF;
        
EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('Não existe depto para o gerente');
END outer_block;




--3) Como ignorar as variaveis de substituição?
--Voce deseja executar um script que contem elementos que são semelhantes as variaveis de substituição,mas voce não pretende que eles sejam variaveis de substituição
--voce deseja que o interpretador simplesmente ignore o prompt de entrada

--Solução: Uma solução é preceder o caracter & com um caracter escape, o caractere escape diz que o & não pretende ser uma referencia de variavel de substituição.

--exemplo1:

SET ESCAPE '\'
INSERT INTO tb_departamento
VALUES(sq_departamento.nextval,'Teste \& Teste',null,null);-- 'Teste & Teste'


SELECT *
FROM tb_departamento;

--Solução 2: é desativar completamente o recurso de variavel de substituição, o próximo exemplo usa o SET DEFINE OFF comando que diz ao interpretador SQL que ele deve ignorar todas as variaveis de substituição

SET DEFINE OFF
INSERT INTO tb_departamento
VALUES(sq_departamento.nextval,'Importação & Exportação',null,null);


SELECT *
FROM tb_departamento;



--4)Voce está interessado em mudar a variavel de substituição de & para algum ooutro caractere

--Solução: Emitir o comando SET DEFINE para definir o novo caractere, por exemplo: digamos que voce deseja que o caractere de substituição seja um acento circunflexo (^)


SET DEFINE ^

SELECT nm_departamento
FROM tb_departamento
WHERE id_departamento = ^id_depto;


SET DEFINE & --voltando...



--5) voce deseja criar uma variavel com o mesmo datatype de uma coluna especifica de uma tabela do BD

--Solução: Utilize o atributo %TYPE associado ao nome da coluna, a fim de criar a nova variavel, note que a variavel V_NM_DEPTO é criada com o mesmo tipo de dado da coluna NM_DEPARTAMENTO da tabela TB_DEPARTAMENTO
--slide 157




--6)Recuperar uma unica linha do banco de dados.Voce esta interessado emr etornar uma linha especifica de uma determinada tabela armazenada no banco de dados por meio de uma consultas considerada simples

--Solução: Utilize a sintaxe SELECT ... INTO, a fim de recuperar a linha do BD.Voce pode escolher para recuperar uma ou mais colunas de dados a partir da linha correspondente.
--exemplo a seguir descreve um cenario em que a tabela é consultada para retornar varias colunas a parti de uma unica linha

--exemplo1:

SET serveroutput ON
DECLARE
    v_nome      VARCHAR2(20);
    v_sobrenome VARCHAR2(25);
    v_email     VARCHAR2(25);
BEGIN
    SELECT nome,sobrenome,email
    INTO v_nome,v_sobrenome,v_email
    FROM tb_empregado
    WHERE id_empregado=100;
    
    DBMS_OUTPUT.PUT_LINE('Dados do empregado: '||v_nome||' '||v_sobrenome||' '||v_email);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Nenhum empregado localizado para esse ID');
        
    WHEN TOO_MANY_ROWS THEN
        DBMS_OUTPUT.PUT_LINE('Mais de um empregado localizado para esse ID');
END;


--exemplo 2 (primeiro contato com cursor, slide 166):

SET serveroutput ON
DECLARE
    CURSOR emp_cursor IS
        SELECT nome,sobrenome,email
        FROM tb_empregado
            WHERE id_empregado=&id_emp;
    v_nome      VARCHAR2(20);
    v_sobrenome VARCHAR2(25);
    v_email     VARCHAR2(25);
BEGIN
    OPEN emp_cursor;
        FETCH emp_cursor INTO v_nome,v_sobrenome,v_email;
        IF emp_cursor%NOTFOUND THEN
            RAISE NO_DATA_FOUND;
        ELSE
        --segundo fetch para verificar se existe mais de uma linha retornada
            FETCH emp_cursor INTO v_nome,v_sobrenome,v_email;
            
            IF emp_cursor%FOUND THEN
                RAISE TOO_MANY_ROWS;
            ELSE
                DBMS_OUTPUT.PUT_LINE('Dados do empregado: '||v_nome||' '||v_sobrenome||' '||v_email);
            END IF;
        END IF;
        CLOSE emp_cursor;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Nenhum empregado localizado para esse ID');
        
    WHEN TOO_MANY_ROWS THEN
        DBMS_OUTPUT.PUT_LINE('Mais de um empregado localizado para esse ID');
END;



--7)Voce tem uma variavel e uma coluna compartilhando o mesmo nome.Voce quer se referir a ambas na mesma intrução SQL.Por exemplo,voce gostaria de procurar registros onde SOBRENOME seja igual a um ultimo nome,esse fornecido por um usuario através de um argumento para uma chamada de procedimento

--Solução: Voce pode usar a notação de ponto para qualificar totalmente o nome da variavel local com o nome do procedimento para que o PL/SQL possa diferenciar entre os dois

--exemplo 1:

CREATE OR REPLACE PROCEDURE sp_recupera_info_emp(sobrenome IN VARCHAR2) AS
v_nome      VARCHAR2(20);
v_sobrenome VARCHAR2(25);
v_email     VARCHAR2(25);
BEGIN
    SELECT nome,sobrenome,email
    INTO v_nome,v_sobrenome,v_email
    FROM tb_empregado
    WHERE sobrenome = sp_recupera_info_emp.sobrenome;
    
    DBMS_OUTPUT.PUT_LINE('Dados do empregado: '|| v_nome||' '||v_sobrenome||' - '||v_email);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Nenhum empregado localizado com esse sobrenome: '||sp_recupera_info_emp.sobrenome);
END;

--TESTE 1
SET serveroutput ON
BEGIN
    sp_recupera_info_emp('Abel');
END;

--TESTE 2

SET serveroutput ON
BEGIN
    sp_recupera_info_emp('Andrade');
END;


--Exemplo 2

SET serveroutput ON
<<emp_info>>
DECLARE
    sobrenome       VARCHAR2(25) := 'Fay';
    v_nome          VARCHAR2(20);
    v_sobrenome     VARCHAR2(25);
    v_email         VARCHAR2(25);
BEGIN
    SELECT nome,sobrenome,email
    INTO v_nome,v_sobrenome,v_email
    FROM tb_empregado
    WHERE sobrenome =emp_info.sobrenome;
    
    DBMS_OUTPUT.PUT_LINE('Dados do empregado '|| v_nome|| ' '|| v_sobrenome|| ' - '|| v_email);
END;



--8) Voce quer declarar algumas variaveis em seu bloco anonimo as quais correspondam aos mesmos tipos de dados de algumas colunas presentes em uma tabela especifica
--se o tipo de dado em uma dessas colunas for alterado,voce gostaria que o bloco anonimo seja atualizado automaticamente, considerando o novo tipo de dado para a variavel correspondente

--Solução: Utilize o atributo %TYPE nas colunas da tabela para identificar os tipos de dados que será retornado em suas variaveis locais, em vez de fornecer um tipo de dado codificado para uma variavel, acrescente %TYPE para o nome da coluna ora presente no BD. 
--Se o fizer, será aplicado o tipo de dado da coluna especificada para a variavel que voce está declarando
--slide 176


--9) Ao invés de recuperar somente poucas colunas através de uma consulta voce prefere devolver todas as colunas
--Pode ser uma tarefa demorada para replicar cada uma das colunas da tabela em seu aplicativo criando uma varaivel local para cada coluna, juntamente com os respectivos datatypes
--Embora voce possa certamente fazer uso do atributo %TYPE ao declarar as varaiveis, voce prefere recuperar a linha inteira em um unico objeto
--Alem disso, voce gostaria que o objeto o qual os dados serão armazenados tenha a capacidade de assumir os mesmos tipos de dados para cada uma das colunas que estão sendo devolvidos assim como voce faria usando o atributo %TYPE








--AULA 3 SLIDES NOVOS

--ESTRUTURAS DE CONTROLE (revisao)
--exemplo 1 (usando between)
SET serveroutput ON
DECLARE
    v_x NUMBER(2) :=10;
BEGIN
    IF(v_x BETWEEN 5 AND 20) THEN
        dbms_output.put_line('True');
    ELSE
        dbms_output.put_line('False');
    END IF;
    
    IF (v_x BETWEEN 5 AND 10) THEN
        dbms_output.put_line('True');
    ELSE
        dbms_output.put_line('False');
    END IF;
    
    IF(v_x BETWEEN 11 AND 20) THEN
        dbms_output.put_line('True');
    ELSE
        dbms_output.put_line('False');
    END IF;
END;


--EXEMPLO 2 (usando IN e IS NULL)

SET serveroutput ON
DECLARE
    v_letra VARCHAR2(1) := 'm';
BEGIN
    IF(v_letra IN ('a','b','c'))THEN
        dbms_output.put_line('true');
    ELSE
        dbms_output.put_line('false');
    END IF;
    
    IF(v_letra IN('m','n','o')) THEN
        dbms_output.put_line('true');
    ELSE
        dbms_output.put_line('false');
    END IF;
    
    IF(v_letra IS NULL)THEN
        dbms_output.put_line('true');
    ELSE
        dbms_output.put_line('false');
    END IF;
END;



--CURSORES (slide 9)
--O Oracle cria uma área de memória, conhecida como area de contexto
--Area de contexto é utilizada para o processamento de uma instrução SQL (contem todas as informações necessarias para o processamento, por exemplo, numero de linhas processadas, etc)

--Um CURSOR é um ponteiro para essa area de contexto

--PL/SQL controla a area de contexto atraves de um cursor

--Um cursor mantem as linhas (uma ou mais) retornadas por uma instrução SQL

--O conjunto de linhas que o cursor detém é caracterizado como o conjunto ativo

--è permitido nomear um cursor de modo que permite ao mesmo ser referenciado em um programa para buscar e processar as linhas retornadas pela instrução SQL, uma de cada vez

--Existem dois tipos de cursores: implicitos e explicitos

--Toda vez que uma determinada instrução SQL é executada, um cursor IMPLICITO é criado pelo ORACLE

--Permite analisar o status de uma instrução SQL por meio do uso dos atributos


--Atributos mais usuais: 
--%FOUND: retorna TRUE quando uma isntrução DML alterar uma linha e ou DQL acessar uma linha
--%ISOPEN: sempre retorna FALSE para qualquer cursor implicito
--%NOTFOUND: retorna TRUE quando uma instru~ção DML alterar uma linha ou DQL não poder acessar uma linha
--%ROWCOUNT: retornar o numero de linhas alteradas por uma instrução DML ou o numero de linhas retornadas por uma instrução SELECT INTO
--Qualquer atributo do cursor SQL serão acessado como SQL%NOME_ATRIBUTO

--cursores implicitos
--exemplo 1

SET serveroutput ON
DECLARE
    v_total_linhas NUMBER(2);
BEGIN
    UPDATE tb_clientes
        SET salario= salario +500;
        
    IF SQL%NOTFOUND THEN
        DBMS_OUTPUT.PUT_LINE('Nenhum cliente selecionado');
    ELSIF SQL%FOUND THEN
        v_total_linhas := SQL%ROWCOUNT;
        DBMS_OUTPUT.PUT_LINE(v_total_linhas||' clientes selecionados');
    END IF;
END;


-- EXEMPLOS 2

SET serveroutput ON
BEGIN
    UPDATE tb_empregado
        SET nome = nome
    WHERE ROWNUM = 1;
    
    IF SQL%FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Foi(ram) atualizada(s) '|| SQL%ROWCOUNT|| ' linha(s)');
    ELSE
        dbms_output.put_line('nenhuma linha foi atualizada');
    END IF;
END;


-- Exemplo 3:

SET serveroutput ON
DECLARE
    v_n NUMBER;
BEGIN
    SELECT 1 INTO v_n
    FROM dual;
    
    dbms_output.put_line('Selecionado(s) '||SQL%ROWCOUNT||' linha(s)');
END;


--Exemplo 4: designar as colunas como um grupo para tipos de dados record

SET serveroutput ON
DECLARE
    TYPE reg_emp IS RECORD(
        id_emp      tb_empregado.id_empregado%TYPE,
        nome        tb_empregado.nome%TYPE,
        sobrenome   tb_empregado.sobrenome%TYPE);
    dataset     REG_EMP;
BEGIN
    SELECT id_empregado,nome,sobrenome
    INTO dataset
    FROM tb_empregado
    WHERE ROWNUM <2;
    
    DBMS_OUTPUT.PUT_LINE('Empregado selecionado '|| dataset.nome);
END;


--Exemplo 5: Uso de um cursor implicito de multiplas linhas em um cursor LOOP FOR

SET serveroutput ON
BEGIN
    FOR i IN(SELECT nome,sobrenome,salario
             FROM tb_empregado)LOOP
        DBMS_OUTPUT.PUT_LINE('Nome: '||i.nome||'     Sobrenome: '||i.sobrenome||'     Salario: '||i.salario);
    END LOOP;
END;



--Cursores explicitos são definidos pelo desenvolvedor, promove maior controle sobre a area de contexto. Um cursor explicito deve ser definido na seção de declaração do bloco PL/SQL
-- Criado em uma isntrlçao SELECT que retorna mais d euma linha

--Manipular um cursor explicito envolve 4 etapas:
--1)declarar o cursor para incializar a memoria
--2)Abrir o cursor para a alocação de memoria
--3)Buscar o cursor para recuperar dados
--4)Fechar o cursor para liberar memoria alocada

--A declaração de um cursor envolve um nome e uma instrução SELECT associada (slide 25)
--Ao abrir um cursor alocamos memoria para o mesmo, ele fica pronto para buscar as linhas retornadas pela isntrução SQL
--O fechamento do cursor significa liberar a memoria alocada

--Os dois metodos abaixo proporcionam a recuperação de linhas em um cursor explicito
--LOOP simples: imprescindivel abrir e fechar o cursor, Verificação da existencia de linhas ativas no cursor.
--FOR LOOP: utilizado em cursores implicitos ou explicitos. A declaração do cursor torna-se opcional. Não existe a necessidade de abrir,recuperar,fechar o cursor de maneira explicita

--exemplo 1:


SET serveroutput ON
DECLARE
    v_id        tb_clientes.id_cliente%TYPE;
    v_nome      tb_clientes.nm_cliente%TYPE;
    v_endereco  tb_clientes.endereco%TYPE;
    
    CURSOR c_clientes IS
        SELECT id_cliente,nm_cliente,endereco
        FROM tb_clientes;
BEGIN
    OPEN c_clientes;
    LOOP
        FETCH c_clientes INTO v_id,v_nome,v_endereco;
        EXIT WHEN c_clientes%NOTFOUND;
        dbms_output.put_line(v_id||' '||v_nome||' '||v_endereco);
    END LOOP;
    CLOSE c_clientes;
END;


--exemplo2:

SET serveroutput ON
DECLARE
    CURSOR cur_emp IS
        SELECT id_empregado,nome,sobrenome
        FROM tb_empregado
        WHERE ROWNUM<5;
    v_id_emp        tb_empregado.id_empregado%TYPE;
    v_nome          tb_empregado.nome%TYPE;
    v_sobrenome     tb_empregado.sobrenome%TYPE;
BEGIN
    OPEN cur_emp;
    IF cur_emp%ISOPEN THEN
        LOOP
            FETCH cur_emp INTO v_id_emp,v_nome,v_sobrenome;
            EXIT WHEN cur_emp%NOTFOUND;
            dbms_output.put_line('O nome do empregado com ID '|| v_id_emp||' é: '|| v_nome||' '||v_sobrenome);
        END LOOP;
    END IF;
    
    CLOSE cur_emp;
END;


--exemplo 3:

SET serveroutput ON
DECLARE
    CURSOR cur_emp IS
        SELECT id_empregado,nome,sobrenome
        FROM tb_empregado
        WHERE ROWNUM<5;
BEGIN
    FOR emp_linha IN cur_emp
    LOOP
        dbms_output.put_line('O nome do empregado com ID: '||emp_linha.id_empregado||' é: '||emp_linha.nome||' '||emp_linha.sobrenome);
    END LOOP;
END;


--EXEMPLO 4:

SET serveroutput ON
BEGIN
    FOR emp_linha IN(SELECT id_empregado, nome, sobrenome
                     FROM tb_empregado
                     WHERE ROWNUM <5)
    LOOP
        dbms_output.put_line('O nome do empregado com ID '||emp_linha.id_empregado||' é: '||emp_linha.nome||' '||emp_linha.sobrenome);
    END LOOP;
END;

--Cursores explicitos eventualmente podem incluir parametros. Tal recurso permite que os cursores sejam abertos e fechados diversas vezes, produzindo resultado distintos em cada circunstacia (active sets),dependendo exclusivamente do valor dos parametros
--possibilidade de executar a mesma instrução select multiplas vezes, flexibilizando apenas um ou mais valores no predica da clausula WHERE

--Exemplo 5

SET serveroutput ON
DECLARE
    CURSOR cur_emp(p_id_emp NUMBER)IS
        SELECT id_empregado,nome,sobrenome
        FROM tb_empregado
        WHERE id_empregado=p_id_emp;
        
    v_id_emp        tb_empregado.id_empregado%TYPE;
    v_nome          tb_empregado.nome%TYPE;
    v_sobrenome     tb_empregado.sobrenome%TYPE;
BEGIN
    OPEN cur_emp(100);
    FETCH cur_emp INTO v_id_emp, v_nome,v_sobrenome;
        dbms_output.put_line('O nome do empregado com ID '||v_id_emp||' é: '|| v_nome||' '||v_sobrenome);
    CLOSE cur_emp;
    
    OPEN cur_emp(101);
    FETCH cur_emp INTO v_id_emp,v_nome,v_sobrenome;
        dbms_output.put_line('O nome do empregado com ID '||v_id_emp||' é: '|| v_nome||' '||v_sobrenome);
    CLOSE cur_emp;
END;




--TRATAMENTO DE EXCEÇÕES (EXCEPTIONS)
--Uma condição de erro durante a execução de um determinado programa é chamado de exceção em PL/SQL
--Programas desenvolvidas em PL/SQL utilizam tais condições por meio do uso de bloco de exceção,permitindo que uma ação apropriada possa ser tomada quando ocorrer uma condição de erro
--Existem dois tipos de exceções: Exceções pré-definidas e Exceções definidas pelo usuario

--Exemplo 1:

SET serveroutput ON
DECLARE
    v_id_cliente        tb_clientes.id_cliente%TYPE :=8;
    v_nome              tb_clientes.nm_cliente%TYPE;
    v_endereco          tb_clientes.endereco%TYPE;
BEGIN
    SELECT nm_cliente,endereco INTO v_nome,v_endereco
    FROM tb_clientes
    WHERE id_cliente= v_id_cliente;
    
    dbms_output.put_line('Nome: '||v_nome);
    dbms_output.put_line('Endereço: '||v_endereco);
EXCEPTION
    WHEN no_data_found THEN
        dbms_output.put_line('Cliente inexistente!');
    WHEN others THEN
        dbms_output.put_line('Erro!');
END;


--exemplo 2:

SET serveroutput ON
DECLARE
    v_nome      tb_empregado.nome%TYPE;
BEGIN
    SELECT nome INTO v_nome
    FROM tb_empregado
    WHERE nome='David';
EXCEPTION
    WHEN too_many_rows THEN
        dbms_output.put_line('A consulta retornou mais que uma linha. Utilize coleçoes ou cursores');
END;

--EXEMPLO 3:

SET serveroutput ON
DECLARE
    v_nome NUMBER;
BEGIN
    SELECT nome INTO v_nome
    FROM tb_empregado
    WHERE ROWNUM = 1;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ocorreu um erro! '|| SQLERRM);
END;


--Observações slide 49

--Exceções são segmentadas em 2 tipos: 
--Execeções implicitas: são as Pré-definidas pelo SGBD
--Exceções Explicitas: São as implementadas pelo Desenvolvedor

--Exceções Explicitas slide 59

--exemplo1:

SET serveroutput ON
DECLARE
    v_id_cliente        tb_clientes.id_cliente%TYPE := &id_cliente;
    v_nome              tb_clientes.nm_cliente%TYPE;
    v_endereco          tb_clientes.endereco%TYPE;
    --Exceção definida pelo usuario
    ex_id_invalido EXCEPTION;
BEGIN
    IF v_id_cliente <= 0 THEN
        RAISE ex_id_invalido;
    ELSE
        SELECT nm_cliente, endereco INTO v_nome,v_endereco
        FROM tb_clientes
        WHERE id_cliente = v_id_cliente;
        
        dbms_output.put_line('Nome: '|| v_nome);
        dbms_output.put_line('Endereço: '||v_endereco);
    END IF;
EXCEPTION
    WHEN ex_id_invalido THEN
        dbms_output.put_line('ID deve ser maior que zero!');
    WHEN no_data_found THEN
        dbms_output.put_line('Nenhum cliente encontrado!');
    WHEN others THEN
        dbms_output.put_line('Erro!');
END;


--exemplo 2

SET serveroutput ON
DECLARE
    v_nome tb_empregado.nome%TYPE;
BEGIN
    SELECT nome INTO v_nome
    FROM tb_empregado
    WHERE nome='David';
EXCEPTION
    WHEN too_many_rows THEN
        dbms_output.put_line(SQLERRM);
        RAISE_APPLICATION_ERROR(-20000,'Erro adaptado.Não é possível gravar valores de multiplas linhas em uma variavel escalar');
END;


--EXEMPLO 3:

SET serveroutput ON
DECLARE
    v_nome  tb_empregado.nome%TYPE;
    v_contador  NUMBER;
BEGIN
    SELECT COUNT (1) INTO v_contador
    FROM tb_empregado
    WHERE nome='David';
    
    IF v_contador > 0 THEN
        BEGIN --INICIO DO BLOCO FILHO
            SELECT nome INTO v_nome
            FROM tb_empregado
            WHERE nome = 'David';
        EXCEPTION
            WHEN too_many_rows THEN
                dbms_output.put_line('A consulta retornou mais que uma linha');
            WHEN others THEN
                dbms_output.put_line(SQLERRM);
        END;
    END IF;
END;


--Exemplo 4

SET serveroutput ON
DECLARE
    v_nome tb_empregado.nome%TYPE;
    v_contador NUMBER;
BEGIN
    SELECT COUNT(1) INTO v_contador
    FROM tb_empregado
    WHERE nome='David';
    
    IF v_contador >0 THEN
        BEGIN--inicio bloco fi
            SELECT nome INTO v_nome
            FROM tb_empregado
            WHERE nome ='David';
        END;
    END IF;
EXCEPTION
    WHEN too_many_rows THEN
        dbms_output.put_line('A consulta retornou mais que uma linha');
    WHEN OTHERS THEN
        dbms_output.put_line(SQLERRM);
END;


--EXEMPLO 5

SET serveroutput ON
DECLARE
    v_nome  tb_empregado.nome%TYPE;
    v_contador  NUMBER;
BEGIN
    SELECT COUNT (1) INTO v_contador
    FROM tb_empregado
    WHERE nome='David';
    
    IF v_contador >0 THEN
        BEGIN
            SELECT nome INTO v_nome
            FROM tb_empregado
            WHERE nome='David';
        EXCEPTION
            WHEN too_many_rows THEN
                dbms_output.put_line('A consulta retornou mais que uma linha');
        END;
    END IF;
EXCEPTION
    WHEN others THEN
        dbms_output.put_line(SQLERRM);
END;


--STORED PROCEDURES (SLIDE 76)

