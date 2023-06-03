import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'model/product.dart';
import 'login.dart';
class addPage extends StatefulWidget {
  @override
  _addPageState createState() => _addPageState();
}

class _addPageState extends State<addPage> {
  String title;
  String gap;
  String Des;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<CRUDModel>(context);
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '단어',
                    fillColor: Colors.grey[300],
                    filled: true,
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return '단어 넣으라고';
                    }
                  },
                  onSaved: (value) => title = value
              ),
              SizedBox(height: 16,),
              TextFormField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '뜻',
                    fillColor: Colors.grey[300],
                    filled: true,
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return '뜻 넣어 좀';
                    }
                  },
                  onSaved: (value) => Des = value
              ),
              RaisedButton(
                splashColor: Colors.red,
                onPressed: () async{
                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();
                    await productProvider.addProduct(Product(  creator:user_text,word: title, mean: Des));
                    Navigator.pushNamed(context, '/home');
                  }
                },
                child: Text('단어 추가', style: TextStyle(color: Colors.white)),
                color: Colors.blue,
              )

            ],
          ),
        ),
      ),
    );
  }
}