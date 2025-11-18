-- #############################################
-- # MODELO DE DADOS E AUTOMAÇÃO PL/SQL
-- # PROJETO: SKILLBOOST (GLOBAL SOLUTION)
-- #############################################

-- 1. DDL

-- Tabela para os usuários da aplicação
CREATE TABLE GS_USUARIO (
    id_usuario NUMBER PRIMARY KEY,
    nome VARCHAR2(100),
    cargo VARCHAR2(50),
    email VARCHAR2(100) UNIQUE
);

-- Tabela para o conteúdo de micro-learning (Upskilling)
CREATE TABLE GS_CONTEUDO (
    id_conteudo NUMBER PRIMARY KEY,
    titulo VARCHAR2(100),
    categoria VARCHAR2(50),
    duracao_min NUMBER
);

-- Tabela para registrar o humor e produtividade do usuário (Wellbeing)
CREATE TABLE GS_REGISTRO_BEM_ESTAR (
    id_registro NUMBER PRIMARY KEY,
    id_usuario NUMBER,
    nivel_stress NUMBER(2),
    data_registro DATE DEFAULT SYSDATE,
    FOREIGN KEY (id_usuario) REFERENCES GS_USUARIO(id_usuario)
);

-- Tabela de log para receber os alertas disparados pela Trigger (RH)
CREATE TABLE GS_ALERTAS_RH (
    id_alerta NUMBER PRIMARY KEY,
    id_usuario_afetado NUMBER,
    mensagem VARCHAR2(200),
    data_alerta DATE DEFAULT SYSDATE
);

-- Sequência para IDs de Alerta
CREATE SEQUENCE seq_alertas START WITH 1 INCREMENT BY 1;


-- 2. PL/SQL (AUTOMAÇÃO)

-- PROCEDURE: Cálculo de Pontuação (Gamificação/Métrica de Aprendizado)
-- Calcula pontos baseado no conteúdo consumido
CREATE OR REPLACE PROCEDURE CALCULAR_PONTUACAO (
    p_id_usuario IN NUMBER,
    p_pontos_total OUT NUMBER
) IS
BEGIN
    -- Lógica: Cada minuto de aula consumido é convertido em 10 pontos.
    SELECT NVL(SUM(c.duracao_min * 10), 0)
    INTO p_pontos_total
    FROM GS_CONTEUDO c
    WHERE c.categoria = 'Soft Skills';
END;
/

-- TRIGGER: Monitoramento de Burnout (Controle de Saúde)
-- Acionada após um registro de humor, alerta se o nível de estresse for alto.
CREATE OR REPLACE TRIGGER TRG_ALERTA_BURNOUT
AFTER INSERT ON GS_REGISTRO_BEM_ESTAR
FOR EACH ROW
BEGIN
    -- Condição de Alerta: Se o stress reportado for maior que 8 (1 a 10)
    IF :NEW.nivel_stress > 8 THEN
        INSERT INTO GS_ALERTAS_RH (id_alerta, id_usuario_afetado, mensagem)
        VALUES (
            seq_alertas.NEXTVAL,
            :NEW.id_usuario,
            'ALERTA DE RISCO: Usuário ID ' || :NEW.id_usuario || ' reportou alto nível de estresse.'
        );
    END IF;
END;
/