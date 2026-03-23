import 'package:flutter/material.dart';

import '../models/data_models/ad_data_model.dart';

class ReportWidget extends StatefulWidget {
  final AdDataModel adModel;
  const ReportWidget({super.key, required this.adModel});

  @override
  State<ReportWidget> createState() => _ReportWidgetState();
}

class _ReportWidgetState extends State<ReportWidget> {
  Widget _reportOption(
    String label,
    String subtitle,
    String value,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      child: ListTile(
        tileColor: Colors.grey.shade100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(8),
        ),
        dense: true,
        leading: Icon(icon, color: Colors.red),
        title: Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.red),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        onTap: () => Navigator.pop(context, value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // drag handle
          const Center(
            child: SizedBox(
              width: 40,
              height: 4,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Report this ad',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                _reportOption(
                  'Misleading, scam, or fake offer',
                  'The ad tries to trick users, make false promises, or steal money or data.',
                  'scam',
                  Icons.phishing,
                ),
                _reportOption(
                  'Adult, alcohol, smoking, drugs, or gambling content',
                  'Promotes age-restricted or regulated products.',
                  'restricted',
                  Icons.block,
                ),
                _reportOption(
                  'Harmful, hateful, or inappropriate content',
                  'Violence, hate speech, abuse, or unsafe material.',
                  'harmful',
                  Icons.warning_amber_rounded,
                ),
                _reportOption(
                  'Unsafe, broken, or suspicious link',
                  'Does not work, redirects unexpectedly, or looks unsafe.',
                  'unsafe',
                  Icons.link_off,
                ),
                _reportOption(
                  'Spam, low-quality, or repetitive',
                  'Appears too often or provides little value.',
                  'spam',
                  Icons.repeat,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red, width: 1.5),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
          ),
        ],
      ),
    );
  }
}
