import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bootiehunter/providers/bootie_provider.dart';
import 'package:bootiehunter/models/bootie.dart';
import 'package:bootiehunter/widgets/status_badge.dart';
import 'package:bootiehunter/screens/bootie_detail_screen.dart';

class BootiesListScreen extends StatefulWidget {
  const BootiesListScreen({super.key});

  @override
  State<BootiesListScreen> createState() => _BootiesListScreenState();
}

class _BootiesListScreenState extends State<BootiesListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BootieProvider>().loadBooties();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booties'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilters,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<BootieProvider>().refreshBooties(),
          ),
        ],
      ),
      body: Consumer<BootieProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.booties.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${provider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.refreshBooties(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final booties = provider.filteredBooties;

          if (booties.isEmpty) {
            return const Center(child: Text('No booties found'));
          }

          return RefreshIndicator(
            onRefresh: () => provider.refreshBooties(),
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: booties.length,
              itemBuilder: (context, index) {
                final bootie = booties[index];
                return _BootieCard(bootie: bootie);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to create bootie screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFilters() {
    final provider = context.read<BootieProvider>();
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Filters',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: provider.statusFilter,
              decoration: const InputDecoration(labelText: 'Status'),
              items: [
                const DropdownMenuItem(value: null, child: Text('All')),
                const DropdownMenuItem(value: 'captured', child: Text('Captured')),
                const DropdownMenuItem(value: 'submitted', child: Text('Submitted')),
                const DropdownMenuItem(value: 'researching', child: Text('Researching')),
                const DropdownMenuItem(value: 'researched', child: Text('Researched')),
                const DropdownMenuItem(value: 'finalized', child: Text('Finalized')),
              ],
              onChanged: (value) => provider.setStatusFilter(value),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                provider.clearFilters();
                Navigator.pop(context);
              },
              child: const Text('Clear Filters'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BootieCard extends StatelessWidget {
  final Bootie bootie;

  const _BootieCard({required this.bootie});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BootieDetailScreen(bootieId: bootie.id),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: bootie.primaryImageUrl != null
                  ? Image.network(
                      bootie.primaryImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, size: 48),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 48),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bootie.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  StatusBadge(status: bootie.status, compact: true),
                  if (bootie.recommendedBounty != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '\$${bootie.recommendedBounty!.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

