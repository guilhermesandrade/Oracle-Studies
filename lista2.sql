SET serveroutput ON
DECLARE
    v_contador  NUMBER;
BEGIN
    SELECT COUNT(1) INTO v_contador
    FROM tb_empregado
    WHERE id_departamento = 10;
    
    UPDATE tb_empregado
    SET salario = salario + salario *0.15
    WHERE id_departamento =10;
    
    DBMS_OUTPUT.PUT_LINE(v_contador ||' Funcionarios agraciados!');
END;

SELECT nome, salario
FROM tb_empregado
WHERE id_departamento = 10;


DESCRIBE tb_empregado;
DESCRIBE tb_funcao;

SELECT *
FROM tb_funcao;


SET serveroutput ON
DECLARE
    v_velha_funcao    tb_funcao.id_funcao%TYPE := '&v_velha_funcao';
    v_nova_funcao    tb_funcao.id_funcao%TYPE := '&v_nova_funcao';
    v_contador NUMBER;
BEGIN
    UPDATE tb_empregado
    SET id_funcao = v_nova_funcao
    WHERE id_funcao = v_velha_funcao;
    
    IF SQL%ROWCOUNT >0 THEN
        dbms_output.put_line(SQL%ROWCOUNT || ' funcionarios tiveram suas funções atualizadas');
    ELSE
        dbms_output.put_line('Nenhum funcionario teve suas funções atualizadas');
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line(SQLERRM);
END;



ROLLBACK;

SELECT nome, id_funcao
FROM tb_empregado;


DECLARE
    l_name  emp.ename%TYPE;
    l_empno emp.empno%TYPE := &1;
BEGIN
    SELECT ename
    INTO l_name
    FROM emp
    WHERE empno = l_empno;
    
    DBMS_OUTPUT.PUT_LINE('employee name = '|| l_name);
EXCEPTION
    WHEN no_data_found THEN
        DBMS_OUTPUT.PUT_LINE('FUNCIONARIO DESCONHECIDO');
END;


SET serveroutput ON
DECLARE
    v_n1 NUMBER := &v_n1;
    v_n2 NUMBER := &v_n2;
    
    e_maior EXCEPTION;
BEGIN
    IF v_n1 > v_n2 THEN
        RAISE e_maior;
    ELSE
        dbms_output.put_line('O segundo numero informado é maior!');
    END IF;
EXCEPTION
    WHEN e_maior THEN
        dbms_output.put_line('O primeiro numero é o MAIOR !!!');
END;



DECLARE
    CURSOR employee_cur(p_deptno emp.deptno)
    IS
            SELECT ename
            ,   job
            FROM emp
            WHERE deptno = l_deptno;
BEGIN
    OPEN employee_cur(10);
    
    LOOP
        FETCH r_employee INTO employee_cur;
        EXIT employee_cur.NOTFOUND;
    END LOOP;
    CLOSE;
END;