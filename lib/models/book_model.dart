import 'package:cloud_firestore/cloud_firestore.dart';

class BookModel {
  final String id;
  final String bookName;
  final String authorName;
  final num bookPrice;
  final String userId;
  final Timestamp createdAt;
  final String? bookNumber;
  final String? isbn;
  final DateTime? purchaseDate;
  final int? bookQuantity;
  final String? status;

  BookModel({
    required this.id,
    required this.bookName,
    required this.authorName,
    required this.bookPrice,
    required this.userId,
    required this.createdAt,
    this.bookNumber,
    this.isbn,
    this.purchaseDate,
    this.bookQuantity,
    this.status = 'Want to Read',
  });

  factory BookModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    num bookPrice;
    if (data['bookPrice'] is String) {
      bookPrice = num.tryParse(data['bookPrice']) ?? 0;
    } else if (data['bookPrice'] is num) {
      bookPrice = data['bookPrice'];
    } else {
      bookPrice = 0;
    }

  
    DateTime? parsedPurchaseDate;
    if (data['purchaseDate'] is Timestamp) {
      parsedPurchaseDate = (data['purchaseDate'] as Timestamp).toDate();
    }

    return BookModel(
      id: doc.id,
      bookName: data['bookName'] ?? '',
      authorName: data['authorName'] ?? '',
      bookPrice: bookPrice,
      userId: data['userId'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      bookNumber: data['bookNumber'],
      isbn: data['isbn'],
      purchaseDate: parsedPurchaseDate,
      bookQuantity: data['bookQuantity'],
      status: data['status'] ?? 'Want to Read',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'bookName': bookName,
      'authorName': authorName,
      'bookPrice': bookPrice,
      'userId': userId,
      'createdAt': createdAt,
      'bookNumber': bookNumber,
      'isbn': isbn,
      'purchaseDate': purchaseDate != null ? Timestamp.fromDate(purchaseDate!) : null,
      'bookQuantity': bookQuantity,
      'status': status,
    };
  }
}
