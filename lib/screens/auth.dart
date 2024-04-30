import 'dart:io';

import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _firebaseAuth = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<StatefulWidget> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  var _isLogin = true;
  final _formKey = GlobalKey<FormState>();
  var _userEmail = '';
  var _userPassword = '';
  var _userName = '';
  File? _userImageFile;
  var _isAuthenticating = false;

  void _submitForm() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid || !_isLogin && _userImageFile == null) {
      return;
    }

    _formKey.currentState!.save();

    try {
      setState(() {
        _isAuthenticating = true;
      });
      if (_isLogin) {
        await _firebaseAuth.signInWithEmailAndPassword(
            email: _userEmail, password: _userPassword);

        setState(() {
          _isAuthenticating = false;
        });
      } else {
        final userCredentials =
            await _firebaseAuth.createUserWithEmailAndPassword(
                email: _userEmail, password: _userPassword);

        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${userCredentials.user!.uid}.jpg');

        await storageRef.putFile(_userImageFile!);
        final imageUrl = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({
          'username': _userName,
          'email': _userEmail,
          'image_url': imageUrl,
        });

        setState(() {
          _isAuthenticating = false;
        });
      }
    } on FirebaseAuthException catch (error) {
      var message = 'Authentication failed!';
      if (error.message != null) {
        message = error.message!;
      }
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
      setState(() {
        _isAuthenticating = false;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error.toString()),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: const Text('FlutterChat'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                    bottom: 20, top: 20, left: 20, right: 20),
                width: 200,
                child: Image.asset('assets/images/chat.png', fit: BoxFit.cover),
              ),
              Card(
                margin: const EdgeInsets.only(left: 20, right: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!_isLogin)
                          UserImagePicker(
                              onImagePick: ((pickedImage) =>
                                  _userImageFile = pickedImage)),
                        if (!_isLogin)
                          TextFormField(
                            decoration:
                                const InputDecoration(labelText: 'Username'),
                            keyboardType: TextInputType.name,
                            enableSuggestions: false,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) => value == null ||
                                    value.trim().isEmpty ||
                                    value.length < 3
                                ? 'The username must be at least 3 characters long'
                                : null,
                            onSaved: (value) {
                              _userName = value!;
                            },
                          ),
                        TextFormField(
                          decoration:
                              const InputDecoration(labelText: 'Email Address'),
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          validator: (value) =>
                              value!.trim().isEmpty || !value.contains('@')
                                  ? 'Please enter a valid email address'
                                  : null,
                          onSaved: (value) {
                            _userEmail = value!;
                          },
                        ),
                        TextFormField(
                          decoration:
                              const InputDecoration(labelText: 'Password'),
                          obscureText: true,
                          autocorrect: false,
                          validator: (value) => value!.trim().isEmpty ||
                                  value.length < 6
                              ? 'Password must be at least 6 characters long'
                              : null,
                          onSaved: (value) {
                            _userPassword = value!;
                          },
                        ),
                        const SizedBox(height: 12),
                        if (_isAuthenticating)
                          const CircularProgressIndicator(),
                        if (!_isAuthenticating)
                          ElevatedButton(
                            onPressed: _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                            ),
                            child: Text(_isLogin ? 'Login' : 'Signup'),
                          ),
                        if (!_isAuthenticating)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = !_isLogin;
                              });
                            },
                            child: Text(_isLogin
                                ? 'Create new account'
                                : 'I already have an account'),
                          ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
