-- Criar o Banco de Dados e Tabelas

-- Criar o banco de dados
CREATE DATABASE cafeteria_bomgosto;

-- Conectar ao banco criado
\c cafeteria_bomgosto;

-- Criar tabela cardapio
CREATE TABLE cardapio (
    codigo SERIAL PRIMARY KEY,
    nome VARCHAR(100) UNIQUE NOT NULL,
    descricao TEXT,
    preco_unitario DECIMAL(10,2) NOT NULL
);

-- Criar tabela comanda
CREATE TABLE comanda (
    codigo SERIAL PRIMARY KEY,
    data DATE NOT NULL,
    mesa INTEGER NOT NULL,
    nome_cliente VARCHAR(100) NOT NULL
);

-- Criar tabela item_comanda
CREATE TABLE item_comanda (
    codigo_comanda INTEGER REFERENCES comanda(codigo),
    codigo_cardapio INTEGER REFERENCES cardapio(codigo),
    quantidade INTEGER NOT NULL,
    PRIMARY KEY (codigo_comanda, codigo_cardapio)
);

-- Inserir Dados de Exemplo

-- Inserir dados no cardápio
INSERT INTO cardapio (nome, descricao, preco_unitario) VALUES
('Expresso', 'Café puro e intenso', 5.00),
('Cappuccino', 'Café com leite vaporizado e espuma', 8.50),
('Latte', 'Café com leite vaporizado e pouca espuma', 9.00),
('Mocha', 'Café com chocolate e leite vaporizado', 10.50),
('Macchiato', 'Expresso com uma dose de leite vaporizado', 7.00);

-- Inserir comandas
INSERT INTO comanda (data, mesa, nome_cliente) VALUES
('2024-01-15', 1, 'João Campos'),
('2024-01-15', 2, 'Maria Antônia'),
('2024-01-16', 3, 'Jean Vaz'),
('2024-01-16', 1, 'Anabela Castela');

-- Inserir itens das comandas
INSERT INTO item_comanda (codigo_comanda, codigo_cardapio, quantidade) VALUES
(1, 1, 2), -- Comanda 1: 2 Expressos
(1, 2, 1), -- Comanda 1: 1 Cappuccino
(2, 3, 1), -- Comanda 2: 1 Latte
(2, 4, 1), -- Comanda 2: 1 Mocha
(3, 1, 3), -- Comanda 3: 3 Expressos
(4, 2, 2), -- Comanda 4: 2 Cappuccinos
(4, 3, 1), -- Comanda 4: 1 Latte
(4, 5, 1); -- Comanda 4: 1 Macchiato

--1) Listagem do cardápio ordenada por nome

SELECT codigo, nome, descricao, preco_unitario
FROM cardapio
ORDER BY nome;

-- 2) Comandas com seus itens detalhados

SELECT 
    c.codigo AS codigo_comanda,
    c.data,
    c.mesa,
    c.nome_cliente,
    card.nome AS nome_cafe,
    card.descricao,
    ic.quantidade,
    card.preco_unitario,
    (ic.quantidade * card.preco_unitario) AS preco_total
FROM comanda c
INNER JOIN item_comanda ic ON c.codigo = ic.codigo_comanda
INNER JOIN cardapio card ON ic.codigo_cardapio = card.codigo
ORDER BY c.data, c.codigo, card.nome;

-- 3) Comandas com valor total

SELECT 
    c.codigo,
    c.data,
    c.mesa,
    c.nome_cliente,
    SUM(ic.quantidade * card.preco_unitario) AS valor_total
FROM comanda c
INNER JOIN item_comanda ic ON c.codigo = ic.codigo_comanda
INNER JOIN cardapio card ON ic.codigo_cardapio = card.codigo
GROUP BY c.codigo, c.data, c.mesa, c.nome_cliente
ORDER BY c.data;

-- 4) Comandas com mais de um tipo de café

SELECT 
    c.codigo,
    c.data,
    c.mesa,
    c.nome_cliente,
    COUNT(ic.codigo_cardapio) AS tipos_cafe,
    SUM(ic.quantidade * card.preco_unitario) AS valor_total
FROM comanda c
INNER JOIN item_comanda ic ON c.codigo = ic.codigo_comanda
INNER JOIN cardapio card ON ic.codigo_cardapio = card.codigo
GROUP BY c.codigo, c.data, c.mesa, c.nome_cliente
HAVING COUNT(ic.codigo_cardapio) > 1
ORDER BY c.data;

-- 5) Faturamento total por data

SELECT 
    c.data,
    SUM(ic.quantidade * card.preco_unitario) AS faturamento_total
FROM comanda c
INNER JOIN item_comanda ic ON c.codigo = ic.codigo_comanda
INNER JOIN cardapio card ON ic.codigo_cardapio = card.codigo
GROUP BY c.data
ORDER BY c.data;