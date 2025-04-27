--1)
ALTER TABLE tb_empregado
ADD premiacao VARCHAR2(50);


--2)
SET serveroutput ON
ACCEPT p_id_emp PROMPT 'Por favor, informe o id do emp'
DECLARE
    v_id_emp        tb_empregado.id_empregado%TYPE := &p_id_emp;
    v_asterisco     tb_empregado.premiacao%TYPE := NULL;
    v_salario       tb_empregado.salario%TYPE;
BEGIN
    SELECT NVL(ROUND(salario/1000),0)
    INTO v_salario
    FROM tb_empregado
    WHERE id_empregado = v_id_emp;

    FOR i IN 1..v_salario LOOP
        v_asterisco := v_asterisco || '*';
    END LOOP;
    
    UPDATE tb_empregado
    SET premiacao = v_asterisco
    WHERE id_empregado = v_id_emp;
    
    COMMIT;
END;


--3)
SET serveroutput ON
ACCEPT p_id_depto PROMPT 'Informe o id do departamento: '
DECLARE
    reg_depto tb_departamento%ROWTYPE;
BEGIN
    SELECT *
    INTO reg_depto
    FROM tb_departamento
    WHERE id_departamento = &p_id_depto;
    
    dbms_output.put_line('Nome do Departamento: '|| reg_depto.nm_departamento||' ,id: '|| reg_depto.id_departamento ||' ,id da localizacao: '||reg_depto.id_localizacao||' ,id do gerente: '|| reg_depto.id_gerente);
EXCEPTION
    WHEN no_data_found THEN
        dbms_output.put_line('Nenhum departamento encontrado com esse ID: ');
END;


--4)
SET serveroutput ON
ACCEPT p_nm_regiao PROMPT 'Informe o nome da região: '
DECLARE
    v_nm_regiao     tb_regiao.nm_regiao%TYPE := '&p_nm_regiao';
    v_id_regiao     tb_pais.id_regiao%TYPE;
    v_qnt_paises    NUMBER;
BEGIN
    SELECT id_regiao 
    INTO v_id_regiao
    FROM tb_regiao
    WHERE UPPER(nm_regiao) = UPPER(v_nm_regiao);
    
    SELECT COUNT(*) 
    INTO v_qnt_paises
    FROM tb_pais
    WHERE id_regiao = v_id_regiao;
    
    DBMS_OUTPUT.PUT_LINE('Quantidade de paises na região '|| v_nm_regiao || ': '|| v_qnt_paises);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('A região informada não foi encontrada!!');
END;


--OU SE FOR REALMENTE PARA CONTAR AS REGIÕES:

SET serveroutput ON
ACCEPT p_nm_regiao PROMPT 'Informe o nome da região: '
DECLARE
    v_nm_regiao tb_regiao.nm_regiao%TYPE := '&p_nm_regiao';
    v_count     NUMBER;
BEGIN
    SELECT COUNT(DISTINCT(id_regiao))
    INTO v_count
    FROM tb_pais;
    
    DBMS_OUTPUT.PUT_LINE('Quantidade de regiões na tabela pais: '|| v_count || '. Voce informou a regiao '|| v_nm_regiao);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('A região informada não foi encontrada!!');
END;


--5)
SET serveroutput ON
DECLARE
    CURSOR c_emp IS
        SELECT *
        FROM tb_empregado
        WHERE id_funcao = 'ST_MAN';
    v_emp tb_empregado%ROWTYPE;
BEGIN
    OPEN c_emp;
    
    LOOP
        FETCH c_emp INTO v_emp;
        EXIT WHEN c_emp%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('NOME: '|| v_emp.nome|| ' |Email: '|| v_emp.email);
    END LOOP;
    CLOSE c_emp;
END;