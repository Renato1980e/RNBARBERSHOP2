# RN Barber Shop — sistema de agendamento e gestão

Aplicação React + Vite com painel privado, agenda, clientes, serviços, financeiro básico e relatórios. Para dados reais sincronizados entre dispositivos, use Supabase.

## 1. Rodar no computador
1. Instale Node.js LTS: https://nodejs.org/
2. Extraia a pasta.
3. Abra o terminal dentro da pasta do projeto.
4. Rode `npm install`.
5. Copie `.env.example` para `.env`.
6. Rode `npm run dev` e abra o endereço mostrado no terminal.

## 2. Configurar o banco Supabase
1. Crie um projeto em https://supabase.com/.
2. No painel do Supabase, abra SQL Editor.
3. Copie e execute todo o conteúdo de `supabase/schema.sql`.
4. Em Project Settings → API, copie Project URL e a chave pública anon/publishable.
5. Preencha `.env`:
   `VITE_SUPABASE_URL=https://seu-projeto.supabase.co`
   `VITE_SUPABASE_ANON_KEY=sua-chave-publica`
6. Reinicie `npm run dev`.

**Nunca coloque a `service_role` key no site ou no GitHub.** O arquivo `.env` já está ignorado pelo Git.

## 3. Colocar no GitHub
O GitHub guarda o código, mas não roda sozinho um banco de dados. Para esse app, publique o frontend em Vercel ou Netlify e mantenha o Supabase como banco/autenticação. Se quiser GitHub Pages, será necessário ajustar a configuração de rotas e build; Vercel é o caminho mais simples para Vite.

## Funcionalidades incluídas
- Conta com e-mail e senha (Supabase) e sessão persistente.
- Demonstração local sem Supabase, salva neste navegador.
- Painel com métricas, agenda de hoje e próximos atendimentos.
- Cadastro/edição de agendamentos, cliente, serviço, preço, duração, observações e status.
- Verificação de conflito de horário no app e restrição contra sobreposição no PostgreSQL.
- Cancelamento libera horário.
- Cadastro de clientes e serviços; preços/durações editáveis.
- Controle de pagamentos pendentes, marcar pagamento recebido, entradas e despesas manuais.
- Relatório básico e exportação CSV.
- Layout responsivo para computador e celular.

## Limites atuais importantes
- O formulário público de agendamento para visitantes ainda não está ligado ao banco. No momento, o painel privado é a parte principal do sistema.
- A lista de horários usa expediente padrão de 09:00 a 19:00, intervalos de 30 minutos. Ajuste em `src/main.jsx` se seu horário for diferente.
- O modo demonstração local é apenas para testar; não é multiusuário e não sincroniza entre dispositivos.
- O login usa e-mail e senha porque o Supabase Auth suporta recuperação e autenticação segura por e-mail. Nome completo é guardado no perfil da conta.
