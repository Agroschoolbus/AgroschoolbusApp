import 'package:flutter/material.dart';
import 'package:agroschoolbus/pages/map.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../firebase_options.dart';

import 'package:flutter/gestures.dart';
import '../services/api.dart';
import 'package:agroschoolbus/utils/ui_controller.dart';



class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  late API _api;
  late UiController ui_ctrl;

  @override
  void initState() {
    super.initState();
    ui_ctrl = UiController(context: context);
    _api = API(context: context);
  }
  
  
  

  // Future<User?> signUp(String email, String password) {
  void signUp() {
    dynamic obj = {
      "title": "Εγγραφή",
      "message": "Για εγγραφή νέου χρήστη, παρακαλώ επικοινωνήστε με τον διαχειριστή itzortzis@mail.ntua.gr", 
    };
    ui_ctrl.showDialogBox(obj);
  }
    
    // try {
    //   UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
    //     email: "itzortzis@mail.ntua.gr",
    //     password: "",
    //   );
    //   _api.addUser({
    //     "name": "Yannis",
    //     "lastname": "Tzortzis",
    //     "username": "itzortzis",
    //     "id": userCredential.user?.uid
    //   });
    //   print(userCredential.user?.uid);
    //   return userCredential.user;
    // } catch (e) {
    //   print("Error: $e");
    //   return null;
    // }
  


  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential.user;
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }


  void _getInput() async{

    User? user = await signIn(emailController.text, passController.text);
    String userId = "";
    userId = user?.uid ?? "";

    if (userId != "") {
      Map<String, dynamic> data = await _api.fetchUserDetails(userId);
      
      if (data["type"] == 'transporter') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MapPage(title: 'Map Page')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Icon at the top
                Image.asset(
                  'assets/icons/agro_icon.png', // Path to your asset
                  height: 100, // Adjust height as needed
                  width: 100, // Adjust width as needed
                ),
                
                

                // Text below the icon
                const Text(
                  "Agroschoolbus",
                  style: TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40.0),
                const Text(
                  "Πραγματοποιείστε είσοδο για να συνεχίσετε.",
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.normal,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 8.0),

                // Email TextField
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 16.0),

                // Password TextField
                TextField(
                  controller: passController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),

                const SizedBox(height: 24.0),

                // Login Button
                ElevatedButton(
                  onPressed: () {
                    _getInput();
                    // signUp("", "");

                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    backgroundColor: const Color.fromARGB(255, 110, 154, 56),
                    foregroundColor: const Color.fromARGB(255, 77, 77, 77),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                  child: const Text("Είσοδος"),
                  
                ),

                const SizedBox(height: 60.0),

                

                // const Text.rich(
                //   TextSpan(
                //     text: 'Αν δεν έχετε λογαριασμό, μπορείτε να κάνετε ', // Regular text
                //     style: TextStyle(fontSize: 16.0, color: Color.fromARGB(255, 117, 117, 117),), // Default style
                //     children: <TextSpan>[
                //       TextSpan(
                //         text: 'εγγραφή', 
                //         style: TextStyle(
                //           fontWeight: FontWeight.bold,
                //           decoration: TextDecoration.underline,
                //           ), // Bold text for "run"
                //       ),
                //     ],
                //   ),
                // ),

                Text.rich(
                TextSpan(
                  text: 'Αν δεν έχετε λογαριασμό, μπορείτε να κάνετε ',
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Color.fromARGB(255, 117, 117, 117),
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'εγγραφή',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        // color: Colors.blue, // looks like a link
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          signUp();
                          // For example, navigate to register page
                          // Navigator.pushNamed(context, '/register');
                        },
                    ),
                  ],
                ),
              ),


              ],
            ),
          ),
        ),
      ),
    );
  }
}
