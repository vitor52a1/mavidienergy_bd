SET SERVEROUTPUT ON -- Habilita a saída de dados do DBMS
SET VERIFY OFF -- Desabilita a repetição de código ao usar entrada de dados manual

-- Dropar as tabelas existentes
DROP TABLE Endereco_Fornecedor CASCADE CONSTRAINTS;
DROP TABLE Consulta CASCADE CONSTRAINTS;
DROP TABLE Fornecedor CASCADE CONSTRAINTS;
DROP TABLE Cidade_Curiosidade CASCADE CONSTRAINTS;
DROP TABLE Curiosidade CASCADE CONSTRAINTS;
DROP TABLE Cidade CASCADE CONSTRAINTS;
DROP TABLE Endereco CASCADE CONSTRAINTS;
DROP TABLE Usuario CASCADE CONSTRAINTS;
DROP TABLE Pessoa CASCADE CONSTRAINTS;

-- Tabela: Pessoa
CREATE TABLE Pessoa (
pessoa_id NUMBER PRIMARY KEY,
nome VARCHAR2(100) NOT NULL,
idade NUMBER
);

-- Tabela: Usuario
CREATE TABLE Usuario (
usuario_id NUMBER PRIMARY KEY,
pessoa_id NUMBER UNIQUE,
endereco_id NUMBER
);

-- Tabela: Endereco
CREATE TABLE Endereco (
endereco_id NUMBER PRIMARY KEY,
cidade_id NUMBER,
logradouro VARCHAR2(200),
numero VARCHAR2(10),
cep VARCHAR2(15)
);

-- Tabela: Cidade
CREATE TABLE Cidade (
cidade_id NUMBER PRIMARY KEY,
nome VARCHAR2(100),
estado VARCHAR2(50)
);

-- Tabela: Curiosidade
CREATE TABLE Curiosidade (
curiosidade_id NUMBER PRIMARY KEY,
descricao VARCHAR2(500)
);

-- Tabela de associação entre Cidade e Curiosidade
CREATE TABLE Cidade_Curiosidade (
cidade_id NUMBER,
curiosidade_id NUMBER
);

-- Tabela: Fornecedor
CREATE TABLE Fornecedor (
fornecedor_id NUMBER PRIMARY KEY,
nome VARCHAR2(100),
cidade_id NUMBER
);

-- Tabela: Consulta (com valor da conta e data da consulta)
CREATE TABLE Consulta (
consulta_id NUMBER PRIMARY KEY,
usuario_id NUMBER,
valor_conta NUMBER(10, 2), -- Valor da conta de energia
data_consulta DATE DEFAULT SYSDATE, -- Data da consulta
descricao VARCHAR2(500)
);

-- Tabela de associação entre Endereco e Fornecedor
CREATE TABLE Endereco_Fornecedor (
endereco_id NUMBER,
fornecedor_id NUMBER
);

-- Adicionando as Foreign Keys
ALTER TABLE Usuario
ADD CONSTRAINT fk_usuario_pessoa
FOREIGN KEY (pessoa_id) REFERENCES Pessoa(pessoa_id);

ALTER TABLE Usuario
ADD CONSTRAINT fk_usuario_endereco
FOREIGN KEY (endereco_id) REFERENCES Endereco(endereco_id);

ALTER TABLE Endereco
ADD CONSTRAINT fk_endereco_cidade
FOREIGN KEY (cidade_id) REFERENCES Cidade(cidade_id);

ALTER TABLE Cidade_Curiosidade
ADD CONSTRAINT fk_cidade_curiosidade_cidade
FOREIGN KEY (cidade_id) REFERENCES Cidade(cidade_id);

ALTER TABLE Cidade_Curiosidade
ADD CONSTRAINT fk_cidade_curiosidade_curiosidade
FOREIGN KEY (curiosidade_id) REFERENCES Curiosidade(curiosidade_id);

ALTER TABLE Fornecedor
ADD CONSTRAINT fk_fornecedor_cidade
FOREIGN KEY (cidade_id) REFERENCES Cidade(cidade_id);

ALTER TABLE Consulta
ADD CONSTRAINT fk_consulta_usuario
FOREIGN KEY (usuario_id) REFERENCES Usuario(usuario_id);

ALTER TABLE Endereco_Fornecedor
ADD CONSTRAINT fk_endereco_fornecedor_endereco
FOREIGN KEY (endereco_id) REFERENCES Endereco(endereco_id);

ALTER TABLE Endereco_Fornecedor
ADD CONSTRAINT fk_endereco_fornecedor_fornecedor
FOREIGN KEY (fornecedor_id) REFERENCES Fornecedor(fornecedor_id);


-- Funções para validação e cálculo
-- Função para validar CEP
CREATE OR REPLACE FUNCTION valida_cep(cep IN VARCHAR2) RETURN BOOLEAN IS
BEGIN
IF REGEXP_LIKE(cep, '^\d{5}-\d{3}$') THEN
RETURN TRUE;

ELSE
RETURN FALSE;

END IF;

EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('Erro ao validar o CEP.');
RETURN FALSE;
END;

-- Função para validar e-mail
CREATE OR REPLACE FUNCTION valida_email(email IN VARCHAR2) RETURN BOOLEAN IS
BEGIN
IF REGEXP_LIKE(email, '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$') THEN
RETURN TRUE;
ELSE
RETURN FALSE;
END IF;
EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('Erro ao validar o e-mail.');
RETURN FALSE;
END;

-- Função para calcular o total de valores das contas de energia do usuário
CREATE OR REPLACE FUNCTION calcula_total_consultas(usuario_id IN NUMBER) RETURN NUMBER IS
total NUMBER(10,2);
BEGIN
SELECT SUM(valor_conta)
INTO total
FROM Consulta
WHERE usuario_id = usuario_id;
RETURN total;
EXCEPTION
WHEN NO_DATA_FOUND THEN
RETURN 0;
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('Erro ao calcular o total das consultas.');
RETURN NULL;
END;

-- Procedures para inserção de dados
-- Inserir pessoa
CREATE OR REPLACE PROCEDURE inserir_pessoa(pessoa_id IN NUMBER, nome IN VARCHAR2, idade IN NUMBER) IS
BEGIN
INSERT INTO Pessoa (pessoa_id, nome, idade)
VALUES (pessoa_id, nome, idade);
END;

-- Inserir usuário
CREATE OR REPLACE PROCEDURE inserir_usuario(usuario_id IN NUMBER, pessoa_id IN NUMBER, endereco_id IN NUMBER) IS
BEGIN
INSERT INTO Usuario (usuario_id, pessoa_id, endereco_id)
VALUES (usuario_id, pessoa_id, endereco_id);
END;

-- Inserir endereço
CREATE OR REPLACE PROCEDURE inserir_endereco(endereco_id IN NUMBER, cidade_id IN NUMBER, logradouro IN VARCHAR2, numero IN VARCHAR2, cep IN VARCHAR2) IS
BEGIN
IF NOT valida_cep(cep) THEN
RAISE_APPLICATION_ERROR(-20001, 'Formato de CEP inválido');
END IF;
INSERT INTO Endereco (endereco_id, cidade_id, logradouro, numero, cep)
VALUES (endereco_id, cidade_id, logradouro, numero, cep);
END;

-- Inserir cidade
CREATE OR REPLACE PROCEDURE inserir_cidade(cidade_id IN NUMBER, nome IN VARCHAR2, estado IN VARCHAR2) IS
BEGIN
INSERT INTO Cidade (cidade_id, nome, estado)
VALUES (cidade_id, nome, estado);
END;

-- Inserir curiosidade
CREATE OR REPLACE PROCEDURE inserir_curiosidade(curiosidade_id IN NUMBER, descricao IN VARCHAR2) IS
BEGIN
INSERT INTO Curiosidade (curiosidade_id, descricao)
VALUES (curiosidade_id, descricao);
END;

-- Inserir fornecedor
CREATE OR REPLACE PROCEDURE inserir_fornecedor(fornecedor_id IN NUMBER, nome IN VARCHAR2, cidade_id IN NUMBER) IS
BEGIN
INSERT INTO Fornecedor (fornecedor_id, nome, cidade_id)
VALUES (fornecedor_id, nome, cidade_id);
END;

-- Inserir consulta
CREATE OR REPLACE PROCEDURE inserir_consulta(consulta_id IN NUMBER, usuario_id IN NUMBER, valor_conta IN NUMBER, descricao IN VARCHAR2) IS
BEGIN
INSERT INTO Consulta (consulta_id, usuario_id, valor_conta, descricao)
VALUES (consulta_id, usuario_id, valor_conta, descricao);
END;

-- Inserir associação endereço-fornecedor
CREATE OR REPLACE PROCEDURE inserir_endereco_fornecedor(endereco_id IN NUMBER, fornecedor_id IN NUMBER) IS
BEGIN
INSERT INTO Endereco_Fornecedor (endereco_id, fornecedor_id)
VALUES (endereco_id, fornecedor_id);
END;

-- Inserir cidade-curiosidade
CREATE OR REPLACE PROCEDURE inserir_cidade_curiosidade(cidade_id IN NUMBER, curiosidade_id IN NUMBER) IS
BEGIN
INSERT INTO Cidade_Curiosidade (cidade_id, curiosidade_id)
VALUES (cidade_id, curiosidade_id);
END;

-- Inserções de registros
BEGIN
-- Inserir registros na tabela Cidade
inserir_cidade(1, 'São Paulo', 'SP');
inserir_cidade(2, 'Rio de Janeiro', 'RJ');
inserir_cidade(3, 'Belo Horizonte', 'MG');
inserir_cidade(4, 'Curitiba', 'PR');
inserir_cidade(5, 'Porto Alegre', 'RS');
inserir_cidade(6, 'Brasília', 'DF');
inserir_cidade(7, 'Manaus', 'AM');
inserir_cidade(8, 'Fortaleza', 'CE');
inserir_cidade(9, 'Salvador', 'BA');
inserir_cidade(10, 'Recife', 'PE');

-- Inserir registros na tabela Endereco
inserir_endereco(1, 1, 'Rua A', '123', '12345-678');
inserir_endereco(2, 2, 'Rua B', '456', '23456-789');
inserir_endereco(3, 3, 'Rua C', '789', '34567-890');
inserir_endereco(4, 4, 'Rua D', '101', '45678-901');
inserir_endereco(5, 5, 'Rua E', '112', '56789-012');
inserir_endereco(6, 6, 'Rua F', '131', '67890-123');
inserir_endereco(7, 7, 'Rua G', '415', '78901-234');
inserir_endereco(8, 8, 'Rua H', '161', '89012-345');
inserir_endereco(9, 9, 'Rua I', '718', '90123-456');
inserir_endereco(10, 10, 'Rua J', '920', '01234-567');

-- Inserir registros na tabela Pessoa
inserir_pessoa(1, 'Alice', 25);
inserir_pessoa(2, 'Bob', 30);
inserir_pessoa(3, 'Carol', 35);
inserir_pessoa(4, 'Dave', 40);
inserir_pessoa(5, 'Eve', 45);
inserir_pessoa(6, 'Frank', 50);
inserir_pessoa(7, 'Grace', 55);
inserir_pessoa(8, 'Heidi', 60);
inserir_pessoa(9, 'Ivan', 65);
inserir_pessoa(10, 'Judy', 70);

-- Inserir registros na tabela Usuario
inserir_usuario(1, 1, 1);
inserir_usuario(2, 2, 2);
inserir_usuario(3, 3, 3);
inserir_usuario(4, 4, 4);
inserir_usuario(5, 5, 5);
inserir_usuario(6, 6, 6);
inserir_usuario(7, 7, 7);
inserir_usuario(8, 8, 8);
inserir_usuario(9, 9, 9);
inserir_usuario(10, 10, 10);

-- Inserir registros na tabela Fornecedor
inserir_fornecedor(1, 'Fornecedor A', 1);
inserir_fornecedor(2, 'Fornecedor B', 2);
inserir_fornecedor(3, 'Fornecedor C', 3);
inserir_fornecedor(4, 'Fornecedor D', 4);
inserir_fornecedor(5, 'Fornecedor E', 5);
inserir_fornecedor(6, 'Fornecedor F', 6);
inserir_fornecedor(7, 'Fornecedor G', 7);
inserir_fornecedor(8, 'Fornecedor H', 8);
inserir_fornecedor(9, 'Fornecedor I', 9);
inserir_fornecedor(10, 'Fornecedor J', 10);

-- Inserir registros na tabela Consulta
inserir_consulta(1, 1, 200.50, 'Consulta mensal de energia');
inserir_consulta(2, 2, 150.75, 'Consulta mensal de energia');
inserir_consulta(3, 3, 300.00, 'Consulta mensal de energia');
inserir_consulta(4, 4, 400.20, 'Consulta mensal de energia');
inserir_consulta(5, 5, 250.80, 'Consulta mensal de energia');
inserir_consulta(6, 6, 100.90, 'Consulta mensal de energia');
inserir_consulta(7, 7, 180.45, 'Consulta mensal de energia');
inserir_consulta(8, 8, 210.60, 'Consulta mensal de energia');
inserir_consulta(9, 9, 220.70, 'Consulta mensal de energia');
inserir_consulta(10, 10, 300.10, 'Consulta mensal de energia');

-- Inserir registros na tabela Endereco_Fornecedor
inserir_endereco_fornecedor(1, 1);
inserir_endereco_fornecedor(2, 2);
inserir_endereco_fornecedor(3, 3);
inserir_endereco_fornecedor(4, 4);
inserir_endereco_fornecedor(5, 5);
inserir_endereco_fornecedor(6, 6);
inserir_endereco_fornecedor(7, 7);
inserir_endereco_fornecedor(8, 8);
inserir_endereco_fornecedor(9, 9);
inserir_endereco_fornecedor(10, 10);

-- Inserir registros na tabela Curiosidade
inserir_curiosidade(1, 'São Paulo é a cidade mais populosa do Brasil.');
inserir_curiosidade(2, 'Rio de Janeiro é conhecido por suas praias.');
inserir_curiosidade(3, 'Brasília é a capital do Brasil.');
inserir_curiosidade(4, 'Curitiba é conhecida pela sustentabilidade.');
inserir_curiosidade(5, 'Salvador tem o maior Carnaval do mundo.');
inserir_curiosidade(6, 'Manaus é a porta de entrada para a Amazônia.');
inserir_curiosidade(7, 'Recife é conhecida como a “Veneza Brasileira”.');
inserir_curiosidade(8, 'Porto Alegre tem clima temperado.');
inserir_curiosidade(9, 'Fortaleza possui belas praias.');
inserir_curiosidade(10, 'Belo Horizonte é famosa pela gastronomia.');

-- Inserir registros na tabela Cidade_Curiosidade
inserir_cidade_curiosidade(1, 1);
inserir_cidade_curiosidade(2, 2);
inserir_cidade_curiosidade(3, 3);
inserir_cidade_curiosidade(4, 4);
inserir_cidade_curiosidade(5, 5);
inserir_cidade_curiosidade(6, 6);
inserir_cidade_curiosidade(7, 7);
inserir_cidade_curiosidade(8, 8);
inserir_cidade_curiosidade(9, 9);
inserir_cidade_curiosidade(10, 10);

END;

/
SELECT * FROM Pessoa;
SELECT * FROM Usuario;
SELECT * FROM Endereco;
SELECT * FROM Cidade;
SELECT * FROM Curiosidade;
SELECT * FROM Cidade_Curiosidade;
SELECT * FROM Fornecedor;
SELECT * FROM Consulta;
SELECT * FROM Endereco_Forne