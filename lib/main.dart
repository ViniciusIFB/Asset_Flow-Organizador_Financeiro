import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  runApp(const AssetFlowApp());
}

class AssetFlowApp extends StatelessWidget {
  const AssetFlowApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Asset Flow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF4F4F6),
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}

// --- MODELO DE DADOS ---
class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final bool isIncome;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.isIncome,
  });
}

// --- TELA PRINCIPAL ---
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final Color darkHeader = const Color(0xFF372F38);
  final Color greenIncome = const Color(0xFF56682E);
  final Color redExpense = const Color(0xFFB55E45);
  
  String currentFilter = 'Todas';
  DateTime currentMonth = DateTime.now();

  late List<Transaction> transactions;

  @override
  void initState() {
    super.initState();
    transactions = [
      Transaction(id: '1', title: 'Pagamento Mensal', amount: 3500.00, date: currentMonth, category: 'Salário', isIncome: true),
      Transaction(id: '2', title: 'Aluguel Apartamento', amount: 2000.00, date: currentMonth, category: 'Fixo', isIncome: false),
      Transaction(id: '3', title: 'Supermercado', amount: 1250.00, date: currentMonth, category: 'Alimentação', isIncome: false),
      Transaction(id: '4', title: 'Renda Extra', amount: 2000.00, date: currentMonth, category: 'Extra', isIncome: true),
    ];
  }

  List<Transaction> get filteredTransactions {
    return transactions.where((t) {
      bool isSameMonth = t.date.month == currentMonth.month && t.date.year == currentMonth.year;
      if (!isSameMonth) return false;

      if (currentFilter == 'Receitas') return t.isIncome;
      if (currentFilter == 'Despesas') return !t.isIncome;
      return true;
    }).toList();
  }

  double get totalBalance {
    double balance = 0;
    for (var t in filteredTransactions) {
      balance += t.isIncome ? t.amount : -t.amount;
    }
    return balance;
  }

  Map<String, double> get expensesByCategory {
    Map<String, double> totals = {};
    final currentMonthExpenses = transactions.where((t) => 
      t.date.month == currentMonth.month && 
      t.date.year == currentMonth.year && 
      !t.isIncome
    );

    for (var t in currentMonthExpenses) {
      totals[t.category] = (totals[t.category] ?? 0) + t.amount;
    }
    return totals;
  }

  void _changeMonth(int offset) {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + offset, 1);
    });
  }

  void _addNewTransaction(String title, double amount, String category, bool isIncome) {
    final newTx = Transaction(
      id: DateTime.now().toString(),
      title: title,
      amount: amount,
      date: DateTime.now(),
      category: category,
      isIncome: isIncome,
    );

    setState(() {
      transactions.add(newTx);
    });
  }

  void _openTransactionModal(BuildContext context, bool isIncome) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return TransactionForm(
          isIncome: isIncome,
          onSubmit: _addNewTransaction,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      // ListView no Scaffold permite que a tela toda role, resolvendo o problema de espaço
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 40),
            decoration: BoxDecoration(
              color: darkHeader,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.account_balance_wallet, color: Colors.white, size: 24),
                    SizedBox(width: 10),
                    Text('Asset Flow', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 32),
                const Text('SALDO TOTAL', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 1.0)),
                const SizedBox(height: 4),
                Text(
                  currencyFormat.format(totalBalance),
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(icon: const Icon(Icons.chevron_left, size: 20), onPressed: () => _changeMonth(-1)),
                Text(
                  DateFormat('MMMM yyyy', 'pt_BR').format(currentMonth).toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5),
                ),
                IconButton(icon: const Icon(Icons.chevron_right, size: 20), onPressed: () => _changeMonth(1)),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: greenIncome,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    onPressed: () => _openTransactionModal(context, true),
                    child: const Text('Receita', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: redExpense,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    onPressed: () => _openTransactionModal(context, false),
                    child: const Text('Despesa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: ['Todas', 'Receitas', 'Despesas'].map((filter) {
                bool isSelected = currentFilter == filter;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => currentFilter = filter),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isSelected ? [const BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))] : [],
                      ),
                      child: Center(
                        child: Text(
                          filter,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? Colors.black87 : Colors.black54,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          if (expensesByCategory.isNotEmpty && currentFilter != 'Receitas')
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text('Gastos por Categoria', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black54)),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 70,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: expensesByCategory.keys.length,
                    itemBuilder: (context, index) {
                      String category = expensesByCategory.keys.elementAt(index);
                      double amount = expensesByCategory[category]!;
                      
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(category, style: TextStyle(color: Colors.grey[500], fontSize: 11, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(currencyFormat.format(amount), style: TextStyle(color: redExpense, fontSize: 14, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),

          if (filteredTransactions.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(child: Text('Nenhuma transação encontrada.', style: TextStyle(color: Colors.black54, fontSize: 14))),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
              itemCount: filteredTransactions.length,
              itemBuilder: (context, index) {
                final t = filteredTransactions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey[200]!),
                  ),
                  elevation: 0,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: (t.isIncome ? greenIncome : redExpense).withOpacity(0.1),
                          child: Icon(
                            t.isIncome ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                            color: t.isIncome ? greenIncome : redExpense,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(t.category, style: TextStyle(color: Colors.grey[700], fontSize: 11, fontWeight: FontWeight.w500)),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(DateFormat('dd MMM.', 'pt_BR').format(t.date), style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${t.isIncome ? '+' : '-'} ${currencyFormat.format(t.amount)}',
                          style: TextStyle(color: t.isIncome ? greenIncome : redExpense, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: -0.3),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

// --- FORMULÁRIO DE TRANSAÇÃO ---
class TransactionForm extends StatefulWidget {
  final bool isIncome;
  final Function(String, double, String, bool) onSubmit;

  const TransactionForm({Key? key, required this.isIncome, required this.onSubmit}) : super(key: key);

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _customCategoryController = TextEditingController();

  String? _selectedCategory;
  late List<String> _categories;

  @override
  void initState() {
    super.initState();
    _categories = widget.isIncome
        ? ['Salário', 'Extra', 'Investimento', 'Outro']
        : ['Fixo', 'Alimentação', 'Transporte', 'Saúde', 'Lazer', 'Outro'];
    
    _selectedCategory = _categories.first;
  }

  void _submitForm() {
    final title = _titleController.text;
    final amountText = _amountController.text.replaceAll(',', '.');
    final amount = double.tryParse(amountText) ?? 0.0;

    String category = _selectedCategory!;

    if (category == 'Outro') {
      category = _customCategoryController.text;
    }

    if (title.isEmpty || amount <= 0 || category.isEmpty) {
      return;
    }

    widget.onSubmit(title, amount, category, widget.isIncome);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isIncome ? 'Nova Receita' : 'Nova Despesa',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: widget.isIncome ? const Color(0xFF56682E) : const Color(0xFFB55E45),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _titleController,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              labelText: 'Descrição (Ex: Pizza)',
              labelStyle: const TextStyle(fontSize: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              labelText: 'Valor (R\$)',
              labelStyle: const TextStyle(fontSize: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            decoration: InputDecoration(
              labelText: 'Categoria',
              labelStyle: const TextStyle(fontSize: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            items: _categories.map((String cat) {
              return DropdownMenuItem(value: cat, child: Text(cat));
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _selectedCategory = newValue;
              });
            },
          ),
          if (_selectedCategory == 'Outro') ...[
            const SizedBox(height: 16),
            TextField(
              controller: _customCategoryController,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Nome da Categoria',
                labelStyle: const TextStyle(fontSize: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.isIncome ? const Color(0xFF56682E) : const Color(0xFFB55E45),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              onPressed: _submitForm,
              child: const Text('Salvar Transação', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}