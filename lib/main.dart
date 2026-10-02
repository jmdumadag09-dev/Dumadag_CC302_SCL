
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'API Item List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ItemListPage(),
    );
  }
}

class ItemListPage extends StatefulWidget {
  const ItemListPage({super.key});

  @override
  State<ItemListPage> createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  List items = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  
  Future<void> fetchItems() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('https://jsonplaceholder.typicode.com/posts'),
      );

      if (response.statusCode == 200) {
        setState(() {
          items = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load items');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching data';
      });
    }
  }

 
  Future<void> deleteItem(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('https://jsonplaceholder.typicode.com/posts/$id'),
      );

      if (response.statusCode == 200 ||
          response.statusCode == 204) {
        setState(() {
          items.removeWhere((item) => item['id'] == id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item deleted successfully'),
          ),
        );
      } else {
        throw Exception('Failed to delete item');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete item'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Item List'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchItems,
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(errorMessage),
                      ElevatedButton(
                        onPressed: fetchItems,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : items.isEmpty
                  ? const Center(
                      child: Text('No items available'),
                    )
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text('${item['id']}'),
                            ),
                            title: Text(
                              item['title'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              item['body'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                deleteItem(item['id']);
                              },
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}