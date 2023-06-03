import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:get_it/get_it.dart';
import 'dart:async';


enum Category { all, accessories, clothing, home, }

class Product {

  Category category;
  String id;
  bool isFeatured;
  String word;
  String mean;
  int CorrectRate;
  String creator;
  String creation;

  DocumentReference reference;

  Product({this.id, this.word, this.mean, this.CorrectRate,
    this.creator, this.creation});

  Product.fromMap(Map snapshot,String id) :
        id = id ?? '',
        mean= snapshot['mean'] ?? '',
        word = snapshot['word'] ?? '',
        CorrectRate = snapshot['CorrectRate'] ?? 0,
        creator = snapshot['creator'] ?? '',
        creation = snapshot['creation'] ?? '';


  toJson() {
    return {
      "mean": mean,
      "word": word,
      "CorrectRate": CorrectRate,
      "creator":creator,
      "creation":creation,
    };
  }

}

class Api{
  final Firestore _db = Firestore.instance;
  final String path;
  CollectionReference ref;

  Api( this.path ) {
    ref = _db.collection(path);
  }

  Future<QuerySnapshot> getDataCollection() {
    return ref.getDocuments() ;
  }
  Stream<QuerySnapshot> streamDataCollection() {
    return ref.snapshots() ;
  }
  Future<DocumentSnapshot> getDocumentById(String id) {
    return ref.document(id).get();
  }
  Future<void> removeDocument(String id){
    return ref.document(id).delete();
  }
  Future<DocumentReference> addDocument(Map data) {
    return ref.add(data);
  }
  Future<void> updateDocument(Map data , String id) {
    return ref.document(id).updateData(data) ;
  }



}


class CRUDModel extends ChangeNotifier {
  Api _api = locator<Api>();

  List<Product> products;

  Future<void> CorrectRateProducts(String id) async {
    Firestore.instance.collection('products').document(id).updateData({'CorrectRate': FieldValue.increment(1)});
  }

  Future<List<Product>> fetchProducts() async {
    var result = await _api.getDataCollection();
    products = result.documents
        .map((doc) => Product.fromMap(doc.data, doc.documentID))
        .toList();
    return products;
  }

  Stream<QuerySnapshot> fetchProductsAsStream() {
    return _api.streamDataCollection();
  }

  Future<Product> getProductById(String id) async {
    var doc = await _api.getDocumentById(id);
    return  Product.fromMap(doc.data, doc.documentID) ;
  }


  Future<void> removeProduct(String id) async{
    await _api.removeDocument(id) ;
  }
  Future<void> updateProduct(Product data,String id) async{
    await _api.updateDocument(data.toJson(), id) ;
  }

  Future<void> addProduct(Product data) async{
    var result  = await _api.addDocument(data.toJson()) ;
  }
}

GetIt locator = GetIt();

void setupLocator() {
  locator.registerLazySingleton(() => Api('products'));
  locator.registerLazySingleton(() => CRUDModel()) ;
}