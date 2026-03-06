import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Acerca de ChileHalal'),
        elevation: 0,
        foregroundColor: colorScheme.onSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // LOGO Y ESLOGAN
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))
                  ],
                ),
                child: Image.asset('assets/images/chilehalal-logo.png', height: 100),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Líderes en Certificación Halal en Latinoamérica',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colorScheme.primary),
            ),
            const SizedBox(height: 32),

            // SECCIONES DE INFORMACIÓN
            _buildInfoSection(
              context,
              icon: FontAwesomeIcons.clockRotateLeft,
              title: 'Nuestra Historia',
              description: 'Fundada en 2010 por científicos y expertos en procesos halal. Nuestro equipo suma más de 37 años de experiencia global certificando la calidad ética y religiosa.',
            ),
            
            _buildInfoSection(
              context,
              icon: FontAwesomeIcons.earthAmericas,
              title: 'Pasaporte Global',
              description: 'Acreditados por los mercados más estrictos: BPJPH (Indonesia) y MOIAT (Emiratos Árabes Unidos). Abrimos las puertas a más de 100 países.',
            ),

            _buildInfoSection(
              context,
              icon: FontAwesomeIcons.shieldHalved,
              title: 'Alcance Integral',
              description: 'Bajo la Norma N.H.L.A., auditamos toda la cadena de valor: alimentos, empaques, productos químicos y farmacéuticos.',
            ),

            // TARJETA DE IMPACTO DESTACADA
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.primary.withValues(alpha: 0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: colorScheme.primary.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      FaIcon(FontAwesomeIcons.chartLine, color: Colors.white, size: 24),
                      SizedBox(width: 12),
                      Text('Impacto Global (2023)', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildStatRow('+75.000', 'Ton. de carne exportada'),
                  const SizedBox(height: 10),
                  _buildStatRow('+850.000', 'Ton. de alimentos certificados'),
                  const SizedBox(height: 10),
                  _buildStatRow('+100', 'Países receptores de nuestros productos'),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            const Text(
              '© ${2024} Centro de Certificación Halal de Chile.\nTodos los derechos reservados.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, {required IconData icon, required String title, required String description}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: FaIcon(icon, color: colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(description, style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String number, String label) {
    return Row(
      children: [
        Text(number, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14))),
      ],
    );
  }
}