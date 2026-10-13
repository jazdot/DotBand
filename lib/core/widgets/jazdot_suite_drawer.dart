import 'package:flutter/material.dart';
import '../theme/obsidian_theme.dart';
import 'dot_band_animated_logo.dart';

/**
 * Official Jazdot Enterprises Mobile Network Suite Navigation Drawer.
 * Provides seamless parity and cross-launch navigation between:
 * - DotBand (Wi-Fi 6E/7 Tri-Band Spectrum Analyzer)
 * - DotSignal (Cellular & 5G Baseband Telemetry)
 * - DotLan (Local Subnet & IoT Radar)
 * Includes the B2B bridge for Jazdot dotedge / DotNetwork industrial deployments.
 */
class JazdotSuiteDrawer extends StatelessWidget {
  const JazdotSuiteDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: ObsidianTheme.bgElevated,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Corporate Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const DotBandAnimatedLogo(
                    size: 36,
                    variant: LogoVariant.compact,
                    showWordmark: false,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Text(
                            'JAZDOT',
                            style: TextStyle(
                              color: Color(0xFFFAFAFA),
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              fontFamily: 'monospace',
                            ),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'ENTERPRISES',
                            style: TextStyle(
                              color: Color(0xFFD97706),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Mobile Network Suite v1.0',
                        style: TextStyle(
                          color: ObsidianTheme.textTertiary,
                          fontSize: 10,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Ecosystem Apps
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 16, bottom: 8),
              child: Text(
                'WIRELESS RECONNAISSANCE SUITE',
                style: TextStyle(
                  color: ObsidianTheme.textTertiary,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'monospace',
                ),
              ),
            ),

            _buildAppTile(
              context,
              title: 'DotBand',
              subtitle: 'Wi-Fi 6E/7 Tri-Band Spectrum Analyzer',
              isActive: true,
              icon: Icons.wifi,
              badgeColor: const Color(0xFFA855F7),
            ),
            _buildAppTile(
              context,
              title: 'DotSignal',
              subtitle: 'Cellular 2G/3G/4G/5G Baseband Telemetry',
              isActive: false,
              icon: Icons.cell_tower,
              badgeColor: const Color(0xFF3B82F6),
            ),
            _buildAppTile(
              context,
              title: 'DotLan',
              subtitle: 'Local Subnet & IoT Reconnaissance',
              isActive: false,
              icon: Icons.lan,
              badgeColor: const Color(0xFF10B981),
            ),

            const Spacer(),

            // Enterprise Private Wireless Bridge
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ObsidianTheme.bgSurface,
                borderRadius: BorderRadius.circular(ObsidianTheme.radiusCard),
                border: Border.all(color: ObsidianTheme.borderGold),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.business_center, color: Color(0xFFFBBF24), size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'JAZDOT INDUSTRIAL',
                        style: TextStyle(
                          color: ObsidianTheme.accentGold,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Deploying factory Wi-Fi 6E/7 or Private 5G? Coexistence site survey consulting powered by Jazdot dotedge.',
                    style: TextStyle(
                      color: ObsidianTheme.textSecondary,
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Jazdot Industrial Inquiry opened (jazdot.com/industrial)')),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Explore Solutions',
                          style: TextStyle(
                            color: ObsidianTheme.accentGold,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward, color: ObsidianTheme.accentGold, size: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool isActive,
    required IconData icon,
    required Color badgeColor,
  }) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: badgeColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(ObsidianTheme.radiusSm),
          border: Border.all(color: isActive ? badgeColor : Colors.transparent),
        ),
        child: Icon(icon, color: badgeColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isActive ? ObsidianTheme.accentGold : ObsidianTheme.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w800,
          fontFamily: 'monospace',
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: ObsidianTheme.textTertiary, fontSize: 10),
      ),
      trailing: isActive
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: ObsidianTheme.accentGold.withOpacity(0.2),
                borderRadius: BorderRadius.circular(ObsidianTheme.radiusSm),
              ),
              child: Text(
                'ACTIVE',
                style: TextStyle(color: ObsidianTheme.accentGold, fontSize: 8, fontWeight: FontWeight.w900),
              ),
            )
          : null,
      onTap: () {
        Navigator.of(context).pop();
      },
    );
  }
}
