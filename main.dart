import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budget Calculator',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      debugShowCheckedModeBanner: false,
      home: const SimpleBudgetCalculator(),
    );
  }
}

class SimpleBudgetCalculator extends StatefulWidget {
  const SimpleBudgetCalculator({Key? key}) : super(key: key);

  @override
  State<SimpleBudgetCalculator> createState() => _SimpleBudgetCalculatorState();
}

class _SimpleBudgetCalculatorState extends State<SimpleBudgetCalculator> {
  final TextEditingController _incomeController = TextEditingController();
  final TextEditingController _expensesController = TextEditingController();

  double _balance = 0.0;
  bool _showBalance = false;

  final List<CalculationHistory> _history = <CalculationHistory>[];

  void _calculateBalance() {
    final double income = double.tryParse(_incomeController.text) ?? 0.0;
    final double expenses = double.tryParse(_expensesController.text) ?? 0.0;

    final double newBalance = income - expenses;

    final CalculationHistory newEntry = CalculationHistory(
      income: income,
      expenses: expenses,
      balance: newBalance,
      timestamp: DateTime.now(),
    );

    setState(() {
      _balance = newBalance;
      _showBalance = true;
      _history.insert(0, newEntry);
    });
  }

  void _clearFields() {
    _incomeController.clear();
    _expensesController.clear();
    setState(() {
      _showBalance = false;
      _balance = 0.0;
    });
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
    );
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _expensesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color balanceColor =
        _balance >= 0 ? Colors.green.shade700 : Colors.red.shade700;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Calculator'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildTextField(
                _incomeController,
                'Total Income',
                Icons.arrow_upward,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                _expensesController,
                'Total Expenses',
                Icons.arrow_downward,
              ),
              const SizedBox(height: 32),
              Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: _calculateBalance,
                      child: const Text('Calculate'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  TextButton.icon(
                    onPressed: _clearFields,
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear'),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              if (_showBalance)
                Column(
                  children: <Widget>[
                    Text(
                      'REMAINING BALANCE:',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹${_balance.toStringAsFixed(2)}', // Changed from '$' to '₹'
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: balanceColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              if (_history.isNotEmpty) ...<Widget>[
                const SizedBox(height: 40),
                Text(
                  'History',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _history.length,
                  itemBuilder: (BuildContext context, int index) {
                    final CalculationHistory item = _history[index];
                    final Color itemBalanceColor =
                        item.balance >= 0 ? Colors.green : Colors.red;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6.0),
                      child: ListTile(
                        title: Text(
                          'Balance: ₹${item.balance.toStringAsFixed(2)}', // Changed from '$' to '₹'
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: itemBalanceColor,
                          ),
                        ),
                        subtitle: Text(
                          'Income: ₹${item.income.toStringAsFixed(2)} | Expenses: ₹${item.expenses.toStringAsFixed(2)}', // Changed from '$' to '₹'
                        ),
                        trailing: Text(
                          '${item.timestamp.hour}:${item.timestamp.minute.toString().padLeft(2, '0')}',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class CalculationHistory {
  final double income;
  final double expenses;
  final double balance;
  final DateTime timestamp;

  CalculationHistory({
    required this.income,
    required this.expenses,
    required this.balance,
    required this.timestamp,
  });
}
