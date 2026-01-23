import 'package:flutter/foundation.dart';
import 'package:librisys/models/book_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'books';

  Future<void> addBook({
    required String bookName,
    required String authorName,
    required num bookPrice,
    required String userId,
    String? bookNumber,
    String? isbn,
    DateTime? purchaseDate,
    int? bookQuantity,
    String? status,
  }) async {
    try {
      await _firestore.collection(_collection).add({
        'bookName': bookName,
        'authorName': authorName,
        'bookPrice': bookPrice,
        'userId': userId,
        'createdAt': Timestamp.now(),
        'bookNumber': bookNumber,
        'isbn': isbn,
        'purchaseDate': purchaseDate != null ? Timestamp.fromDate(purchaseDate) : null,
        'bookQuantity': bookQuantity,
        'status': status,
      });
    } catch (e) {
      debugPrint("Error adding book: $e");
      rethrow;
    }
  }

  Stream<List<BookModel>> getBooksStream({required String userId}) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => BookModel.fromFirestore(doc))
              .toList();
        });
  }

  Future<void> updateBook({
    required String bookId,
    required String bookName,
    required String authorName,
    required num bookPrice,
    String? bookNumber, 
    String? isbn, 
    DateTime? purchaseDate, 
    int? bookQuantity, 
    String? status, 
  }) async {
    try {
      await _firestore.collection(_collection).doc(bookId).update({
        'bookName': bookName,
        'authorName': authorName,
        'bookPrice': bookPrice,
        'updatedAt': Timestamp.now(),
        'bookNumber': bookNumber,
        'isbn': isbn,
        'purchaseDate': purchaseDate != null ? Timestamp.fromDate(purchaseDate) : null,
        'bookQuantity': bookQuantity,
        'status': status,
      });
    } catch (e) {
      debugPrint("Error updating book: $e");
      rethrow;
    }
  }

  Future<void> deleteBook({required String bookId}) async {
    try {
      await _firestore.collection(_collection).doc(bookId).delete();
    } catch (e) {
      debugPrint("Error deleting book: $e");
      rethrow;
    }
  }
}
