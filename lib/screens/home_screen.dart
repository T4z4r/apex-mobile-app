import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/properties_provider.dart';
import '../providers/units_provider.dart';
import '../providers/leases_provider.dart';
import '../providers/maintenance_provider.dart';
import '../theme/app_theme.dart';
import '../components/modern_components.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadData();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 750),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token != null) {
      await Future.wait([
        Provider.of<PropertiesProvider>(context, listen: false)
            .fetchProperties(token),
        Provider.of<UnitsProvider>(context, listen: false).fetchUnits(token),
        Provider.of<LeasesProvider>(context, listen: false).fetchLeases(token),
        Provider.of<MaintenanceProvider>(context, listen: false)
            .fetchMaintenanceRequests(token),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final properties = context.watch<PropertiesProvider>();
    final units = context.watch<UnitsProvider>();
    final leases = context.watch<LeasesProvider>();
    final maintenance = context.watch<MaintenanceProvider>();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: CustomScrollView(
        slivers: [
          // HERO HEADER
          SliverToBoxAdapter(child: _buildHeroHeader(auth)),
          SliverToBoxAdapter(child: const SizedBox(height: 20)),

          // STATS
          SliverToBoxAdapter(
            child: _buildNewStats(
              properties.properties.length,
              units.units.length,
              leases.leases.length,
              maintenance.maintenanceRequests.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),

          // ACTIVITY
          SliverToBoxAdapter(child: _buildNewActivity()),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),

          // QUICK ACTIONS
          SliverToBoxAdapter(child: _buildNewQuickActions()),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  //  HERO HEADER
  // ---------------------------------------------------------------------------

  Widget _buildHeroHeader(AuthProvider auth) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.7)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Good ${_timeOfDay()},",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  auth.userName ?? "User",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Avatar
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: const Icon(Icons.person, color: Colors.white, size: 30),
          ),
        ],
      ),
    );
  }

  String _timeOfDay() {
    final h = DateTime.now().hour;
    if (h < 12) return "morning";
    if (h < 17) return "afternoon";
    return "evening";
  }

  // ---------------------------------------------------------------------------
  //  NEW MODERN STATS SECTION
  // ---------------------------------------------------------------------------

  Widget _buildNewStats(
      int properties, int units, int leases, int maintenance) {
    final statItems = [
      ("Properties", properties, Icons.home, AppTheme.primaryColor),
      ("Units", units, Icons.apartment, AppTheme.secondaryColor),
      ("Leases", leases, Icons.description, AppTheme.accentColor),
      ("Maintenance", maintenance, Icons.build, AppTheme.errorColor),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text(
          "Dashboard Overview",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 18),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: statItems.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.15,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
          ),
          itemBuilder: (context, i) {
            final (label, value, icon, color) = statItems[i];

            return AnimatedScale(
              duration: Duration(milliseconds: 350 + (i * 80)),
              scale: 1,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon Box
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    const Spacer(),
                    Text(
                      value.toString(),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      label,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ]),
    );
  }

  // ---------------------------------------------------------------------------
  //  MODERN TIMELINE ACTIVITY SECTION
  // ---------------------------------------------------------------------------

  Widget _buildNewActivity() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recent Activity",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 18),
          ModernCard(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
            child: Column(
              children: [
                _timelineItem(Icons.home, AppTheme.primaryColor,
                    "New property added", "Sunset Apartments • 2h ago"),
                _divider(),
                _timelineItem(Icons.description, AppTheme.secondaryColor,
                    "Lease signed", "Unit 204 • Yesterday"),
                _divider(),
                _timelineItem(Icons.build, AppTheme.errorColor,
                    "Maintenance completed", "Unit 105 • 2 days ago"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _timelineItem(
      IconData icon, Color color, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  )),
              Text(subtitle,
                  style: TextStyle(
                      color: Colors.grey.shade600, fontSize: 12, height: 1.2)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _divider() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Divider(color: Colors.grey.shade200),
      );

  // ---------------------------------------------------------------------------
  //  NEW QUICK ACTION BUTTONS
  // ---------------------------------------------------------------------------

  Widget _buildNewQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Quick Actions",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                  child: _actionButton(
                      Icons.add_home, "Add Property", AppTheme.primaryColor)),
              const SizedBox(width: 14),
              Expanded(
                  child: _actionButton(
                      Icons.person_add, "Add Tenant", AppTheme.secondaryColor)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                  child: _actionButton(
                      Icons.description, "Create Lease", AppTheme.accentColor)),
              const SizedBox(width: 14),
              Expanded(
                  child: _actionButton(
                      Icons.build, "Report Issue", AppTheme.errorColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, Color color) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.75)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.25),
              blurRadius: 8,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 26),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
