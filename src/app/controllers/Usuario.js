import jwt from "jsonwebtoken";
import Autenticacao from "../../config/auth";
import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

const gerarToken = (userId, isAdmin) => {
  return jwt.sign({ userId, isAdmin }, Autenticacao.secret, {
    expiresIn: "1d",
  });
};

export default {
  async criarUsuario(request, response) {
    try {
      const { nome, email, senha } = request.body;
      const resultado = await prisma.$queryRaw`
      SELECT criar_usuario(${nome}, ${email}, ${senha}) AS mensagem
    `;
      if (resultado[0].mensagem) {
        return response.status(400).json({ error: resultado[0].mensagem });
      }
      return response.status(201).json({ message: resultado[0].mensagem });
    } catch (error) {
      console.error("Erro ao criar usuário", error);
      return response
        .status(500)
        .send({ error: "Não foi possível criar um usuário!" });
    }
  },
  async Login(request, response) {
    try {
      const { email, senha } = request.body;
      const usuario = await prisma.$queryRaw`
      SELECT * FROM login_usuario(${email},${senha})
    `;
      if (!usuario.length) {
        return response.status(400).json({ error: "Usuário não encontrado!" });
      }
      // Gerar token JWT
      const token = gerarToken(usuario[0].id, usuario[0].admin);
      response.status(200).json({ message: "Autenticado com sucesso", token });
    } catch (error) {
      console.error("Erro ao autenticar usuário", error);
      return response
        .status(500)
        .send({ error: "Não foi possível autenticar o usuário!" });
    }
  },
  async ListarUsuarios(request, response) {
    try {
      const usuariosComReservas = await prisma.$queryRaw`
      SELECT listar_usuarios_com_reservas()
    `;
      return response.status(200).json(usuariosComReservas);
    } catch (error) {
      console.error("Erro ao listar usuários", error);
      return response
        .status(500)
        .send({ error: "Não foi possível listar os usuários!" });
    }
  },
};
