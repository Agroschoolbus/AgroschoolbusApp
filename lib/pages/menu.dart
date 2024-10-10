import 'package:flutter/material.dart';
import 'package:agroschoolbus/pages/map.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(""),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Title
            const Text(
              "Agroschoolbus",
              style: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8.0),

            // Subtitle

            const Text.rich(
              TextSpan(
                text: 'Κεντρική σελίδα της εφαρμογής. Τύπος χρήστη: ', // Regular text
                style: TextStyle(fontSize: 18.0, color: Color.fromARGB(255, 97, 97, 97),), // Default style
                children: <TextSpan>[
                  TextSpan(
                    text: 'Ελαιοπαραγωγός', 
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      ), // Bold text for "run"
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 60.0),

            // Buttons
            ElevatedButton(
              onPressed: () {
                // Button 1 action
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 110, 154, 56),
                foregroundColor: const Color.fromARGB(255, 77, 77, 77),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7.0),
                )
              ),
              child: const Text("Επεξεργασία προσωπικών στοιχείων"),
              
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MapPage(title: 'Map Page')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 110, 154, 56),
                foregroundColor: const Color.fromARGB(255, 77, 77, 77),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7.0),
                )
              ),
              child: const Text("Επισήμανση θέσης σάκων"),
              
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                // Button 3 action
              },
              
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 110, 154, 56),
                foregroundColor: const Color.fromARGB(255, 77, 77, 77),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7.0),
                )
              ),
              child: const Text("Δημιουργία/Διόρθωση μονοπατιού"),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                // Button 4 action
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 110, 154, 56),
                foregroundColor: const Color.fromARGB(255, 77, 77, 77),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7.0),
                )
              ),
              child: const Text("Άλλο"),
            ),
            const SizedBox(height: 40.0),
            ElevatedButton(
              onPressed: () {
                // Button 5 action
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffefbe64),
                foregroundColor: const Color.fromARGB(255, 77, 77, 77),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7.0),
                )
              ),
              child: const Text("Σάκοι προς συλλογή: 5"),
              
            ),

            const SizedBox(height: 60.0),

            


            const Text.rich(
                  TextSpan(
                    text: 'Έχουν συλλεχθεί συνολικά ', // Regular text
                    style: TextStyle(fontSize: 16.0, color: Color.fromARGB(255, 117, 117, 117),), // Default style
                    children: <TextSpan>[
                      TextSpan(
                        text: '0', 
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          ), // Bold text for "run"
                      ),
                      TextSpan(
                        text: ' σάκοι.', 
                        style: TextStyle(
                          ), // Bold text for "run"
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
          ],
        ),
      ),
    );
  }
}
