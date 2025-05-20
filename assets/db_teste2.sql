BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS "cadastro" (
	"id"	INTEGER,
	"texto"	TEXT NOT NULL,
	"numero"	INTEGER NOT NULL CHECK("numero" > 0) UNIQUE,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "log_operacoes" (
	"id"	INTEGER,
	"data_hora"	TEXT NOT NULL DEFAULT (datetime('now')),
	"tipo_operacao"	TEXT NOT NULL CHECK("tipo_operacao" IN ('Insert', 'Update', 'Delete')),
	"numero"	INTEGER NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TRIGGER log_delete
AFTER DELETE ON cadastro
BEGIN
    INSERT INTO log_operacoes (tipo_operacao, numero) 
    VALUES ('Delete', OLD.numero);
END;
CREATE TRIGGER log_insert
AFTER INSERT ON cadastro
BEGIN
    INSERT INTO log_operacoes (tipo_operacao, numero) 
    VALUES ('Insert', NEW.numero);
END;
CREATE TRIGGER log_update
AFTER UPDATE ON cadastro
BEGIN
    INSERT INTO log_operacoes (tipo_operacao, numero) 
    VALUES ('Update', NEW.numero);
END;
COMMIT;
