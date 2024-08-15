import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:msib_johan/core/model/wallet_model.dart';
import 'package:msib_johan/core/provider/wallet_provider.dart';
import '../../core/model/category_model.dart';
import '../../core/provider/category_provider.dart';
import '../../core/provider/expense_provider.dart'; // Ganti dengan path yang sesuai

class ExpensesPage extends ConsumerWidget {
  const ExpensesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenseState = ref.watch(expenseProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Expenses")),
      body: RefreshIndicator(
        onRefresh: () async {
          // Panggil fungsi untuk mendapatkan ulang data expenses
          ref.refresh(expenseProvider);
        },
        child: expenseState.when(
          data: (expenses) {
            if (expenses.isEmpty) {
              return Center(
                  child: Column(
                children: [
                  Text("No expenses available"),
                  ElevatedButton(
                      onPressed: () {
                        ref.refresh(expenseProvider);
                      },
                      child: Text('refresh'))
                ],
              ));
            }

            return Container(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 10),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Consumer(
                            builder: (context, ref, child) {
                              final walletState = ref.watch(walletProvider);

                              return walletState.when(
                                data: (wallets) {
                                  // Find the wallet name based on the walletId
                                  final wallet = wallets.firstWhere(
                                    (wal) => wal.id == expense.walletId,
                                    orElse: () => WalletModel(
                                        id: -1,
                                        name: 'Unknown',
                                        userId: -1,
                                        createdAt: DateTime.now(),
                                        updatedAt: DateTime.now()),
                                  );

                                  return Text(
                                      'Wallet: ${wallet.name}'); // Display the wallet name
                                },
                                loading: () => const Center(
                                    child: CircularProgressIndicator()),
                                error: (error, _) => Text('Error: $error'),
                              );
                            },
                          ),
                          SizedBox(height: 5),
                          Text(expense.name),
                          SizedBox(height: 5),
                          Text('Amount: ${expense.amount}'),
                          Consumer(
                            builder: (context, ref, child) {
                              final categoryState = ref.watch(categoryProvider);

                              return categoryState.when(
                                data: (categories) {
                                  final category = categories.firstWhere(
                                    (cat) => cat.id == expense.categoryId,
                                    orElse: () => CategoryModel(
                                        id: -1,
                                        name: 'Unknown',
                                        type: 'expense'),
                                  );

                                  return Text(
                                      'Category: ${category.name}'); // Display the category name
                                },
                                loading: () => const Center(
                                    child: CircularProgressIndicator()),
                                error: (error, _) => Text('Error: $error'),
                              );
                            },
                          ),
                          Text('time: ${expense.time}'),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      // Initialize with existing values
                                      final selectedCategoryIdNotifier =
                                          ValueNotifier<int?>(
                                              expense.categoryId);

                                      final cleanedExpenseAmount = expense
                                          .amount
                                          .split('.')[0]
                                          .replaceAll(RegExp(r'[^\d]'), '');
                                      final expenseNameController =
                                          TextEditingController(
                                              text: expense.name);
                                      final expenseAmountController =
                                          TextEditingController(
                                              text: cleanedExpenseAmount);

                                      return Consumer(
                                        builder: (context, ref, child) {
                                          final categoryState =
                                              ref.watch(categoryProvider);
                                          final expenseNotifier = ref
                                              .watch(expenseProvider.notifier);

                                          return AlertDialog(
                                            title: const Text('Update Expense'),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                // DropdownButton to select category
                                                ValueListenableBuilder<int?>(
                                                  valueListenable:
                                                      selectedCategoryIdNotifier,
                                                  builder: (context,
                                                      selectedCategoryId,
                                                      child) {
                                                    return categoryState.when(
                                                      data: (categories) {
                                                        return DropdownButton<
                                                            int>(
                                                          hint: const Text(
                                                              'Select Category'),
                                                          value:
                                                              selectedCategoryId,
                                                          onChanged:
                                                              (int? newValue) {
                                                            selectedCategoryIdNotifier
                                                                    .value =
                                                                newValue;
                                                          },
                                                          items: categories
                                                              .map((category) {
                                                            return DropdownMenuItem<
                                                                int>(
                                                              value:
                                                                  category.id,
                                                              child: Text(
                                                                  category
                                                                      .name),
                                                            );
                                                          }).toList(),
                                                        );
                                                      },
                                                      loading: () =>
                                                          const CircularProgressIndicator(),
                                                      error: (error, _) =>
                                                          Text('Error: $error'),
                                                    );
                                                  },
                                                ),
                                                // TextField for Expense Name
                                                TextField(
                                                  controller:
                                                      expenseNameController,
                                                  decoration:
                                                      const InputDecoration(
                                                    labelText: 'Expense Name',
                                                  ),
                                                ),
                                                // TextField for Amount
                                                TextField(
                                                  controller:
                                                      expenseAmountController,
                                                  decoration:
                                                      const InputDecoration(
                                                    labelText: 'Amount',
                                                  ),
                                                  keyboardType:
                                                      TextInputType.number,
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () async {
                                                  if (expenseNameController.text.isNotEmpty &&
                                                      expenseAmountController
                                                          .text.isNotEmpty &&
                                                      selectedCategoryIdNotifier
                                                              .value !=
                                                          null) {
                                                    await expenseNotifier
                                                        .updateExpense(
                                                      expense
                                                          .walletId, // Keep the existing wallet ID
                                                      expense.id,
                                                      expenseNameController
                                                          .text,
                                                      selectedCategoryIdNotifier
                                                          .value!,
                                                      expenseAmountController
                                                          .text,
                                                      DateTime.now(),
                                                    );
                                                    Navigator.of(context).pop();
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            'Please fill all fields and select a category'),
                                                      ),
                                                    );
                                                  }
                                                },
                                                child: const Text('Update'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('Cancel'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Delete Expense'),
                                        content: const Text(
                                            'Are you sure you want to delete this expense?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () async {
                                              await ref
                                                  .watch(
                                                      expenseProvider.notifier)
                                                  .deleteExpense(expense.id);
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Delete'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Cancel'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text("Error: $error")),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              String expenseName = '';
              String expenseAmount = '';
              int? selectedWalletId; // State for storing the selected wallet
              int?
                  selectedCategoryId; // State for storing the selected category

              return Consumer(
                builder: (context, ref, child) {
                  final walletState = ref.watch(walletProvider);
                  final categoryState = ref.watch(categoryProvider);

                  return AlertDialog(
                    title: const Text('Add Expense'),
                    content: walletState.when(
                      data: (wallets) {
                        return categoryState.when(
                          data: (categories) {
                            return StatefulBuilder(
                              builder: (context, setState) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // DropdownButton to select wallet
                                    DropdownButton<int>(
                                      hint: const Text('Select Wallet'),
                                      value: selectedWalletId,
                                      onChanged: (int? newValue) {
                                        setState(() {
                                          selectedWalletId = newValue;
                                        });
                                      },
                                      items: wallets.map((wallet) {
                                        return DropdownMenuItem<int>(
                                          value: wallet.id,
                                          child: Text(wallet.name),
                                        );
                                      }).toList(),
                                    ),
                                    // DropdownButton to select category
                                    DropdownButton<int>(
                                      hint: const Text('Select Category'),
                                      value: selectedCategoryId,
                                      onChanged: (int? newValue) {
                                        setState(() {
                                          selectedCategoryId = newValue;
                                        });
                                      },
                                      items: categories.map((category) {
                                        return DropdownMenuItem<int>(
                                          value: category.id,
                                          child: Text(category.name),
                                        );
                                      }).toList(),
                                    ),
                                    TextField(
                                      onChanged: (value) {
                                        expenseName = value;
                                      },
                                      decoration: const InputDecoration(
                                        labelText: 'Expense Name',
                                      ),
                                    ),
                                    TextField(
                                      onChanged: (value) {
                                        expenseAmount = value;
                                      },
                                      decoration: const InputDecoration(
                                        labelText: 'Amount',
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (error, _) => Text('Error: $error'),
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, _) => Text('Error: $error'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () async {
                          ref.refresh(expenseProvider);
                          if (expenseName.isNotEmpty &&
                              expenseAmount.isNotEmpty &&
                              selectedWalletId != null &&
                              selectedCategoryId != null) {
                            await ref
                                .watch(expenseProvider.notifier)
                                .createExpense(
                                  selectedWalletId!,
                                  expenseName,
                                  selectedCategoryId!,
                                  expenseAmount,
                                  DateTime.now(),
                                );
                            Navigator.of(context).pop();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Please fill all fields and select both wallet and category'),
                              ),
                            );
                          }
                        },
                        child: const Text('Add'),
                      ),
                      TextButton(
                        onPressed: () {
                          ref.refresh(expenseProvider);
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
