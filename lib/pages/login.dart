import 'package:flutter/material.dart';
import 'package:agroschoolbus/pages/map.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  
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
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 16.0),

                // Password TextField
                const TextField(
                  decoration: InputDecoration(
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MapPage(title: 'Map Page')),
                    );
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

                

                const Text.rich(
                  TextSpan(
                    text: 'Αν δεν έχετε λογαριασμό, μπορείτε να κάνετε ', // Regular text
                    style: TextStyle(fontSize: 16.0, color: Color.fromARGB(255, 117, 117, 117),), // Default style
                    children: <TextSpan>[
                      TextSpan(
                        text: 'εγγραφή', 
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          ), // Bold text for "run"
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
