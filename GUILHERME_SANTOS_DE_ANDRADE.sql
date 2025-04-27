--GUILHERME SANTOS DE ANDRADE / 24609 / SISTEMAS DE INFORMAÇÃO

--(utilizarei o nome da tabela 'tb_empregado' como 'tb_empregado2', pois juntei o esquema feito em sala de aula com o esquema RH, 
--logo tive que criar a tb_empregado com outro nome)

--exercicio 1:
SELECT nome, NVL(TO_CHAR(salario*percentual_comissao),'Nenhuma comissão') AS COMISSÃO
FROM tb_empregado2
ORDER BY percentual_comissao ASC;

--exercicio 2:

SELECT e.nome AS Empregado, e.data_admissao AS "Empregado Data Admissao", 
        g.nome AS Gerente, g.data_admissao AS "Gerente Data Admissão"
FROM tb_empregado2 e
INNER JOIN tb_empregado2 g ON g.id_gerente = e.id_empregado
WHERE e.data_admissao < g.data_admissao;

--exercicio 3:

SELECT ROUND(MAX(salario)) AS Máximo,ROUND(MIN(salario))AS Minimo,ROUND(AVG(salario))AS média,ROUND(SUM(salario))AS Somatório
FROM tb_empregado2;

--exercicio 4:

SELECT id_gerente, MIN(salario)AS menor
FROM tb_empregado2 
WHERE id_gerente IS NOT NULL
GROUP BY id_gerente
HAVING MIN(salario)>=1000
ORDER BY menor ASC;

--exercicio 5:

SELECT COUNT(*) AS "Total Empregados", SUM(CASE
                                    WHEN EXTRACT(YEAR FROM data_admissao) BETWEEN 1990 AND 1993
                                    THEN 1
                                    ELSE 0
                                END) AS "Contratados 1990-1993"
FROM tb_empregado2;

--Exercicio 6:

SELECT nome,RPAD('*',salario/1000,'*')AS "Funcionarios e seus salario"
FROM tb_empregado2
ORDER BY salario DESC;

--Exercicio 7:

SELECT (id_empregado || ', '  || id_gerente || ', ' || id_departamento || ', ' ||
        id_funcao || ', ' || nome || ', ' || sobrenome || ', ' || email || ', ' ||
        telefone || ', ' || data_admissao || ', ' || percentual_comissao || ', ' ||
        salario) AS Saida
FROM tb_empregado2;

--Exercicio 8:

SELECT nome, id_funcao, 
    CASE
        WHEN id_funcao='SH_CLERK' THEN 'A'
        WHEN id_funcao='ST_MAN' THEN 'B'
        WHEN id_funcao='AC_ACCOUNT' THEN 'C'
        WHEN id_funcao ='AC_MGR' THEN 'D'
        WHEN id_funcao ='IT_PROG' THEN 'E'
        ELSE '0'
    END AS Grade
FROM tb_empregado2
ORDER BY Grade ASC;

--Exercicio 9:

SELECT nome,ROUND(MONTHS_BETWEEN(SYSDATE, data_admissao)) AS meses_trabalhados
FROM tb_empregado2
ORDER BY meses_trabalhados ASC;

--Exercicio 10:

SELECT e.nome, d.nm_departamento,l.cidade||', '||l.estado
FROM tb_empregado2 e
INNER JOIN tb_departamento d ON d.id_departamento = e.id_departamento
INNER JOIN tb_localizacao l ON l.id_localizacao = d.id_localizacao
WHERE e.percentual_comissao IS NOT NULL;

--Exercicio 11:

GRANT SELECT,INSERT,UPDATE ON tb_departamento TO joao WITH GRANT OPTION; 

--Exercicio 12:

CREATE TABLE tb_departamento_2(
id          NUMBER(7),
nm_depto    VARCHAR2(25)
);

-- a)
INSERT INTO tb_departamento_2(id,nm_depto)
VALUES(1,'RH');
INSERT INTO tb_departamento_2(id,nm_depto)
VALUES(2,'Suporte');
INSERT INTO tb_departamento_2(id,nm_depto)
VALUES(3,'Juridico')

-- b)

COMMENT ON TABLE tb_departamento_2 IS 'Departamentos 2';

SELECT table_name,comments
FROM USER_TAB_COMMENTS
WHERE table_name = 'TB_DEPARTAMENTO_2';

--Exercicio 13:

CREATE TABLE tb_empregado_2(
id          NUMBER(7),
sobrenome   VARCHAR2(25),
nome        VARCHAR2(25),
id_depto    NUMBER(7)
);

-- a)
ALTER TABLE tb_empregado_2
MODIFY(sobrenome   VARCHAR2(50));

DESCRIBE tb_empregado_2;

-- b)
ALTER TABLE tb_empregado_2
ADD(CONSTRAINT pk_emp_id PRIMARY KEY (id));

-- c)
ALTER TABLE tb_departamento_2
ADD(CONSTRAINT pk_tb_departamento_2_id PRIMARY KEY(id));

ALTER TABLE tb_empregado_2
ADD(CONSTRAINT fk_emp_dept_id FOREIGN KEY(id_depto)
    REFERENCES tb_departamento_2 (id));
    
DESCRIBE tb_departamento_2;
DESCRIBE tb_empregado_2;

-- Exercicio 14:

CREATE TABLE tb_empregado_3 AS
SELECT id_empregado AS ID, nome AS FIRST_NAME,sobrenome AS LAST_NAME,salario AS SALARY,id_departamento AS DEPT_ID
FROM tb_empregado2
WHERE 1=0;

-- a)
DELETE FIRST_NAME
FROM tb_empregado_3;

-- Exercicio 15:

SELECT id_empregado, nome, salario, salario+(salario*0.15) AS "Novo Salario"
FROM tb_empregado2;

-- Exercicio 16:

SELECT nome, 
       data_admissao,
       NEXT_DAY(ADD_MONTHS(TO_DATE(TO_CHAR(data_admissao, 'DD-MM') || ', ' || TO_CHAR(SYSDATE, 'YYYY'), 'DD-MM-YYYY'), 6) - 1, 'SEGUNDA') AS "Revisão"
FROM tb_empregado2;

-- Exercicio 17:

SELECT INITCAP(LOWER(nome)) AS "Nome Formatado",LENGTH(nome) AS "Tamanho do Nome"
FROM tb_empregado2
WHERE UPPER(SUBSTR(nome, 1, 1)) IN ('J', 'A', 'M');

--Exercicio 18:

SELECT REGEXP_REPLACE(SUBSTR(id_funcao,1,2),'SH','SHIPPING')
FROM tb_empregado2
ORDER BY id_funcao DESC;

--Exercicio 19:

SELECT id_departamento, MIN(salario) AS menor_salario, MAX(salario) AS "Maior Salario"
FROM tb_empregado2
GROUP BY id_departamento
HAVING menor_salario < 7000;

--Exercicio 20:

CREATE INDEX index_empregado_gerente ON tb_empregado2(id_empregado,id_gerente);

DROP INDEX index_empregado_gerente;

-------------------------------------------------------------------------------------------------------------------------------------------------------------

-- EXERCICIOS PARA ESTUDO DAQUI PARA BAIXO:

DESCRIBE tb_clientes;

SELECT nome,sobrenome
FROM tb_clientes
WHERE nome LIKE '%re%';

------------------------------

SELECT nome, sobrenome, CASE
                            WHEN LENGTH(nome||sobrenome)>10 THEN SUBSTR(nome,1,1)|| '. ' || SUBSTR(sobrenome,1,10)
                            ELSE nome || ' ' || sobrenome
                        END AS nome_formatado
FROM tb_clientes;

-------------------------------

SELECT COUNT(*),e.id_funcao,EXTRACT(YEAR FROM h.data_termino)AS ano_termino
FROM tb_empregado2 e
INNER JOIN tb_historico_funcao h ON h.id_empregado = e.id_empregado
GROUP BY ano_termino, e.id_funcao;

----------------------------------

SELECT COUNT(*) AS total, 
       TO_CHAR(data_admissao, 'DAY') AS dia_da_semana
FROM tb_empregado2
GROUP BY TO_CHAR(data_admissao, 'DAY')
HAVING COUNT(*) >= 20;

----------------------------------------

--EXEMPLO DE CRIAÇÃO DE PROCEDURE

CREATE OR REPLACE PROCEDURE atualizar_salario(
    --aqui ficam as variaveis que vai utilizar para executar o procedure (vai ser informadas na execução do mesmo)
    p_id_empregado IN NUMBER,
    p_novo_salario IN NUMBER)
IS
BEGIN
    -- atualizar o salario do funcionario
    UPDATE tb_empregado2
    SET salario = p_novo_salario
    WHERE employee_id = p_emp_id;

    COMMIT
    
    DBMS_OUTPUT.PUT_LINE('Salario atualizado!');
EXCEPTION
    WHEN NO_DATA_FOUND THEN 
        DBMS_OUTPUT.PUT_LINE('Algum dado não foi encontrado! (Cancelando execução)');
END;

--Para ver as mensagens geradas pelo DBMS_OUTPUT.PUT_LINE:
SET SERVEROUTPUT ON;

--Para executar o procedure
BEGIN
    atualizar_salario(1,10500);
END;

---------------------------------------------------

SELECT e.nome,f.ds_funcao,data_admissao
FROM tb_empregado2 e
INNER JOIN tb_funcao f ON f.id_funcao = e.id_funcao 
WHERE data_admissao BETWEEN '20 FEV,1987' AND '1 MAI,1989'
ORDER BY data_admissao ASC;

----------------------------------------------------------

SELECT UPPER(e.nome) AS nome, LENGTH(e.sobrenome) AS comprimento_sobrenome ,d.nm_departamento AS departamento, p.nm_pais AS pais
FROM tb_empregado2 e
INNER JOIN tb_departamento d ON d.id_departamento = e.id_departamento
INNER JOIN tb_localizacao l ON l.id_localizacao = d.id_localizacao
INNER JOIN tb_pais p ON p.id_pais = l.id_pais
WHERE SUBSTR(nome,1,1) IN ('B','L','A');

----------------------------------------------------------------------

SELECT e.nome,d.nm_departamento, l.cidade,l.estado
FROM tb_empregado2 e
INNER JOIN tb_departamento d ON d.id_departamento = e.id_departamento
INNER JOIN tb_localizacao l ON l.id_localizacao = d.id_localizacao
WHERE percentual_comissao IS NOT NULL;

-----------------------------------------------------------------------

SELECT e.nome || ' Trabalha para ' || NVL(g.nome,'Os acionistas')
FROM tb_empregado2 e
LEFT JOIN tb_empregado2 g ON g.id_gerente = e.id_empregado
ORDER BY g.nome DESC;

------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE ds_empregado(p_id  INTEGER)IS
    v_nome_completo VARCHAR2(100);
    v_ds_funcao     VARCHAR2(100);
BEGIN
    SELECT e.nome ||' '|| e.sobrenome, f.ds_funcao
    INTO v_nome_completo,v_ds_funcao
    FROM tb_empregado2 e
    INNER JOIN tb_funcao f ON f.id_funcao = e.id_funcao
    WHERE e.id_empregado = p_id;
    
    DBMS_OUTPUT.PUT_LINE('Nome: '|| v_nome_completo||' Função:'|| v_ds_funcao);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Empregado '|| p_id || ' não encontrado!');
END;

SET SERVEROUTPUT ON;

BEGIN
    ds_empregado(107);
END;

----------------------------------------------------------------------------------

SELECT salario
FROM tb_empregado2
ORDER BY id_departamento;

---------------------------------------------------------------------------------

SELECT nome, NVL(TO_CHAR(salario*percentual_comissao),'Nenhuma comissão') AS "COMISSÃO"
FROM tb_empregado2
ORDER BY percentual_comissao;

-----------------------------------------------------------------------------------

SELECT e.nome AS "Empregado",e.data_admissao AS "Empregado Data Admissão",g.nome AS "Gerente",g.data_admissao AS "Gerente Data Admissão"
FROM tb_empregado2 e
LEFT JOIN tb_empregado2 g ON g.id_empregado = e.id_gerente;

--------------------------------------------------------------------------------------

SELECT LEVEL,LPAD(' ',2*LEVEL-1)||nome||' '|| sobrenome AS funcionario
FROM tb_mais_funcionarios
START WITH id_funcionario-1
CONNECT BY PRIOR id_funcionario = id_gerente;

-----------------------------------------------------------------------------------------

SELECT nome || ' ' ||sobrenome AS nome, NVL(TO_CHAR(percentual_comissao*salario),'Nenhuma Comissão') AS "COMISSÂO"
FROM tb_empregado2
ORDER BY id_departamento;

----------------------------------------------------------------------------------------------------7

SELECT e.nome || ' ' || e.sobrenome AS "Empregado",e.data_admissao AS "Empregado Data Admissão", 
        g.nome|| ' ' || g.sobrenome AS "Gerente",g.data_admissao AS "Gerente Data Admissão"
FROM tb_empregado2 e
LEFT JOIN tb_empregado2 g ON e.id_gerente = g.id_empregado
WHERE e.data_admissao < g.data_admissao;

----------------------------------------------------------------------------------------------------------

SELECT ROUND(MAX(salario))AS "Máximo", ROUND(AVG(salario))AS "Média",ROUND(MIN(salario))AS "Mínimo",ROUND(SUM(salario)) AS "Somatório"
FROM tb_empregado2

---------------------------------------------------------------------------------------------------------------

SELECT MAX(AVG(salario))
FROM tb_empregado2
GROUP BY id_empregado;

SELECT id_empregado, salario
FROM tb_empregado2
WHERE salario = (SELECT MAX(salario)
                FROM tb_empregado2)
;

---------------------------------------------------------------------------------

SELECT id_gerente, MIN(salario)
FROM tb_empregado2
WHERE id_gerente IS NOT NULL
GROUP BY id_gerente
HAVING MIN(salario)>=1000
ORDER BY id_gerente ASC;

-------------------------------------------------------------------------------

SELECT COUNT(id_empregado) AS "Total contratados", SUM(CASE
                                WHEN EXTRACT(YEAR FROM data_admissao) BETWEEN 1990 AND 1993
                                THEN 1
                                ELSE 0
                                END) AS "Contratrado 1990-1993"
FROM tb_empregado2;

------------------------------------------------------------------------------------

SELECT nome, RPAD('*',salario/1000,'*') AS "Funcionários e seus Salários"
FROM tb_empregado2
ORDER BY salario DESC;

------------------------------------------------------------------------------------------

SELECT id_empregado || ', ' || id_gerente || ', ' || id_departamento || ', ' ||
        id_funcao || ', ' || nome || ', ' || sobrenome || ', ' || email || ', ' ||
        telefone || ', ' || data_admissao || ', ' || percentual_comissao || ', ' ||
        salario AS "Saída"
FROM tb_empregado2;

-------------------------------------------------------------------------------

SELECT id_funcao, DECODE(id_funcao,
                    'SH_CLERK', 'A',
                    'ST_MAN','B',
                    'AC_ACCOUNT','C',
                    'AC_MGR','D',
                    'IT_PROG','E',
                     0) AS grade
FROM tb_empregado2
ORDER BY  grade ASC;

SELECT nome, id_funcao, CASE 
                        WHEN id_funcao = 'SH_CLERK' THEN 'A'
                        WHEN id_funcao = 'ST_MAN' THEN 'B'
                        WHEN id_funcao = 'AC_ACCOUNT' THEN 'C'
                        WHEN id_funcao = 'AC_MGR' THEN 'D'
                        WHEN id_funcao = 'IT_PROG' THEN 'E'
                        ELSE '0'
                    END AS "Grade"
FROM tb_empregado2
ORDER BY "Grade" ASC;

-------------------------------------------------------------------

SELECT nome || ' '|| sobrenome AS nome, ROUND(MONTHS_BETWEEN(SYSDATE,data_admissao)) AS "Meses Trabalhado"
FROM tb_empregado2
ORDER BY "Meses Trabalhado" ASC;

---------------------------------------------------------------------

GRANT INSERT,SELECT,UPDATE ON tb_departamento TO joao WITH GRANT OPTION;

----------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE sp_get_emp(p_id_emp INTEGER)IS
p_nome_completo VARCHAR(100);
p_ds_funcao     VARCHAR(100);
BEGIN
    SELECT e.nome || ' ' || e.sobrenome, f.ds_funcao
    INTO p_nome_completo,p_ds_funcao
    FROM tb_empregado2 e
    INNER JOIN tb_funcao f ON e.id_funcao = f.id_funcao
    WHERE id_empregado = p_id_emp;
    
    DBMS_OUPUT.PUT_LINE('Nome: '|| p_nome_completo|| ' Função:'|| p_ds_funcao );
EXCEPTION
    WHEN NO_DATA_FOUND THEN
    DBMS_OUPUT.PUT_LINE ('Empregado '||p_id_emp||' não localizado!!!' );
END;

SET SERVEROUTPUT ON;

BEGIN 
    sp_get_emp(101);
END;

----------------------------------------------------------------------------------

SELECT REGEXP_REPLACE(SUBSTR(id_funcao,1,2),'SH','SHIPPING')
FROM tb_empregado2;

---------------------------------------------------------------------------------

SELECT nome, data_admissao, NEXT_DAY(ADD_MONTHS(TO_DATE(TO_CHAR(data_admissao, 'DD-MM') || ', ' || TO_CHAR(SYSDATE, 'YYYY'), 'DD-MM-YYYY'), 6) - 1, 'SEGUNDA') AS "Revisão"
FROM tb_empregado2;

---------------------------------------------------------------------------------

SELECT INITCAP(LOWER(nome))AS "Nome",LENGTH(nome)AS "Tamanho do Nome"
FROM tb_empregado2
WHERE SUBSTR(nome,1,1) IN ('J','A','M');

-------------------------------------------------------------------------------

ALTER TABLE tb_empregado_2 
ADD( CONSTRAINT pk_emp_id PRIMARY KEY(id));

ALTER TABLE tb_empregado_2 
MODIFY(sobrenome VARCHAR2(100));

ALTER TABLE tb_empregado_2 
ADD(CONSTRAINT fk_emp_dept_id FOREIGN KEY (id_depto)
    REFERENCES tb_departamento_2 (id));


INSERT INTO tb_departamento_2 (id,nm_depto)
SELECT id_departamento,nm_departamento
FROM tb_departamento;

SELECT *
FROM tb_departamento_2;

-----------------------------------------------------------------------------------

SELECT e.nome|| ' trabalha para o ' || NVL(g.nome,'os  Acionistas')
FROM tb_empregado2 e
LEFT JOIN tb_empregado2 g ON e.id_gerente = g.id_empregado
ORDER BY g.nome DESC;

--------------------------------------------------------------------------------------

