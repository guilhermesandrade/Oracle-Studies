--iniciando (Programação com Banco de Dados I: PLSQL)
SHOW USER;

CREATE USER plsql IDENTIFIED BY treina_plsql; --(user: plsql / senha: treina_plsql)

--atribuindo permissões ao usuario plsql, ele deve se conectar no BD, criar objetos como tabelas (permissao resource)

ALTER USER plsql QUOTA 100M ON USERS;

GRANT connect, resource TO plsql;

