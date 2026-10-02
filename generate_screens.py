import os

SCREENS = [
    {
        "name": "name_screen",
        "widget": "NameScreen",
        "title": "Your Name",
        "subtext": "What should we call you?",
        "field": "display_name",
        "next": "/onboarding/age"
    },
    {
        "name": "age_screen",
        "widget": "AgeScreen",
        "title": "How old are you?",
        "subtext": "",
        "field": "date_of_birth",
        "next": "/onboarding/gender"
    },
    {
        "name": "gender_screen",
        "widget": "GenderScreen",
        "title": "How do you identify?",
        "subtext": "",
        "field": "gender",
        "next": "/onboarding/looking-for"
    },
    {
        "name": "looking_for_screen",
        "widget": "LookingForScreen",
        "title": "What are you looking for?",
        "subtext": "You can select multiple options.",
        "field": "looking_for",
        "next": "/onboarding/interests"
    },
    {
        "name": "interests_screen",
        "widget": "InterestsScreen",
        "title": "Your interests",
        "subtext": "Select a few to get better matches.",
        "field": "interests",
        "next": "/onboarding/photos"
    },
    {
        "name": "photos_screen",
        "widget": "PhotosScreen",
        "title": "Add your Photos",
        "subtext": "Add at least 3 photos to get better matches.",
        "field": "photos",
        "next": "/onboarding/bio"
    },
    {
        "name": "bio_screen",
        "widget": "BioScreen",
        "title": "A bit about you",
        "subtext": "Keep it real. This helps you find the right people.",
        "field": "bio",
        "next": "/onboarding/location"
    },
    {
        "name": "location_screen",
        "widget": "LocationScreen",
        "title": "Enable location?",
        "subtext": "Devil uses your location to show people near you and notify you when someone is close by.",
        "field": "location",
        "next": "/onboarding/review"
    },
    {
        "name": "review_screen",
        "widget": "ReviewScreen",
        "title": "Almost done!",
        "subtext": "",
        "field": "review",
        "next": "/onboarding/notifications"
    },
    {
        "name": "notifications_screen",
        "widget": "NotificationsScreen",
        "title": "Turn on notifications?",
        "subtext": "Get notified about matches, messages and when someone is near you.",
        "field": "notifications",
        "next": "/onboarding/success"
    },
    {
        "name": "success_screen",
        "widget": "SuccessScreen",
        "title": "You\'re all set!",
        "subtext": "Let\'s find some interesting people around you.",
        "field": "success",
        "next": "/"
    }
]

TEMPLATE = """import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/onboarding_provider.dart';

class {widget} extends StatefulWidget {{
  const {widget}({{super.key}});

  @override
  State<{widget}> createState() => _{widget}State();
}}

class _{widget}State extends State<{widget}> {{
  bool _isLoading = false;

  void _saveAndContinue() async {{
    // TODO: implement local validation and state update
    
    setState(() => _isLoading = true);
    final provider = context.read<OnboardingProvider>();
    final success = await provider.saveStep('{field}');
    
    if (mounted) {{
      setState(() => _isLoading = false);
      if (success) {{
        context.push('{next}');
      }} else {{
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.errorMessage ?? 'Failed to save')),
        );
      }}
    }}
  }}

  @override
  Widget build(BuildContext context) {{
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB), // Cream background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '{title}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              if ('{subtext}'.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  '{subtext}',
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
              const SizedBox(height: 32),
              
              // TODO: specific fields for this screen
              const Expanded(child: Center(child: Text("UI coming soon"))),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveAndContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF0055), // Devil pink
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    disabledBackgroundColor: Colors.grey.shade400,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          '{cta}',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }}
}}
"""

out_dir = "lib/features/profile/screens/onboarding"

for s in SCREENS:
    cta = "Continue"
    if s["name"] == "location_screen":
        cta = "Enable Location"
    elif s["name"] == "review_screen":
        cta = "Complete Profile"
    elif s["name"] == "notifications_screen":
        cta = "Enable Notifications"
    elif s["name"] == "success_screen":
        cta = "Go to Home"

    content = TEMPLATE.format(
        widget=s["widget"],
        title=s["title"],
        subtext=s["subtext"],
        field=s["field"],
        next=s["next"],
        cta=cta
    )
    with open(f"{out_dir}/{s['name']}.dart", "w") as f:
        f.write(content)

print("Screens generated successfully.")
