import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';
import '../theme.dart';
import '../widgets/vihtal_app_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _pageBg = Color(0xFFF8F3F4);
  static const _title = Color(0xFF221619);
  static const _body = Color(0xFF4A3438);
  static const _cardSoft = Color(0xFFF3E8EA);
  static const _accent = Color(0xFFD5001A);
  static const _darkCard = Color(0xFF3B272B);

  Widget _profileHero() {
    return Column(
      children: [
        Container(
          width: 118,
          height: 118,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFF5D2CF),
            border: Border.all(color: const Color(0xFFF0C2BE), width: 6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const CircleAvatar(
            radius: 46,
            backgroundColor: Color(0xFFEAB7AE),
            child: Icon(Icons.person_rounded, size: 54, color: Color(0xFF4A3438)),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Pedro Martinez',
          style: TextStyle(
            color: _title,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'pedromartinez01@gmail.com',
          style: TextStyle(color: _body, fontSize: 14),
        ),
      ],
    );
  }

  Widget _personalInfoTile(BuildContext context) {
    return InkWell(
      onTap: () => context.push(AppRoutes.editProfile),
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _cardSoft,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFEBD7DA)),
        ),
        child: const Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Color(0xFFF0CDD1),
              child: Icon(Icons.person_outline_rounded, color: _accent),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Text(
                'Informacion Personal',
                style: TextStyle(color: _title, fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Color(0xFF8A7478), size: 30),
          ],
        ),
      ),
    );
  }

  Widget _badgeItem({
    required String name,
    required IconData icon,
    required bool unlocked,
  }) {
    final circle = Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: unlocked ? _accent : const Color(0xFFF1ECEE),
        border: Border.all(
          color: unlocked ? const Color(0xFFF1CFD3) : const Color(0xFFD3C7CA),
          width: 2,
        ),
      ),
      child: Icon(
        icon,
        color: unlocked ? Colors.white : const Color(0xFFB8ADB0),
        size: 34,
      ),
    );

    return SizedBox(
      width: 98,
      child: Column(
        children: [
          circle,
          const SizedBox(height: 8),
          Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: unlocked ? _title : const Color(0xFFC0B5B8),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _challengeCard({
    required bool active,
    required String title,
    required String subtitle,
    String? progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: active ? _cardSoft : const Color(0xFFF2EDEE),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: active ? _accent : const Color(0xFFE8DADD),
            child: Icon(
              active ? Icons.link_rounded : Icons.lock_outline_rounded,
              color: active ? Colors.white : const Color(0xFFAF9FA3),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: active ? _title : const Color(0xFF9E8D91),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (progress != null)
                      Text(
                        progress,
                        style: const TextStyle(
                          color: _accent,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: active ? _body : const Color(0xFFA49397),
                    fontSize: 14,
                  ),
                ),
                if (active) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: 5 / 7,
                      minHeight: 7,
                      backgroundColor: const Color(0xFFEAC7CC),
                      valueColor: const AlwaysStoppedAnimation<Color>(_accent),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      appBar: VihtalAppBar(
        backgroundColor: _pageBg,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded, color: _body),
            tooltip: 'Notificaciones',
          ),
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFF2F1F22),
              child: Icon(Icons.person, color: Colors.white),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 18),
              Center(child: _profileHero()),
              const SizedBox(height: 24),
              _personalInfoTile(context),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Text(
                    'Coleccion de Insignias',
                    style: TextStyle(
                      color: _title,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2CDD2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      '6/12',
                      style: TextStyle(color: _accent, fontSize: 14, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 12,
                runSpacing: 20,
                children: [
                  _badgeItem(name: 'CORAZON DE\nHIERRO', icon: Icons.favorite_border_rounded, unlocked: true),
                  _badgeItem(name: 'METAMORFOSIS', icon: Icons.eco_outlined, unlocked: true),
                  _badgeItem(name: 'PUNTUALIDAD', icon: Icons.verified_outlined, unlocked: true),
                  _badgeItem(name: 'INVENCIBLE', icon: Icons.shield_outlined, unlocked: false),
                  _badgeItem(name: 'GUARDIAN', icon: Icons.self_improvement_outlined, unlocked: false),
                  _badgeItem(name: 'ZEN MASTER', icon: Icons.spa_outlined, unlocked: false),
                ],
              ),
              const SizedBox(height: 26),
              const Text(
                'Desafios Semanales',
                style: TextStyle(color: _title, fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              _challengeCard(
                active: true,
                title: 'Sin omisiones',
                subtitle: 'Toma tu medicacion a tiempo durante 7 dias.',
                progress: '5/7',
              ),
              const SizedBox(height: 12),
              _challengeCard(
                active: false,
                title: 'Paseo Diario',
                subtitle: 'Camina 20 min al dia por 5 dias seguidos.',
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                decoration: BoxDecoration(
                  color: _darkCard,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.20),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome_rounded, color: Color(0xFFF0C5C8), size: 18),
                        SizedBox(width: 8),
                        Text(
                          'MOTIVACION',
                          style: TextStyle(
                            color: Color(0xFFF0C5C8),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      '"Cada pequeno paso cuenta para\ntu bienestar total."',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Sigue asi, estas a 3 dias de tu proximo nivel.',
                      style: TextStyle(color: Color(0xFFF5DEE0), fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
