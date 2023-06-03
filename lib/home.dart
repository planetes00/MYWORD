import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'model/products_repository.dart';
import 'model/product.dart';

import 'login.dart';

final List<Product> tog=[];
class FavoriteWidget extends StatefulWidget {
  final Product product;
  FavoriteWidget(this.product);
  @override
  _FavoriteWidgetState createState() => _FavoriteWidgetState(product);
}

class _FavoriteWidgetState extends State<FavoriteWidget> {
  final Product product;
  _FavoriteWidgetState(this.product);
  @override
  Widget build(BuildContext context) {
    return Row(
        children: <Widget>[
          FlatButton(

            child: (tog.contains(product) ? Text(product.mean,style: TextStyle(fontSize: 15.0,)) : Text('            ')),
            onPressed: _toggleFavorite,
          ),
          Icon(Icons.arrow_left ),
          ],

    );

  }
  void _toggleFavorite() {
    setState(() {
      if (tog.contains(product)) tog.remove(product);
      else tog.add(product);
    });
  }

}

class HomePage extends StatelessWidget {

  List<Card> _buildGridCards(BuildContext context,List<Product> products) {

    if (products == null || products.isEmpty) {
      return const <Card>[];
    }

    final ThemeData theme = Theme.of(context);
    final NumberFormat formatter = NumberFormat.simpleCurrency(
        locale: Localizations.localeOf(context).toString());


    return products.map((product) {

      return new Card(
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            ListTile(
            onLongPress: () => alertDialog(context,product),
            title: Row(
              children: <Widget>[
                Expanded(
                  child: Text(product.word,style: TextStyle(fontSize: 15.0,)),
                ),
                FavoriteWidget(product),
              ],
            ),
          ),
        ]),
      );

        }).toList();
  }

  List<Product> products;
  void alertDialog(BuildContext context, Product product) {
    final productProvider = Provider.of<CRUDModel>(context);
    var alert = AlertDialog(
      title: Text(product.word),
      actions: <Widget>[
        FlatButton(
          child: Text('시험 목록에 추가'),
          onPressed: () {
            items.add(product);
            Navigator.pop(context);
          },
        ),
        FlatButton(
          child: Text('삭제'),
          onPressed: ()async {
            await productProvider.removeProduct(product.id);
            Navigator.pushNamed(context, '/home');
          },
        ),
      ],
    );
    showDialog(context: context, builder: (BuildContext context) => alert);
  }


  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<CRUDModel>(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.spellcheck,
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/myPage');
          },
        ),
        title: Text("내 단 어"),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.add,
              semanticLabel: 'add',
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/add');
            },
          ),
          IconButton(
            icon: Icon(
              Icons.check_box,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/home');
            },
          ),
        ],
      ),
      body: Center(
        child:StreamBuilder(
            stream: productProvider.fetchProductsAsStream(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                products = snapshot.data.documents
                    .map((doc) => Product.fromMap(doc.data, doc.documentID))
                    .toList();
                return ListView(
                  padding: EdgeInsets.all(16.0),
                  children: _buildGridCards(context, products),
                );
              } else {
                return Text('fetching');
              }
            }),

      ),
      resizeToAvoidBottomInset: false,
    );
  }


}





