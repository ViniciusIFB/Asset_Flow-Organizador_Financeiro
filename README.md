# Asset Flow - Organizador Financeiro

O Asset Flow é um organizador financeiro multiplataforma desenvolvido em Flutter e Dart. O objetivo central do projeto é fornecer ao usuário uma interface nítida e direta para o controle de gastos mensais e fluxo de caixa, preenchendo as lacunas de usabilidade e clareza deixadas pelos aplicativos de bancos tradicionais.

---

## O Problema
Os aplicativos bancários atuais são projetados com foco em transações, consumo de produtos internos e ofertas de crédito, resultando em extratos confusos e poluição visual. O usuário visualiza o saldo do momento, mas não encontra uma visão clara do impacto acumulado de suas despesas no orçamento do mês.
* Para o iniciante, a opacidade das interfaces gera confusão e dificulta a criação de um hábito de organização.
* Para o usuário avançado, faltam ferramentas analíticas integradas que permitam um controle granular e flexível.

## A Solução
O Asset Flow transfere o foco das transações bancárias puras para o gerenciamento e a clareza visual. A arquitetura foi planejada para atender diferentes níveis de maturidade financeira:
* Interface limpa: Utilização da tipografia Inter e uma paleta de cores minimalista, priorizando tons escuros com contrastes em verde e terracota.
* Navegação temporal: Controle de lançamentos com filtros dinâmicos por mês e ano.
* Acessibilidade: Uma experiência fluida que simplifica a visualização de dados brutos para o controle diário.

---

## Detalhes Técnicos e Engenharia de Código

O projeto foi construído com foco em segurança de tipos, imutabilidade e separação de responsabilidades.

### 1. Modelo de Dados Tipado (Transaction)
Toda movimentação financeira é estruturada para garantir a integridade dos dados em memória. O uso do modificador final assegura a imutabilidade do registro após a sua criação:

class Transaction {
  final String id;          // Identificador único da transação
  final String title;       // Descrição do lançamento
  final double amount;      // Valor monetário com precisão decimal
  final DateTime date;      // Objeto temporal nativo do Dart
  final String category;    // Categoria do fluxo
  final bool isIncome;      // Chave binária (True = Receita / False = Despesa)

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.isIncome,
  });
}

### 2. Processamento Dinâmico (Getters)
Para computar saldos e regras de negócio sem sobrecarregar a interface, a lógica utiliza Getters do Dart para processar os estados em tempo real:

double get totalBalance {
  double balance = 0.0;
  for (var t in filteredTransactions) {
    balance += t.isIncome ? t.amount : -t.amount;
  }
  return balance;
}

---

## Como Executar o Projeto Localmente

### Pré-requisitos
* Flutter SDK instalado e configurado.
* Modo de Desenvolvedor ativado no sistema operacional (necessário para o suporte a links simbólicos de componentes web no Windows).

### Passos para execução
1. Clone o repositório:
git clone https://github.com/ViniciusIFB/Asset_Flow-Organizador_Financeiro.git

2. Acesse a pasta do projeto:
cd Asset_Flow-Organizador_Financeiro

3. Instale as dependências:
flutter pub get

4. Execute a aplicação:
flutter run

---

## Deploy Web (GitHub Pages)

O projeto está configurado para distribuição na plataforma Web. Os arquivos de produção compilados pelo Flutter são hospedados na pasta /docs para servir o GitHub Pages.

Para atualizar a versão de produção:

1. Limpeza de caches locais:
flutter clean

2. Geração do build de produção com a rota base do repositório:
flutter build web --base-href "/Asset_Flow-Organizador_Financeiro/"

3. Atualização dos arquivos na branch principal:
git add .
git commit -m "deploy: build updated"
git push
