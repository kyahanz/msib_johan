import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/provider/expense_provider.dart';
import '../../core/provider/wallet_provider.dart';
import '../../core/services/api_method.dart';

class HomePage extends ConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletState = ref.watch(walletProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Wallets"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              logout(context);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Panggil fungsi untuk mendapatkan ulang data wallet
          ref.refresh(walletProvider);
        },
        child: walletState.when(
          data: (wallets) {
            if (wallets.isEmpty) {
              return Center(
                  child: Column(
                children: [
                  ElevatedButton(
                      onPressed: () {
                        ref.refresh(walletProvider);
                      },
                      child: Text('Refresh')),
                  Text("No wallets available"),
                ],
              ));
            }

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      ref.refresh(expenseProvider);
                      Navigator.pushNamed(context, '/expenses');
                    },
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      child: Center(
                        child: Text(
                          "See Expenses",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: wallets.length,
                    itemBuilder: (context, index) {
                      final wallet = wallets[index];
                      return ListTile(
                        title: Text(wallet.name),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    String walletName = '';

                                    return AlertDialog(
                                      title: Text('Update Wallet'),
                                      content: TextField(
                                        onChanged: (value) {
                                          walletName = value;
                                        },
                                        decoration: InputDecoration(
                                          labelText: wallet.name,
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () async {
                                            if (walletName.isNotEmpty) {
                                              // Tambahkan logika untuk menambahkan wallet baru
                                              await ref
                                                  .watch(walletProvider.notifier)
                                                  .updateWallet(
                                                      wallet.id, walletName);
                                              ref.refresh(walletProvider);
                                              Navigator.of(context).pop();
                                            } else {
                                              // Tampilkan pesan jika nama wallet kosong
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        'Wallet name cannot be empty')),
                                              );
                                            }
                                          },
                                          child: Text('Update'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            ref.refresh(walletProvider);
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('Cancel'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                await ref
                                    .watch(walletProvider.notifier)
                                    .deleteWallet(wallet.id);
                                ref.refresh(walletProvider);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () {
                    ref.refresh(walletProvider);
                  },
                  child: Text('Refresh')),
              Text("Error: $error"),
            ],
          )),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              String walletName = '';

              return AlertDialog(
                title: Text('Add Wallet'),
                content: TextField(
                  onChanged: (value) {
                    walletName = value;
                  },
                  decoration: InputDecoration(
                    labelText: 'Wallet Name',
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      if (walletName.isNotEmpty) {
                        // Tambahkan logika untuk menambahkan wallet baru
                        await ref
                            .watch(walletProvider.notifier)
                            .createWallet(walletName);
                        ref.refresh(walletProvider);
                        Navigator.of(context).pop();
                      } else {
                        // Tampilkan pesan jika nama wallet kosong
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Wallet name cannot be empty')),
                        );
                      }
                    },
                    child: Text('Add'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
