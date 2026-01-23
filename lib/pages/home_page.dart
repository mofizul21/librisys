import 'package:librisys/app/mobile/auth_service.dart';
import 'package:librisys/constants/constants.dart';
import 'package:librisys/models/book_model.dart';
import 'package:librisys/controllers/book_controller.dart';
import 'package:librisys/utils/ui_utils.dart'; // Added import
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final BookController _bookController = BookController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String? userId = authService.value.currentUser?.uid;

    if (userId == null) {
      return const Center(child: Text("Please log in to view books."));
    }

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search books...",
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<BookModel>>(
              stream: _bookController.getBooksStream(userId: userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  debugPrint("Firestore Error: ${snapshot.error}");
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(
                          "assets/lotties/BooksGathering.json",
                          height: 200,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "No books added yet!",
                          style: KTextStyleTitle.pageTitle,
                        ),
                      ],
                    ),
                  );
                }

                final List<BookModel> books = snapshot.data!;
                final List<BookModel> filteredBooks = _filterBooks(
                  books,
                  _searchQuery,
                );

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 8.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total books: ${filteredBooks.length}",
                            style: KTextStyleTitle.pageTitle,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredBooks.length,
                        itemBuilder: (context, index) {
                          final BookModel book = filteredBooks[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            child: ListTile(
                              title: Text(book.bookName),
                              subtitle: Text(
                                "${book.authorName} - \$${book.bookPrice}${book.status != null && book.status!.isNotEmpty ? ' Status: ${book.status}' : ''}",
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _showEditBookDialog(book),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () =>
                                        _showDeleteConfirmationDialog(book),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBookDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  List<BookModel> _filterBooks(List<BookModel> books, String query) {
    if (query.isEmpty) {
      return books;
    }
    final lowerCaseQuery = query.toLowerCase();
    return books.where((book) {
      return book.bookName.toLowerCase().contains(lowerCaseQuery) ||
          book.authorName.toLowerCase().contains(lowerCaseQuery);
    }).toList();
  }

  void _showDeleteConfirmationDialog(BookModel book) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: Text("Are you sure you want to delete '${book.bookName}'?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await _bookController.deleteBook(bookId: book.id);
                  if (!mounted) return;
                  Navigator.of(context).pop();
                  showCustomSnackBar(
                    context,
                    SnackBarType.success,
                    "Book deleted.",
                  );
                } catch (e) {
                  if (!mounted) return;
                  showCustomSnackBar(
                    context,
                    SnackBarType.error,
                    "Failed to delete book: $e",
                  );
                }
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void _showAddBookDialog() {
    final TextEditingController bookNameController = TextEditingController();
    final TextEditingController authorNameController = TextEditingController();
    final TextEditingController bookPriceController = TextEditingController();
    final TextEditingController bookNumberController = TextEditingController();
    final TextEditingController isbnController = TextEditingController();
    final TextEditingController bookQuantityController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        DateTime? selectedPurchaseDate;
        String? selectedStatus = 'Want to Read';

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Add a new book"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: bookNameController,
                      decoration: const InputDecoration(
                        labelText: "Book Name *",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: authorNameController,
                      decoration: const InputDecoration(
                        labelText: "Author Name",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: bookPriceController,
                      decoration: const InputDecoration(
                        labelText: "Book Price",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*$'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: bookNumberController,
                      decoration: const InputDecoration(
                        labelText: "Book Number",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: isbnController,
                      decoration: const InputDecoration(
                        labelText: "ISBN",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: bookQuantityController,
                      decoration: const InputDecoration(
                        labelText: "Book Quantity",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*$')),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      readOnly: true,
                      controller: TextEditingController(
                        text: selectedPurchaseDate == null
                            ? ''
                            : selectedPurchaseDate!.toLocal().toString().split(
                                ' ',
                              )[0],
                      ),
                      decoration: const InputDecoration(
                        labelText: "Purchase Date",
                        suffixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedPurchaseDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null && picked != selectedPurchaseDate) {
                          setState(() {
                            selectedPurchaseDate = picked;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: const InputDecoration(
                        labelText: "Select Status",
                        border: OutlineInputBorder(),
                      ),
                      items: <String>['Want to Read', 'Reading', 'Read']
                          .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          })
                          .toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedStatus = newValue;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    bookNameController.clear();
                    authorNameController.clear();
                    bookPriceController.clear();
                    bookNumberController.clear();
                    isbnController.clear();
                    bookQuantityController.clear();
                    setState(() {
                      selectedPurchaseDate = null;
                      selectedStatus = 'Want to Read';
                    });
                  },
                  child: const Text("Clear"),
                ),
                TextButton(
                  onPressed: () async {
                    if (bookNameController.text.trim().isEmpty) {
                      showCustomSnackBar(
                        context,
                        SnackBarType.error,
                        "Book Name is mandatory.",
                      );
                      return;
                    }

                    final String? userId = authService.value.currentUser?.uid;
                    if (userId == null) {
                      showCustomSnackBar(
                        context,
                        SnackBarType.error,
                        "You need to be logged in to add a book.",
                      );
                      return;
                    }
                    try {
                      await _bookController.addBook(
                        bookName: bookNameController.text,
                        authorName: authorNameController.text,
                        bookPrice: double.parse(bookPriceController.text),
                        userId: userId,
                        bookNumber: bookNumberController.text.isNotEmpty
                            ? bookNumberController.text
                            : null,
                        isbn: isbnController.text.isNotEmpty
                            ? isbnController.text
                            : null,
                        purchaseDate: selectedPurchaseDate,
                        bookQuantity: bookQuantityController.text.isNotEmpty
                            ? int.tryParse(bookQuantityController.text)
                            : null,
                        status: selectedStatus,
                      );
                      if (!mounted) return;
                      showCustomSnackBar(
                        context,
                        SnackBarType.success,
                        "Book added successfully.",
                      );
                      Navigator.of(context).pop();
                    } catch (e) {
                      showCustomSnackBar(
                        context,
                        SnackBarType.error,
                        "Failed to add book: $e",
                      );
                    }
                  },
                  child: const Text("Save"),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditBookDialog(BookModel book) {
    final TextEditingController bookNameController = TextEditingController(
      text: book.bookName,
    );
    final TextEditingController authorNameController = TextEditingController(
      text: book.authorName,
    );
    final TextEditingController bookPriceController = TextEditingController(
      text: book.bookPrice.toString(),
    );
    final TextEditingController bookNumberController = TextEditingController(
      text: book.bookNumber,
    );
    final TextEditingController isbnController = TextEditingController(
      text: book.isbn,
    );
    final TextEditingController bookQuantityController = TextEditingController(
      text: book.bookQuantity?.toString(),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        DateTime? selectedPurchaseDate = book.purchaseDate;
        String? selectedStatus = book.status ?? 'Want to Read';

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Edit book"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: bookNameController,
                      decoration: const InputDecoration(
                        hintText: "Book Name *",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: authorNameController,
                      decoration: const InputDecoration(
                        hintText: "Author Name",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: bookPriceController,
                      decoration: const InputDecoration(
                        hintText: "Book Price",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*$'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: bookNumberController,
                      decoration: const InputDecoration(
                        labelText: "Book Number",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: isbnController,
                      decoration: const InputDecoration(
                        hintText: "ISBN",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: bookQuantityController,
                      decoration: const InputDecoration(
                        hintText: "Book Quantity",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*$')),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      readOnly: true,
                      controller: TextEditingController(
                        text: selectedPurchaseDate == null
                            ? ''
                            : selectedPurchaseDate!.toLocal().toString().split(
                                ' ',
                              )[0],
                      ),
                      decoration: const InputDecoration(
                        hintText: "Purchase Date",
                        suffixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedPurchaseDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null && picked != selectedPurchaseDate) {
                          setState(() {
                            selectedPurchaseDate = picked;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: const InputDecoration(
                        hintText: "Select Status",
                        border: OutlineInputBorder(),
                      ),
                      items: <String>['Want to Read', 'Reading', 'Read']
                          .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          })
                          .toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedStatus = newValue;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    bookNameController.clear();
                    authorNameController.clear();
                    bookPriceController.clear();
                    bookNumberController.clear();
                    isbnController.clear();
                    bookQuantityController.clear();
                    setState(() {
                      selectedPurchaseDate = null;
                      selectedStatus = 'Want to Read';
                    });
                  },
                  child: const Text("Clear"),
                ),
                TextButton(
                  onPressed: () async {
                    if (bookNameController.text.trim().isEmpty) {
                      showCustomSnackBar(
                        context,
                        SnackBarType.error,
                        "Book Name is mandatory.",
                      );
                      return;
                    }
                    try {
                      await _bookController.updateBook(
                        bookId: book.id,
                        bookName: bookNameController.text,
                        authorName: authorNameController.text,
                        bookPrice: double.parse(bookPriceController.text),
                        bookNumber: bookNumberController.text.isNotEmpty
                            ? bookNumberController.text
                            : null,
                        isbn: isbnController.text.isNotEmpty
                            ? isbnController.text
                            : null,
                        purchaseDate: selectedPurchaseDate,
                        bookQuantity: bookQuantityController.text.isNotEmpty
                            ? int.tryParse(bookQuantityController.text)
                            : null,
                        status: selectedStatus,
                      );
                      if (!mounted) return;
                      showCustomSnackBar(
                        context,
                        SnackBarType.success,
                        "Book updated successfully.",
                      );
                      Navigator.of(context).pop();
                    } catch (e) {
                      showCustomSnackBar(
                        context,
                        SnackBarType.error,
                        "Failed to update book: $e",
                      );
                    }
                  },
                  child: const Text("Save"),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
