-- criar_usuario.sql
CREATE OR REPLACE FUNCTION criar_usuario(p_nome TEXT, p_email TEXT, p_senha TEXT)
RETURNS TEXT AS $$
DECLARE
    usuario_existente RECORD;
BEGIN
    -- RN5 - O nome do Usuário deve ser obrigatório.
    IF p_nome IS NULL OR p_nome = '' THEN
        RETURN 'O campo nome não pode ser nulo';
    END IF;

    -- RN3 - O identificador do Usuário deve ser obrigatório.
    IF p_email IS NULL OR p_email = '' THEN
        RETURN 'O campo email não pode ser nulo';
    END IF;

    -- RN6 - A senha do Usuário deve ser obrigatória.
    IF p_senha IS NULL OR p_senha = '' THEN
        RETURN 'O campo senha não pode ser nulo';
    END IF;

    -- RN2 - O identificador do Usuário deve ser único.
    SELECT * INTO usuario_existente FROM "Usuario" WHERE "Usuario".email = p_email;
    IF usuario_existente IS NOT NULL THEN
        RETURN 'Email já registrado';
    END IF;

    -- Criar usuário
    INSERT INTO "Usuario" (nome, email, senha) VALUES (p_nome, p_email, p_senha);
    RETURN 'Usuário criado com sucesso';
END;
$$ LANGUAGE plpgsql;

-- login_usuario.sql
CREATE OR REPLACE FUNCTION login_usuario(p_email TEXT, p_senha TEXT)
RETURNS TABLE(id INT, admin BOOLEAN) AS $$
DECLARE
    usuario RECORD;
BEGIN
    -- RN3 - O identificador do Usuário deve ser obrigatório.
    IF p_email IS NULL OR p_email = '' THEN
        RAISE EXCEPTION 'O campo email não pode ser nulo';
    END IF;

    -- RN6 - A senha do Usuário deve ser obrigatória.
    IF p_senha IS NULL OR p_senha = '' THEN
        RAISE EXCEPTION 'O campo senha não pode ser nulo';
    END IF;


    SELECT "Usuario".id, "Usuario".admin, "Usuario".senha INTO usuario FROM "Usuario" WHERE "Usuario".email = p_email;

    -- Verificar se o usuário existe
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Email não registrado';
    END IF;

    -- Verificar se a senha está correta
    IF usuario.senha <> p_senha THEN
        RAISE EXCEPTION 'Senha incorreta';
    END IF;

    RETURN QUERY SELECT usuario.id, usuario.admin;
END;
$$ LANGUAGE plpgsql;

-- listar_usuarios_com_reservas.sql
CREATE OR REPLACE FUNCTION listar_usuarios_com_reservas()
RETURNS TABLE(id INT, nome TEXT, email TEXT, reservas JSON) AS $$
BEGIN
    RETURN QUERY 
    SELECT u.id, u.nome, u.email, 
           (SELECT json_agg(r) FROM "Reserva" r WHERE r.usuarioId = u.id) AS reservas
    FROM "Usuario" u;
END;
$$ LANGUAGE plpgsql;