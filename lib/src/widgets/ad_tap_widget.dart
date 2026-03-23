import 'package:flutter/material.dart';
import 'package:numeral/numeral.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/data_models/ad_data_model.dart';
import 'helper.dart';
import 'report_widget.dart';

class AdTapWidget extends StatefulWidget {
  final AdDataModel adModel;
  final Function onContinue;
  final Function(AdDataModel adModel, String reportType, BuildContext context)
  onReport;

  const AdTapWidget({
    super.key,
    required this.adModel,
    required this.onContinue,
    required this.onReport,
  });

  @override
  State<AdTapWidget> createState() => _AdTapWidgetState();
}

class _AdTapWidgetState extends State<AdTapWidget> {
  String statusText = 'Destination not yet verified';
  Color statusColor = Colors.orange;
  String buttonText = 'Continue Anyway';
  Color buttonColor = Colors.orange;

  @override
  void initState() {
    super.initState();
    switch (widget.adModel.destinationUrlStatus) {
      case 'safe':
        statusColor = Colors.green;
        statusText = 'Verified safe destination';
        buttonText = 'Continue';
        buttonColor = Colors.green;
        break;
      case 'unsafe':
        statusColor = Colors.red;
        statusText = 'Reported as unsafe by users';
        buttonText = 'Continue at Your Own Risk';
        buttonColor = Colors.red;
        break;
      case 'unchecked':
      default:
        statusColor = Colors.orange;
        statusText = 'Destination not yet verified';
        buttonText = 'Continue Anyway';
        buttonColor = Colors.orange;
        break;
    }
  }

  Widget _transparencyReportWidget(String destinationUrl) {
    return TextButton(
      style: TextButton.styleFrom(backgroundColor: Colors.transparent),
      onPressed: () async {
        final url = Uri.parse(
          'https://transparencyreport.google.com/safe-browsing/search?url=$destinationUrl',
        );
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      },
      child: const Text(
        'View transparency report',
        style: TextStyle(color: Colors.orange, fontSize: 13),
      ),
    );
  }

  Widget _destinationTile(String fullUrl) {
    final uri = Uri.tryParse(fullUrl);
    final domain = uri?.host ?? fullUrl;
    return ExpansionTile(
      collapsedIconColor: Colors.green,
      collapsedBackgroundColor: Colors.grey.shade100,
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(8),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(8),
      ),
      childrenPadding: const EdgeInsets.all(10),
      backgroundColor: Colors.grey.shade50,
      title: Text(
        domain,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.green,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: const Text(
        'Tap to view full destination',
        style: TextStyle(fontSize: 12, color: Colors.grey),
      ),
      iconColor: Colors.orange,
      children: [
        SelectableText(
          fullUrl,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: Colors.green),
        ),
      ],
    );
  }

  Color _reportColor(int impressions, int reports) {
    if (impressions <= 0) return Colors.grey;
    final rate = reports / impressions; // 0.0 → 1.0+
    if (rate < 0.005) return Colors.green; // <0.5%
    if (rate < 0.02) return Colors.orange; // 0.5–2%
    return Colors.red; // >2%
  }

  Widget? get _getReportsData {
    int reports = 0;
    String baseString =
        '${widget.adModel.impressionsCount.numeral(digits: 1)} views, ${widget.adModel.clicksCount.numeral(digits: 1)} clicks';
    if (widget.adModel.reportsData.keys.isNotEmpty) {
      List<String> tempRep = [];
      for (var repKey in widget.adModel.reportsData.keys) {
        int? repValue = AdsHelper.getInt(widget.adModel.reportsData[repKey]);
        if (repValue != null && repValue > 0) {
          reports = reports + repValue;
          tempRep.add('$repKey: ${repValue.numeral(digits: 1)}');
        }
      }
      baseString = "$baseString (${tempRep.join(', ')})";
    }
    return Text(
      baseString,
      style: TextStyle(
        color: _reportColor(widget.adModel.impressionsCount, reports),
        fontSize: 13,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget? repWidget = _getReportsData;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Row(
            children: [
              const Text(
                'Confirm destination',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.report, size: 20, color: Colors.red),
                color: Colors.grey,
                tooltip: 'Report Ad',
                onPressed: () async {
                  final result = await showModalBottomSheet<String>(
                    context: context,
                    useSafeArea: true,
                    isScrollControlled: true,
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    constraints: const BoxConstraints(maxWidth: 600),
                    builder: (BuildContext ctx) {
                      return ReportWidget(adModel: widget.adModel);
                    },
                  );
                  if (result != null) {
                    widget.onReport.call(widget.adModel, result, context);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                widget.adModel.destinationUrlStatus == 'safe'
                    ? Icons.verified
                    : Icons.warning_amber_rounded,
                size: 16,
                color: statusColor,
              ),
              const SizedBox(width: 6),
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 12,
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          const Text(
            'You’re about to visit an external website.\n'
            'Please verify the destination before continuing.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Text(
            'Ad Category: ${widget.adModel.category}',
            style: TextStyle(fontSize: 13, color: Colors.green),
          ),
          if (repWidget != null) ...[const SizedBox(height: 5), repWidget],
          const SizedBox(height: 10),
          _destinationTile("https://${widget.adModel.destinationUrl}"),
          const SizedBox(height: 5),
          _transparencyReportWidget("https://${widget.adModel.destinationUrl}"),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red, width: 1.5),
                  ),
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () async {
                    final url = Uri.parse(
                      "https://${widget.adModel.destinationUrl}",
                    );
                    if (await canLaunchUrl(url)) {
                      await launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                    widget.onContinue.call();
                    Navigator.pop(context, true);
                  },
                  child: Text(
                    buttonText,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              'Ad served by Voyant Ads · Voyant Networks',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
