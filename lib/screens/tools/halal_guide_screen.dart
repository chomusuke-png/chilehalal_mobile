import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HalalGuideScreen extends StatelessWidget {
  const HalalGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Guía Halal'),
        elevation: 0,
        foregroundColor: colorScheme.onSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '¿Qué significan nuestras etiquetas?',
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold, 
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'En ChileHalal clasificamos los productos en tres categorías principales según las leyes dietéticas islámicas. Esta guía te ayudará a tomar decisiones de consumo informadas.',
              style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.5),
            ),
            const SizedBox(height: 32),

            _buildInfoCard(
              context,
              title: 'Halal (حلال)',
              subtitle: 'Lícito o Permitido',
              description: 'El producto cumple con todos los requisitos halal. Es seguro y apto para el consumo. No contiene alcohol, cerdo, ni derivados prohibidos, y si contiene carne, el animal ha sido procesado bajo las normas halal.',
              icon: FontAwesomeIcons.check,
              color: Colors.green,
            ),
            const SizedBox(height: 16),

            _buildInfoCard(
              context,
              title: 'Haram (حرام)',
              subtitle: 'Ilícito o Prohibido',
              description: 'El producto contiene ingredientes estrictamente prohibidos por el Islam, tales como carne de cerdo, alcohol, sangre o carnes no procesadas según las normativas halal. Este producto NO debe ser consumido.',
              icon: FontAwesomeIcons.xmark,
              color: Colors.red,
            ),
            const SizedBox(height: 16),

            _buildInfoCard(
              context,
              title: 'Mashbooh (مشبوه)',
              subtitle: 'Dudoso o Sospechoso',
              description: 'El estado del producto no está claro. Puede contener aditivos (como gelatinas, emulsionantes E-XXX o enzimas) cuyo origen animal o vegetal no está especificado por el fabricante. Se recomienda evitarlo hasta tener certeza.',
              icon: FontAwesomeIcons.exclamation,
              color: Colors.orange,
            ),
            
            const SizedBox(height: 40),
            
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  FaIcon(FontAwesomeIcons.certificate, size: 40, color: colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Certificación ChileHalal',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.primary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nuestro equipo trabaja constantemente auditando y verificando empresas y productos en Chile para garantizar la seguridad alimentaria de nuestra comunidad y expandir el alcance comercial de los productos chilenos.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, height: 1.5, color: Colors.grey[800]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: FaIcon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(),
          ),
          Text(
            description,
            style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}