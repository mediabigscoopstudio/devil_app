import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/matching_provider.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MatchingProvider>().fetchMatches();
    });
  }

  @override
  Widget build(BuildContext context) {
    final matchingProvider = context.watch<MatchingProvider>();
    final matches = matchingProvider.matches;
    final isLoading = matchingProvider.status == MatchingStatus.loading;

    return Scaffold(
      appBar: AppBar(title: const Text('Matches')),
      body: isLoading && matches.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : matches.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('No matches yet.'),
                      if (matchingProvider.errorMessage != null)
                        Text('Error: ${matchingProvider.errorMessage}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<MatchingProvider>().fetchMatches(),
                        child: const Text('Refresh'),
                      )
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
                    final profile = matches[index];
                    return GestureDetector(
                      onTap: () {
                        // Navigate to conversation when messaging is implemented
                      },
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            profile.profilePhotoUrl != null
                                ? CachedNetworkImage(
                                    imageUrl: profile.profilePhotoUrl!,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    color: Colors.grey[800],
                                    child: const Icon(Icons.person, size: 50),
                                  ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                color: Colors.black54,
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  profile.name ?? 'Unknown',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
