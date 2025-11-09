import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bootiehunter/providers/bootie_provider.dart';
import 'package:bootiehunter/models/bootie.dart';
import 'package:bootiehunter/widgets/status_badge.dart';
import 'package:bootiehunter/providers/auth_provider.dart';

class BootieDetailScreen extends StatelessWidget {
  final int bootieId;

  const BootieDetailScreen({super.key, required this.bootieId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Bootie>(
      future: context.read<BootieProvider>().bootieService.getBootie(bootieId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('Bootie Details')),
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        final bootie = snapshot.data!;
        return _BootieDetailView(bootie: bootie);
      },
    );
  }
}

class _BootieDetailView extends StatefulWidget {
  final Bootie bootie;

  const _BootieDetailView({required this.bootie});

  @override
  State<_BootieDetailView> createState() => _BootieDetailViewState();
}

class _BootieDetailViewState extends State<_BootieDetailView> {
  late Bootie _bootie;

  @override
  void initState() {
    super.initState();
    _bootie = widget.bootie;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final canFinalize = authProvider.currentUser?.canFinalize ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bootie Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Gallery
            if (_bootie.primaryImageUrl != null)
              SizedBox(
                height: 300,
                child: PageView.builder(
                  itemCount: 1 + _bootie.alternateImageUrls.length,
                  itemBuilder: (context, index) {
                    final imageUrl = index == 0
                        ? _bootie.primaryImageUrl!
                        : _bootie.alternateImageUrls[index - 1];
                    return Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, size: 64),
                        );
                      },
                    );
                  },
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Status
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _bootie.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      StatusBadge(status: _bootie.status),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Category
                  Text(
                    _bootie.categoryDisplayName,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Description
                  if (_bootie.description != null) ...[
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _bootie.description!,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Location
                  if (_bootie.location != null) ...[
                    Text(
                      'Location',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _bootie.location!.name,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Recommended Bounty
                  if (_bootie.recommendedBounty != null) ...[
                    Text(
                      'Recommended Bounty',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${_bootie.recommendedBounty!.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Research Summary
                  if (_bootie.researchSummary != null) ...[
                    Text(
                      'Research Summary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _bootie.researchSummary!,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Final Bounty
                  if (_bootie.finalBounty != null) ...[
                    Text(
                      'Final Bounty',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${_bootie.finalBounty!.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[700],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),

            // Action Buttons
            if (canFinalize && _bootie.isResearched && !_bootie.isFinalized)
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () => _showFinalizeDialog(context),
                  child: const Text('Finalize to Square'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showFinalizeDialog(BuildContext context) {
    final finalBountyController = TextEditingController(
      text: _bootie.recommendedBounty?.toStringAsFixed(2) ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finalize Bootie'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the final bounty amount:'),
            const SizedBox(height: 16),
            TextField(
              controller: finalBountyController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Final Bounty',
                prefixText: '\$',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final finalBounty = double.tryParse(finalBountyController.text);
              if (finalBounty == null || finalBounty <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid amount')),
                );
                return;
              }

              try {
                await context.read<BootieProvider>().finalizeBootie(
                      _bootie.id,
                      finalBounty,
                    );
                if (context.mounted) {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to list
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bootie finalized successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Finalize'),
          ),
        ],
      ),
    );
  }
}

