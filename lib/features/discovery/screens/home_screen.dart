import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/discovery_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DiscoveryProvider>().fetchFeed();
    });
  }

  @override
  Widget build(BuildContext context) {
    final discoveryProvider = context.watch<DiscoveryProvider>();
    final feed = discoveryProvider.feed;
    final isLoading = discoveryProvider.status == DiscoveryStatus.loading;

    return Scaffold(
      appBar: AppBar(title: const Text('Devil - Discovery')),
      body: isLoading && feed.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : feed.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('No profiles available.'),
                      if (discoveryProvider.errorMessage != null)
                        Text('Error: ${discoveryProvider.errorMessage}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<DiscoveryProvider>().fetchFeed(),
                        child: const Text('Refresh'),
                      )
                    ],
                  ),
                )
              : Stack(
                  children: feed.reversed.map((profile) {
                    final isTop = profile.id == feed.first.id;
                    return Align(
                      alignment: Alignment.center,
                      child: Card(
                        elevation: isTop ? 8 : 2,
                        margin: const EdgeInsets.all(16),
                        child: SizedBox(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  color: Colors.grey[800],
                                  child: profile.profilePhotoUrl != null
                                      ? CachedNetworkImage(
                                          imageUrl: profile.profilePhotoUrl!,
                                          fit: BoxFit.cover,
                                        )
                                      : const Icon(Icons.person, size: 100),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${profile.name ?? 'Unknown'}, ${profile.birthDate ?? ''}',
                                      style: Theme.of(context).textTheme.headlineSmall,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(profile.bio ?? 'No bio'),
                                    const SizedBox(height: 16),
                                    if (isTop)
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          FloatingActionButton(
                                            heroTag: 'pass_${profile.id}',
                                            backgroundColor: Colors.grey,
                                            onPressed: () => context.read<DiscoveryProvider>().swipeLeft(profile),
                                            child: const Icon(Icons.close),
                                          ),
                                          FloatingActionButton(
                                            heroTag: 'like_${profile.id}',
                                            backgroundColor: Colors.red,
                                            onPressed: () => context.read<DiscoveryProvider>().swipeRight(profile),
                                            child: const Icon(Icons.favorite),
                                          ),
                                        ],
                                      )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
    );
  }
}
