# 🚀 DEPLOY AUTOMÁTICO - GUIA COMPLETO

## O que você vai ter:

```
GitHub (seu código guardado)
        ↓
Vercel (publica automaticamente)
        ↓
oscaribas.vercel.app (seu jogo online)
```

**Sempre atualizado. De qualquer lugar. Sem seu PC ligado.**

---

## 🎯 PASSO A PASSO (10 minutos)

### **PASSO 1: Prepara a pasta local**

Cria em `Desktop/oscaribas-game/`:
```
oscaribas-game/
├── index.html         ← O jogo
├── vercel.json        ← Config do Vercel
├── .gitignore         ← Arquivos a ignorar
├── package.json       ← Info do projeto
└── DEPLOY.md          ← Este arquivo
```

**Baixa todos os arquivos que eu entreguei.**

---

### **PASSO 2: Sincroniza com GitHub**

Abre Git Bash/Terminal na pasta e digita:

```bash
git init
git add .
git commit -m "Versão inicial do Oscaribas"
git remote add origin https://github.com/rmontagnoli-rgb/oscaribathegame.git
git branch -M main
git push -u origin main
```

**Se pedir senha:**
- Usa seu email do GitHub: `rmontagnoli.art@gmail.com`
- E um **token pessoal** (próximo passo)

### **Como gerar Token (se pedir senha):**

1. Acessa: https://github.com/settings/tokens
2. Clica **"Generate new token (classic)"**
3. Preenche:
   - **Note**: `Git CLI`
   - **Expiration**: `90 days`
   - **Scopes**: marca `repo`
4. Clica **"Generate"**
5. **Copia a senha gigante** que aparece
6. Volta pro Git Bash e cola quando pedir

**Pronto! Seu código está no GitHub.**

---

### **PASSO 3: Conecta ao Vercel**

Agora vem a magia. Você vai fazer deploy em 3 cliques.

1. Acessa: **https://vercel.com**
2. Clica **"Sign up"** (se não tiver conta)
3. Escolhe **"Continue with GitHub"**
4. Autoriza o Vercel acessar seu GitHub
5. **Procura por `oscaribathegame`** na lista
6. Clica nele e depois **"Import"**
7. Espera uns 30 segundos...
8. **Pronto! Você tem um link tipo:** `https://oscaribathegame.vercel.app`

---

### **PASSO 4: Acessa seu jogo**

```
https://oscaribathegame.vercel.app
```

**Tá pronto pra jogar!** 🎮

---

## 🔄 WORKFLOW DAQUI PRA FRENTE

**Você:** "Quero que o botão fique vermelho"

**Eu (aqui):**
- Edito `index.html`
- Faço `git add . → git commit → git push`

**Você:**
- Acessa `oscaribathegame.vercel.app`
- Faz F5 no navegador
- **Vê a mudança em tempo real!** ✅

---

## 🆘 ERROS COMUNS

### "Não consegue fazer push"

**Solução:**
- Usa um **token pessoal** (não senha)
- Gera em: https://github.com/settings/tokens
- Marca scope `repo`

### "Vercel não acha o repositório"

**Solução:**
- Verifica se o nome está certo: `rmontagnoli-rgb/oscaribathegame`
- Repositório está public? (não private)
- Esperou o GitHub sincronizar?

### "Link do Vercel não funciona"

**Solução:**
- Espera 1-2 minutos (primeira vez demora)
- Recarrega a página (Ctrl+F5)
- Verifica no dashboard do Vercel se diz "Ready"

---

## ✅ PRONTO!

Agora você tem:
- ✅ Código no GitHub
- ✅ Jogo publicado (oscaribathegame.vercel.app)
- ✅ Deploy automático (qualquer push = atualiza)
- ✅ Acesso de qualquer lugar

**Pode me chamar agora pra fazer mudanças no jogo!** 🚀

---

## 📝 RESUMO DO WORKFLOW:

```
Você aqui escreve: "Mudança X"
        ↓
Eu edito index.html
        ↓
Eu faço: git add . → git commit -m "Mudança X" → git push
        ↓
Vercel publica automaticamente (em segundos)
        ↓
Você no navegador faz F5
        ↓
Vê a mudança! ✅
```

**Simples assim.** Sem complicação. 💪
