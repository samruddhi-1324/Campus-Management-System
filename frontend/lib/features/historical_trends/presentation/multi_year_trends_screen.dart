import 'package:flutter/material.dart';

class MultiYearTrendsScreen extends StatelessWidget {
  const MultiYearTrendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Longitudinal & Multi-Year Pattern Mining'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPI Summary Cards
            Row(
              children: [
                _buildKpiCard(
                  context,
                  title: 'Historical Records',
                  value: '3,420',
                  subtitle: '2023 - 2026',
                  color: Colors.indigo,
                  icon: Icons.history,
                ),
                const SizedBox(width: 12),
                _buildKpiCard(
                  context,
                  title: 'Detected Spikes',
                  value: '8 Peaks',
                  subtitle: 'Recurring Cyclical',
                  color: Colors.deepOrange,
                  icon: Icons.trending_up,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Seasonal Patterns Card
            Text(
              'Identified Seasonal Failure Patterns (FR-3.5)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            _buildPatternCard(
              title: 'Summer Heatwave HVAC Breakdown Spike',
              description: 'HVAC & AC complaints increase by 48% annually during Q2 (May - July).',
              impactBadge: 'High Severity Spike',
              color: Colors.red,
            ),
            const SizedBox(height: 8),
            _buildPatternCard(
              title: 'Semester Start Wi-Fi Backbone Surge',
              description: 'Campus Wi-Fi connectivity tickets surge by 62% during Fall onboarding (August/September).',
              impactBadge: 'Infrastructure Load',
              color: Colors.blue,
            ),
            const SizedBox(height: 8),
            _buildPatternCard(
              title: 'Exam Season AV / Projector Faults',
              description: 'Audio-Visual issues peak sharply in November and April exam periods.',
              impactBadge: 'Academic Risk',
              color: Colors.amber.shade800,
            ),

            const SizedBox(height: 24),

            // Preventive Strategic Recommendations
            Text(
              'Long-Term Capital & Maintenance Recommendations',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(borderRadius: const BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildRecommendationRow(
                      icon: Icons.ac_unit,
                      text: 'Schedule comprehensive chiller servicing in April prior to summer heatwave.',
                    ),
                    const Divider(height: 20),
                    _buildRecommendationRow(
                      icon: Icons.wifi_tethering,
                      text: 'Deploy high-capacity access points in hostel blocks before Fall onboarding.',
                    ),
                    const Divider(height: 20),
                    _buildRecommendationRow(
                      icon: Icons.videocam,
                      text: 'Stock hot-standby projector kits in Main Auditorium before final exam weeks.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: const BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
                Icon(icon, color: color, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternCard({
    required String title,
    required String description,
    required String impactBadge,
    required Color color,
  }) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: const BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: const BorderRadius.circular(6),
                  ),
                  child: Text(
                    impactBadge,
                    style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(description, style: const TextStyle(fontSize: 12, color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationRow({required IconData icon, required String text}) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.blue.shade50,
          child: Icon(icon, size: 16, color: Colors.blue.shade700),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 13, height: 1.3)),
        ),
      ],
    );
  }
}
