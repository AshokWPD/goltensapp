import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Privacy Policy for Goltens EHS App',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Goltens Singapore is committed to ensuring the privacy and security of your personal information. This Privacy Policy outlines how we collect, use, maintain, and disclose information collected from users of the Goltens EHS mobile application ("App").',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '1. Linking Privacy Policy',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'You can access our Privacy Policy directly within the Goltens EHS App. Additionally, it is available on our app\'s store listing page in the Play Store.',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '2. Labeling and Contact Information',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'This Privacy Policy is clearly labeled as such. For any inquiries or concerns regarding privacy matters, you can contact us at poovan.alves@goltens.com.',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '3. Accessibility',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Our Privacy Policy is designed to be easily readable in a standard web browser without requiring any plug-ins or special handlers. It is hosted on an active, publicly accessible, and non-geofenced URL.',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '4. Compliance with Google Play Policies',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Our Privacy Policy comprehensively discloses how our app accesses, collects, uses, and shares user data. It includes:',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      '- Types of personal and sensitive user data collected',
                      style: TextStyle(fontSize: 16),
                    ),
                    const Text(
                      '- Parties with which data is shared',
                      style: TextStyle(fontSize: 16),
                    ),
                    const Text(
                      '- Secure data handling procedures',
                      style: TextStyle(fontSize: 16),
                    ),
                    const Text(
                      '- Data retention and deletion policy',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '5. Data Retention and Deletion',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'We outline our data retention and deletion policy, detailing how long we retain user data and the procedures for deleting such data upon request.',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '6. Updates to Privacy Policy',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'We reserve the right to update our Privacy Policy at any time. Users will be notified of any changes through the app or via email.',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'By using the Goltens EHS App, you consent to the terms outlined in this Privacy Policy.',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'This Privacy Policy was last updated on (09/02/2024).',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Account Delete',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Delete your account by clicking "Delete Account" button in profile page.',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Divider(
                      thickness: 2,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Contact - Support',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Goltens Singapore',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () =>
                          _sendEmail('mailto:poovan.alves@goltens.com'),
                      child: const Text(
                        'poovan.alves@goltens.com',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () => _makePhoneCall('tel:+6582983597'),
                      child: const Text(
                        '+6582983597',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () => _launchURL('https://goltens.in/'),
                      child: const Text(
                        'https://goltens.in/',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Function to send email
  void _sendEmail(String email) async {
    if (await canLaunch(email)) {
      await launch(email);
    } else {
      throw 'Could not launch $email';
    }
  }

  // Function to make phone call
  void _makePhoneCall(String phone) async {
    if (await canLaunch(phone)) {
      await launch(phone);
    } else {
      throw 'Could not launch $phone';
    }
  }

  // Function to launch URL
  void _launchURL(String url) async {
    try {
      await launch(url);
    } catch (e) {
      print('Error launching URL with launch method: $e');
      // Try using other launch methods
      try {
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          throw 'Could not launch $url';
        }
      } catch (e) {
        print('Error launching URL with canLaunch method: $e');
      }
    }
  }
}
