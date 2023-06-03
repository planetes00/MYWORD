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
  String name;
  String gap;
  int like;
  String more;
  String creator;
  String creation;
  String recent;
  String img;

  DocumentReference reference;

  Product({this.id, this.name, this.gap, this.like, this.more,
    this.creator, this.creation, this.recent,this.img});

  Product.fromMap(Map snapshot,String id) :
        id = id ?? '',
        gap= snapshot['gap'] ?? '',
        name = snapshot['name'] ?? '',
        like = snapshot['like'] ?? 0,
        more = snapshot['more'] ?? '',
        creator = snapshot['creator'] ?? '',
        creation = snapshot['creation'] ?? '',
        recent = snapshot['recent'] ?? '',
        img = snapshot['img'] ?? '';


  toJson() {
    return {
      "gap": gap,
      "name": name,
      "like": like,
      "creator":creator,
      "more":more,
      "creation":creation,
      "recent":recent,
      "img": img,
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

  Future<void> likeProducts(String id) async {
    Firestore.instance.collection('products').document(id).updateData({'like': FieldValue.increment(1)});
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