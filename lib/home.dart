import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'model/products_repository.dart';
import 'model/product.dart';

import 'login.dart';

class HomePage extends StatelessWidget {

  List<Card> _buildGridCards(BuildContext context,List<Product> products) {

    if (products == null || products.isEmpty) {
      return const <Card>[];
    }

    final ThemeData theme = Theme.of(context);
    final NumberFormat formatter = NumberFormat.simpleCurrency(
        locale: Localizations.localeOf(context).toString());

    return products.map((product) {
      return Card(
        clipBehavior: Clip.antiAlias,
        // TODO: Adjust card heights (103)
        child: Column(
          // TODO: Center items on the card (103)
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 18 / 11,
              child: Image.network(
                product.img,
                fit: BoxFit.fitWidth,
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      product.name,
                      style: new TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      product.gap,
                      style: TextStyle(
                        fontSize: 12.0,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: FlatButton(
                        padding: EdgeInsets.fromLTRB(0, 18.0, 0, 0.0),
                        child: Text('more',style: new TextStyle(
                          color: Colors.blue,fontSize: 12.0,
                        )),
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute<void>(builder: (BuildContext context) {
                                return MorePage(product);
                              }));
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
  List<Product> products;

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<CRUDModel>(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.person,
            semanticLabel: 'menu',
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/myPage');
          },
        ),
        title: user_text == null ? new Text("Null"):new Text(user_text),
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
                return GridView.count(
                  crossAxisCount: 2,
                  padding: EdgeInsets.all(16.0),
                  childAspectRatio: 8.0 / 9.0,
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

class MorePage extends StatelessWidget {
  final Product product;
  MorePage(this.product);

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<CRUDModel>(context);
    Widget titleSection = Container(
      padding: const EdgeInsets.fromLTRB(32.0, 0, 10.0, 32.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    product.name,
                    style: new TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.attach_money,
                      size: 20.0,
                    ),
                    Text(
                      product.gap,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize : 15,
                      ),
                    ),
                  ],
                ),

              ],
            ),
          ),
        ],
      ),
    );

    Widget devides = Divider(
      height: 1.0,
      color: Colors.black,
    );
    Widget textSection = Container(
      padding: const EdgeInsets.all(32.0),
      child:Text(
        product.more,
        style: TextStyle(
          fontSize : 15,
        ),
      ),
    );

    Widget userSection = Container(
      padding: const EdgeInsets.all(32.0),
      child:Text(
        product.creator,
        style: TextStyle(
          color: Colors.grey[700],
          fontSize : 10,
        ),
      ),
    );
    return MaterialApp(

      title: '21800140',
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.navigate_before,
              semanticLabel: 'menu',
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/home');
            },
          ),
          title: Text("Detail"),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.mode_edit,
                semanticLabel: 'add',
              ),
              onPressed: () {

              },
            ),
            IconButton(
              icon: Icon(
                Icons.delete,
                semanticLabel: 'add',
              ),
              onPressed: ()async {
                if(product.creator==user_text) {
                  await productProvider.removeProduct(product.id);
                  Navigator.pop(context);
                }else Scaffold.of(context).showSnackBar(SnackBar(content: Text("nope")));

            },
            ),
          ],
        ),
        body: ListView(
          children: [
            Stack(
              children: <Widget>[
                Container(
                  child: Hero(
                    tag: product,
                    child: Image.network(
                      product.img,
                      width: 600,
                      height: 240,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  right: 0.0,
                  top: 0.0,
                  child:  FavoriteWidget(product),
                ),
              ],
            ),
            titleSection,
            devides,
            textSection,
            userSection,
          ],
        ),
      ),
    );
  }



}
class FavoriteWidget extends StatefulWidget {
  final Product product;
  FavoriteWidget(this.product);
  @override
  _FavoriteWidgetState createState() => _FavoriteWidgetState(product);
}

class _FavoriteWidgetState extends State<FavoriteWidget> {

  bool _isFavorited = true;
  final Product product;
  _FavoriteWidgetState(this.product);
  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<CRUDModel>(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(0),
          child: IconButton(
            icon: ( Icon(Icons. thumb_up) ),
            color: Colors.red,
            onPressed: ()async {
              setState(() {
              if (_isFavorited) {
                productProvider.likeProducts(product.id);
                _isFavorited = false;
                Scaffold.of(context).showSnackBar(SnackBar(content: Text("like it!")));
              } else {
                Scaffold.of(context).showSnackBar(SnackBar(content: Text("you can only do it once!")));
              }
            });
            }
          ),
        ),
        SizedBox(
          width: 18,
          child: Container(
            child: Text(product.like.toString()),
          ),
        ),
      ],
    );
  }

}




