import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart'; // Uncomment if using Lottie animations

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'About BCI System',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: false,
        backgroundColor: Colors.deepPurple,

        // 👇 This line makes the back arrow white
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              InfoCard(
                icon: Icons.memory,
                title: "Brain-Computer Interface (BCI)",
                description:
                    "BCI enables communication between the brain and external devices. It helps individuals with motor disabilities to interact with computers using brain signals.",
              ),
              InfoCard(
                icon: Icons.graphic_eq,
                title: "EEG Sensor",
                description:
                    "Electroencephalography (EEG) sensors detect electrical activity of the brain. These signals are essential for capturing user intent in BCI systems.",
              ),
              InfoCard(
                icon: Icons.wifi,
                title: "Neurofeedback Technology",
                description:
                    "Neurofeedback provides real-time feedback to users about their brain activity, promoting better mental control and learning.",
              ),
              InfoCard(
                icon: Icons.healing,
                title: "Support for ALS Patients",
                description:
                    "This system is designed to assist ALS (Amyotrophic Lateral Sclerosis) patients by enabling communication and control through brain signals.",
              ),
              SizedBox(height: 20),
              Divider(),
              SizedBox(height: 10),
              Text(
                "Final Year Project by students of\nICS, Dawood University of Engineering and Technology",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(
                "Batch: 21F-BSCS-61, 21F-BSCS-60, 21F-BSCS-83",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey[700]),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const InfoCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Colors.deepPurple),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple),
                  ),
                  SizedBox(height: 8),
                  Text(description, style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
