import 'package:flutter/material.dart';
import 'package:agroschoolbus/pages/map.dart';

class MenuPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Title
            Text(
              "Agroschoolbus",
              style: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 8.0),

            // Subtitle
            Text(
              "Κεντρική σελίδα της εφαρμογής. Τύπος χρήστη: Ελαιοπαραγωγός",
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 60.0),

            // Buttons
            ElevatedButton(
              onPressed: () {
                // Button 1 action
              },
              child: Text("Επεξεργασία προσωπικών στοιχείων"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 110, 154, 56),
                foregroundColor: Color.fromARGB(255, 77, 77, 77),
                padding: EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7.0),
                )
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MapPage(title: 'Map Page')),
                );
              },
              child: Text("Επισήμανση θέσης σάκων"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 110, 154, 56),
                foregroundColor: Color.fromARGB(255, 77, 77, 77),
                padding: EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7.0),
                )
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                // Button 3 action
              },
              child: Text("Δημιουργία/Διόρθωση μονοπατιού"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 110, 154, 56),
                foregroundColor: Color.fromARGB(255, 77, 77, 77),
                padding: EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7.0),
                )
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                // Button 4 action
              },
              child: Text("Άλλο"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 110, 154, 56),
                foregroundColor: Color.fromARGB(255, 77, 77, 77),
                padding: EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7.0),
                )
              ),
            ),
            SizedBox(height: 40.0),
            ElevatedButton(
              onPressed: () {
                // Button 5 action
              },
              child: Text("Σάκοι προς συλλογή: 5"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xefbe64),
                foregroundColor: Color.fromARGB(255, 77, 77, 77),
                padding: EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7.0),
                )
              ),
            ),

            SizedBox(height: 60.0),

            // Text at the bottom
            Text(
              "Έχουν συλλεχθεί συνολικά 0 σάκοι",
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
