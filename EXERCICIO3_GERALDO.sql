--exercicio 1

SELECT *
FROM tb_departamento;

SELECT *
FROM tb_localizacao;

SET serveroutput ON
DECLARE
    v_ap NUMBER;
    v_loc NUMBER;
    v_nm_departamento tb_departamento.nm_departamento%TYPE;
    v_id_departamento tb_departamento.id_departamento%TYPE;
    v_id_localizacao  tb_departamento.id_localizacao%TYPE;
BEGIN
    v_ap := &v_ap;
    v_loc := &v_loc;

    UPDATE tb_departamento
    SET id_localizacao = v_loc
    WHERE id_departamento = v_ap;
    
    SELECT nm_departamento, id_departamento, id_localizacao
    INTO v_nm_departamento,v_id_departamento, v_id_localizacao
    FROM tb_departamento
    WHERE id_departamento = 20;
    
    dbms_output.put_line('Nome do departamento: '||v_nm_departamento||', numero do departamento: '||v_id_departamento||', localizaçao: '||v_id_localizacao);
END;




--exercicio 2
SELECT *
FROM tb_empregado;

SET serveroutput ON
DECLARE
    v_id_departamento NUMBER; 
    v_linhas_afetadas NUMBER;
    v_existente NUMBER;
BEGIN
    v_id_departamento := &v_id_departamento;

    SELECT COUNT(*)
    INTO v_existente
    FROM tb_departamento
    WHERE id_departamento = v_id_departamento;

    IF v_existente = 0 THEN
        DBMS_OUTPUT.PUT_LINE('O departamento informado (' || v_id_departamento || ') não existe.');
    ELSE
        UPDATE tb_empregado
        SET id_departamento = NULL
        WHERE id_departamento = v_id_departamento;

        DBMS_OUTPUT.PUT_LINE('Empregados desvinculados do departamento: ' || SQL%ROWCOUNT);

        DELETE FROM tb_departamento
        WHERE id_departamento = v_id_departamento;

        v_linhas_afetadas := SQL%ROWCOUNT;
        DBMS_OUTPUT.PUT_LINE('Número de linhas afetadas na exclusão: ' || v_linhas_afetadas);
        
        IF v_linhas_afetadas > 0 THEN
            DBMS_OUTPUT.PUT_LINE('O departamento ' || v_id_departamento || ' foi removido com sucesso!');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Falha ao remover o departamento ' || v_id_departamento || '.');
        END IF;
    END IF;
END;
--não consegui remover o registrio filho...




--exercicio 3

CREATE TABLE tb_mensagens(
resultado   VARCHAR2(60)
);

SET serveroutput ON
DECLARE
    v_num   NUMBER(2) := 1;
BEGIN
    FOR i IN 1..10 LOOP
        IF v_num != 6 and v_num !=8 THEN
            INSERT INTO tb_mensagens(resultado) 
            VALUES (v_num);
        END IF;
        v_num := v_num +1;
    END LOOP;
    
    COMMIT;
END;
    
SELECT resultado
FROM tb_mensagens;




--exercicio 4
SELECT *
FROM tb_empregado;

SET serveroutput ON
DECLARE
    v_emp NUMBER;
    v_salario NUMBER;
    v_comissao NUMBER;
BEGIN
    v_emp := &v_emp;
    
    SELECT salario
    INTO v_salario
    FROM tb_empregado
    WHERE id_empregado = v_emp;
    
    IF v_salario < 1000 THEN
        UPDATE tb_empregado
        SET percentual_comissao = 0.10
        WHERE id_empregado = v_emp;
    ELSIF v_salario BETWEEN 1000 AND 1500 THEN
        UPDATE tb_empregado
        SET percentual_comissao = 0.15
        WHERE id_empregado = v_emp;
    ELSIF v_salario > 1500 THEN
        UPDATE tb_empregado
        SET percentual_comissao = 0.20
        WHERE id_empregado = v_emp;
    ELSE
        UPDATE tb_empregado
        SET percentual_comissao = 0.00
        WHERE id_empregado = v_emp;
    END IF;
    COMMIT;
END;

DESCRIBE tb_empregado;




--exercicio 5

SET SERVEROUTPUT ON
DECLARE
    -- Declaração de um registro de acordo com a estrutura da TB_DEPARTAMENTO
    TYPE departamento_rec IS RECORD (
        id_departamento tb_departamento.id_departamento%TYPE,
        nm_departamento tb_departamento.nm_departamento%TYPE,
        id_gerente tb_departamento.id_gerente%TYPE,
        id_localizacao tb_departamento.id_localizacao%TYPE
    );
    v_departamento departamento_rec; -- Registro que será utilizado no bloco
    v_id_departamento NUMBER;        -- Variável de substituição
BEGIN
    -- Solicitar ao usuário o ID do departamento
    v_id_departamento := &id_departamento;

    -- Buscar os dados do departamento específico e armazenar no registro
    SELECT id_departamento, nm_departamento, id_gerente, id_localizacao
    INTO v_departamento
    FROM tb_departamento
    WHERE id_departamento = v_id_departamento;

    -- Exibir informações selecionadas sobre o departamento
    DBMS_OUTPUT.PUT_LINE('ID do Departamento: ' || v_departamento.id_departamento);
    DBMS_OUTPUT.PUT_LINE('Nome do Departamento: ' || v_departamento.nm_departamento);
    DBMS_OUTPUT.PUT_LINE('ID do Gerente: ' || v_departamento.id_gerente);
    DBMS_OUTPUT.PUT_LINE('ID da Localização: ' || v_departamento.id_localizacao);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Nenhum departamento encontrado com o ID informado: ' || v_id_departamento);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ocorreu um erro: ' || SQLERRM);
END;


SELECT *
FROM tb_departamento;