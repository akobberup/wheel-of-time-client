// =============================================================================
// Legal Info Screen
// Viser juridisk information (privacy policy, sikkerhed, support)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Type af juridisk information der vises
enum LegalInfoType {
  privacyPolicy,
  security,
  support,
}

/// Skærm til visning af juridisk information og support.
///
/// Viser indhold baseret på [LegalInfoType] med pæn formatering.
class LegalInfoScreen extends StatelessWidget {
  final LegalInfoType type;

  const LegalInfoScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final seedColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _LegalAppBar(
            title: _getTitle(context),
            seedColor: seedColor,
            isDark: isDark,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                _buildContent(context, isDark, seedColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTitle(BuildContext context) {
    switch (type) {
      case LegalInfoType.privacyPolicy:
        return 'Privatlivspolitik';
      case LegalInfoType.security:
        return 'Sikkerhed';
      case LegalInfoType.support:
        return 'Support';
    }
  }

  List<Widget> _buildContent(BuildContext context, bool isDark, Color seedColor) {
    switch (type) {
      case LegalInfoType.privacyPolicy:
        return _buildPrivacyPolicy(context, isDark, seedColor);
      case LegalInfoType.security:
        return _buildSecurity(context, isDark, seedColor);
      case LegalInfoType.support:
        return _buildSupport(context, isDark, seedColor);
    }
  }

  List<Widget> _buildPrivacyPolicy(BuildContext context, bool isDark, Color seedColor) {
    return [
      _LastUpdated(date: '28. december 2024', isDark: isDark),
      const SizedBox(height: 24),
      _SectionTitle(title: 'Introduktion', isDark: isDark),
      _Paragraph(
        text: 'Denne privatlivspolitik beskriver, hvordan Årshjulet ("vi", "os" eller "vores") indsamler, bruger og deler information, når du bruger vores mobilapplikation og webtjeneste (samlet kaldet "Tjenesten").',
        isDark: isDark,
      ),
      _Paragraph(
        text: 'Ved at bruge Tjenesten accepterer du indsamling og brug af information i overensstemmelse med denne politik.',
        isDark: isDark,
      ),
      const SizedBox(height: 20),
      _SectionTitle(title: 'Information vi indsamler', isDark: isDark),
      _SubsectionTitle(title: 'Information du giver os', isDark: isDark, seedColor: seedColor),
      _BulletPoint(text: 'Kontoinformation: Navn, email og adgangskode (krypteret)', isDark: isDark),
      _BulletPoint(text: 'Opgavedata: Opgavelister, opgaver, tidsplaner og fuldførelser', isDark: isDark),
      _BulletPoint(text: 'Profilinformation: Valgfrit profilbillede', isDark: isDark),
      const SizedBox(height: 12),
      _SubsectionTitle(title: 'Automatisk indsamlet information', isDark: isDark, seedColor: seedColor),
      _BulletPoint(text: 'Brugsdata: Enhedstype, browsertype og adgangstider', isDark: isDark),
      _BulletPoint(text: 'Enhedsinformation: Device-identifikatorer til notifikationer', isDark: isDark),
      const SizedBox(height: 20),
      _SectionTitle(title: 'Hvordan vi bruger dine data', isDark: isDark),
      _BulletPoint(text: 'Levere, vedligeholde og forbedre Tjenesten', isDark: isDark),
      _BulletPoint(text: 'Sende notifikationer om dine opgaver', isDark: isDark),
      _BulletPoint(text: 'Besvare dine spørgsmål og anmodninger', isDark: isDark),
      _BulletPoint(text: 'Analysere trends og brugsmønstre', isDark: isDark),
      const SizedBox(height: 20),
      _SectionTitle(title: 'Datasikkerhed', isDark: isDark),
      _Paragraph(
        text: 'Dine data opbevares på sikre servere. Vi implementerer passende tekniske og organisatoriske foranstaltninger for at beskytte dine persondata mod uautoriseret adgang, ændring eller sletning.',
        isDark: isDark,
      ),
      _Paragraph(
        text: 'Dine data kan opbevares og behandles i EU eller andre lande, hvor vores tjenesteudbydere opererer.',
        isDark: isDark,
      ),
      const SizedBox(height: 20),
      _SectionTitle(title: 'Dine rettigheder (GDPR)', isDark: isDark),
      _BulletPoint(text: 'Indsigt: Anmod om en kopi af dine persondata', isDark: isDark),
      _BulletPoint(text: 'Rettelse: Anmod om korrektion af unøjagtige data', isDark: isDark),
      _BulletPoint(text: 'Sletning: Anmod om sletning af dine persondata', isDark: isDark),
      _BulletPoint(text: 'Dataportabilitet: Få en kopi i maskinlæsbart format', isDark: isDark),
      _BulletPoint(text: 'Indsigelse: Gør indsigelse mod behandling af dine data', isDark: isDark),
      const SizedBox(height: 20),
      _SectionTitle(title: 'Kontakt os', isDark: isDark),
      _Paragraph(
        text: 'Har du spørgsmål til denne privatlivspolitik eller vil du udøve dine rettigheder, kontakt os på:',
        isDark: isDark,
      ),
      const SizedBox(height: 8),
      _EmailLink(email: 'privacy@t16software.dev', isDark: isDark, seedColor: seedColor),
      const SizedBox(height: 32),
      _Footnote(
        text: 'Denne privatlivspolitik er underlagt dansk lovgivning og EU-regler.',
        isDark: isDark,
      ),
    ];
  }

  List<Widget> _buildSecurity(BuildContext context, bool isDark, Color seedColor) {
    return [
      _SectionTitle(title: 'Rapportering af sikkerhedsproblemer', isDark: isDark),
      _Paragraph(
        text: 'Hvis du finder en sikkerhedssårbarhed, bedes du ikke oprette et offentligt issue.',
        isDark: isDark,
      ),
      _Paragraph(
        text: 'Send i stedet en email til:',
        isDark: isDark,
      ),
      const SizedBox(height: 8),
      _EmailLink(email: 'privacy@t16software.dev', isDark: isDark, seedColor: seedColor),
      _Paragraph(
        text: 'Vi vil svare inden for 48 timer og arbejde sammen med dig om at løse problemet.',
        isDark: isDark,
      ),
      const SizedBox(height: 20),
      _SectionTitle(title: 'Ansvarlig offentliggørelse', isDark: isDark),
      _Paragraph(
        text: 'Vi beder om at du:',
        isDark: isDark,
      ),
      _BulletPoint(
        text: 'Giver os rimelig tid til at løse problemet før offentliggørelse',
        isDark: isDark,
      ),
      _BulletPoint(
        text: 'Ikke udnytter sårbarheden til at tilgå data ud over hvad der er nødvendigt for at demonstrere problemet',
        isDark: isDark,
      ),
    ];
  }

  List<Widget> _buildSupport(BuildContext context, bool isDark, Color seedColor) {
    return [
      _SectionTitle(title: 'Hjælp og support', isDark: isDark),
      _Paragraph(
        text: 'Vi hjælper gerne med spørgsmål og problemer.',
        isDark: isDark,
      ),
      const SizedBox(height: 20),
      _SupportCard(
        icon: Icons.bug_report_outlined,
        title: 'Rapporter en fejl',
        description: 'Fandt du en fejl i appen? Opret en fejlrapport på GitHub.',
        buttonText: 'Opret fejlrapport',
        url: 'https://github.com/akobberup/wheel-of-time-client/issues/new?template=bug_report.yml',
        isDark: isDark,
        seedColor: seedColor,
      ),
      const SizedBox(height: 12),
      _SupportCard(
        icon: Icons.lightbulb_outline,
        title: 'Foreslå en funktion',
        description: 'Har du en idé til at gøre appen bedre?',
        buttonText: 'Opret forslag',
        url: 'https://github.com/akobberup/wheel-of-time-client/issues/new?template=feature_request.yml',
        isDark: isDark,
        seedColor: seedColor,
      ),
      const SizedBox(height: 12),
      _SupportCard(
        icon: Icons.email_outlined,
        title: 'Kontakt os',
        description: 'For andre henvendelser eller sikkerhedsproblemer.',
        buttonText: 'Send email',
        url: 'mailto:privacy@t16software.dev',
        isDark: isDark,
        seedColor: seedColor,
      ),
      const SizedBox(height: 24),
      _SectionTitle(title: 'Før du kontakter os', isDark: isDark),
      _BulletPoint(
        text: 'Søg i eksisterende issues på GitHub for at se om dit problem allerede er rapporteret',
        isDark: isDark,
      ),
      _BulletPoint(
        text: 'Opdater appen til nyeste version og se om problemet stadig eksisterer',
        isDark: isDark,
      ),
    ];
  }
}

/// App bar til legal screens
class _LegalAppBar extends StatelessWidget {
  final String title;
  final Color seedColor;
  final bool isDark;

  const _LegalAppBar({
    required this.title,
    required this.seedColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);

    return SliverAppBar(
      expandedHeight: 100,
      floating: false,
      pinned: true,
      backgroundColor: isDark ? const Color(0xFF121214) : const Color(0xFFFAFAF8),
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: textColor),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 52, bottom: 16),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

/// Sidst opdateret tekst
class _LastUpdated extends StatelessWidget {
  final String date;
  final bool isDark;

  const _LastUpdated({required this.date, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Sidst opdateret: $date',
      style: TextStyle(
        fontSize: 13,
        fontStyle: FontStyle.italic,
        color: isDark ? Colors.white38 : Colors.black38,
      ),
    );
  }
}

/// Sektions-overskrift
class _SectionTitle extends StatelessWidget {
  final String title;
  final bool isDark;

  const _SectionTitle({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
        ),
      ),
    );
  }
}

/// Undersektion-overskrift
class _SubsectionTitle extends StatelessWidget {
  final String title;
  final bool isDark;
  final Color seedColor;

  const _SubsectionTitle({
    required this.title,
    required this.isDark,
    required this.seedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: seedColor,
        ),
      ),
    );
  }
}

/// Normal paragraf
class _Paragraph extends StatelessWidget {
  final String text;
  final bool isDark;

  const _Paragraph({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          height: 1.5,
          color: isDark ? Colors.white70 : Colors.black87,
        ),
      ),
    );
  }
}

/// Bullet point
class _BulletPoint extends StatelessWidget {
  final String text;
  final bool isDark;

  const _BulletPoint({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•  ',
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                height: 1.4,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Email link med klikbar handling
class _EmailLink extends StatelessWidget {
  final String email;
  final bool isDark;
  final Color seedColor;

  const _EmailLink({
    required this.email,
    required this.isDark,
    required this.seedColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _launchEmail(email),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: seedColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: seedColor.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.email_outlined, size: 20, color: seedColor),
            const SizedBox(width: 8),
            Text(
              email,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: seedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

/// Fodnote
class _Footnote extends StatelessWidget {
  final String text;
  final bool isDark;

  const _Footnote({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontStyle: FontStyle.italic,
          color: isDark ? Colors.white54 : Colors.black54,
        ),
      ),
    );
  }
}

/// Support-kort med handling
class _SupportCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String buttonText;
  final String url;
  final bool isDark;
  final Color seedColor;

  const _SupportCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.url,
    required this.isDark,
    required this.seedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: seedColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: seedColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _launchUrl(url),
              style: ElevatedButton.styleFrom(
                backgroundColor: seedColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(buttonText),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
