import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminSubscriptionsScreen extends StatefulWidget {
  const AdminSubscriptionsScreen({Key? key}) : super(key: key);

  @override
  _AdminSubscriptionsScreenState createState() => _AdminSubscriptionsScreenState();
}

class _AdminSubscriptionsScreenState extends State<AdminSubscriptionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'all';
  String _paymentFilter = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Subscriptions'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: _showFiltersDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by car name or user ID...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('user_subscriptions')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.subscriptions, size: 60, color: Colors.grey[400]),
                        const SizedBox(height: 20),
                        Text(
                          'No subscriptions found',
                          style: TextStyle(color: Colors.grey[600], fontSize: 18),
                        ),
                      ],
                    ),
                  );
                }

                // Filter logic
                final filteredDocs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final matchesSearch = _searchQuery.isEmpty ||
                      data['carName'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      data['userId'].toString().toLowerCase().contains(_searchQuery.toLowerCase());

                  final matchesStatus = _statusFilter == 'all' ||
                      data['status'].toString() == _statusFilter;

                  final matchesPayment = _paymentFilter == 'all' ||
                      data['paymentStatus'].toString() == _paymentFilter;

                  return matchesSearch && matchesStatus && matchesPayment;
                }).toList();

                if (filteredDocs.isEmpty) {
                  return Center(child: Text('No matching subscriptions'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    return _buildAdminSubscriptionCard(context, doc.id, data);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminSubscriptionCard(BuildContext context, String subscriptionId, Map<String, dynamic> data) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    //final timeFormat = DateFormat('hh:mm a');

    final startDate = (data['startDate'] as Timestamp).toDate();
    final endDate = (data['endDate'] as Timestamp).toDate();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: ExpansionTile(
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['carName'] ?? 'Unknown Car',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'User: ${data['userId']}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(data['status']),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                (data['status'] ?? 'active').toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAdminDetailRow('Subscription ID:', subscriptionId),
                _buildAdminDetailRow('User ID:', data['userId']),
                _buildAdminDetailRow('Car ID:', data['carId']),
                const Divider(height: 24),
                _buildAdminDetailRow('Duration:', data['duration'] ?? 'N/A'),
                _buildAdminDetailRow('Price:', '₹${data['price']?.toString() ?? '0'}'),
                _buildAdminDetailRow(
                  'Payment Status:',
                  data['paymentStatus'] ?? 'N/A',
                  textColor: data['paymentStatus'] == 'completed' ? Colors.green : Colors.orange,
                ),
                _buildAdminDetailRow('Payment Method:', data['paymentMethod'] ?? 'N/A'),
                const Divider(height: 24),
                _buildAdminDetailRow('Start Date:', dateFormat.format(startDate)),
                _buildAdminDetailRow('End Date:', dateFormat.format(endDate)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      icon: Icons.edit,
                      label: 'Edit',
                      color: Colors.blue,
                      onPressed: () => _editSubscription(subscriptionId),
                    ),
                    _buildActionButton(
                      icon: Icons.receipt,
                      label: 'Invoice',
                      color: Colors.green,
                      onPressed: () => _generateInvoice(subscriptionId),
                    ),
                    _buildActionButton(
                      icon: Icons.delete,
                      label: 'Delete',
                      color: Colors.red,
                      onPressed: () => _confirmDelete(subscriptionId),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminDetailRow(String label, String value, {Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: textColor ?? Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      icon: Icon(icon, size: 18, color: color),
      label: Text(
        label,
        style: TextStyle(color: color),
      ),
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      case 'expired':
        return Colors.blueGrey;
      default:
        return Colors.blue;
    }
  }

  void _showFiltersDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Filter Subscriptions'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: _statusFilter,
                    decoration: const InputDecoration(labelText: 'Subscription Status'),
                    items: [
                      'all',
                      'active',
                      'cancelled',
                      'pending',
                      'expired',
                    ].map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status[0].toUpperCase() + status.substring(1)),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _statusFilter = value!),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _paymentFilter,
                    decoration: const InputDecoration(labelText: 'Payment Status'),
                    items: [
                      'all',
                      'completed',
                      'pending',
                      'failed',
                    ].map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status[0].toUpperCase() + status.substring(1)),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _paymentFilter = value!),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Reset'),
                  onPressed: () {
                    setState(() {
                      _statusFilter = 'all';
                      _paymentFilter = 'all';
                    });
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: const Text('Apply'),
                  onPressed: () {
                    setState(() {});
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _editSubscription(String subscriptionId) {
    // Implement edit functionality
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Subscription'),
        content: const Text('Edit functionality would go here'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Save'),
            onPressed: () {
              // Save changes to Firestore
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _generateInvoice(String subscriptionId) {
    // Implement invoice generation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Generating invoice for $subscriptionId')),
    );
  }

  void _confirmDelete(String subscriptionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this subscription?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () {
              FirebaseFirestore.instance
                  .collection('user_subscriptions')
                  .doc(subscriptionId)
                  .delete();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Subscription deleted')),
              );
            },
          ),
        ],
      ),
    );
  }
}