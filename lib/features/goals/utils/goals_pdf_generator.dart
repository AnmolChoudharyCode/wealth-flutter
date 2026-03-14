import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/financial_profile.dart';
import '../models/goal.dart';
import '../models/year_projection.dart';
import 'wealth_calculator.dart';

abstract final class GoalsPdfGenerator {
  static Future<void> download({
    required FinancialProfile profile,
    required List<Goal> goals,
    required List<YearProjection> projections,
  }) async {
    // Load Unicode fonts (supports ₹ U+20B9 and — U+2014)
    final regular = await PdfGoogleFonts.notoSansRegular();
    final bold = await PdfGoogleFonts.notoSansBold();
    final g = _Gen(regular: regular, bold: bold);

    final doc = pw.Document(title: 'Wealth Goals Report', author: 'WealthPath');
    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    // Page 1: Summary + Goal Feasibility (Portrait)
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        footer: (ctx) => g.footer(ctx),
        build: (ctx) => [
          g.header(dateStr, profile.mobileNo),
          pw.SizedBox(height: 14),
          g.profileInfoBar(profile),
          pw.SizedBox(height: 14),
          g.metricsRow(profile, goals),
          if (goals.isNotEmpty) ...[
            pw.SizedBox(height: 20),
            g.sectionTitle('Goal Feasibility Analysis'),
            pw.SizedBox(height: 6),
            g.goalsTable(goals, profile),
          ],
        ],
      ),
    );

    // Page 2: Year-by-Year Projections (Landscape)
    if (projections.isNotEmpty) {
      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(28),
          footer: (ctx) => g.footer(ctx),
          build: (ctx) => [
            g.sectionTitle('Year-by-Year Wealth Projections'),
            pw.SizedBox(height: 6),
            g.projectionsTable(projections),
          ],
        ),
      );
    }

    final fileName =
        'Goals_Report_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.pdf';
    await Printing.layoutPdf(
      onLayout: (_) async => doc.save(),
      name: fileName,
    );
  }
}

// ─── Internal generator (holds loaded fonts) ──────────────────────────────────

class _Gen {
  final pw.Font regular;
  final pw.Font bold;

  const _Gen({required this.regular, required this.bold});

  pw.TextStyle ts({
    double size = 10,
    bool isBold = false,
    PdfColor? color,
  }) =>
      pw.TextStyle(
        font: isBold ? bold : regular,
        fontSize: size,
        color: color,
      );

  // ── Shared colors ──────────────────────────────────────────────────────────

  static final _purple = PdfColor.fromHex('612D53');
  static final _dark = PdfColor.fromHex('2C2C2C');
  static final _grey = PdfColor.fromHex('6B7280');
  static final _muted = PdfColor.fromHex('9CA3AF');
  static final _lightBg = PdfColor.fromHex('F3F4F4');
  static final _altRow = PdfColor.fromHex('F9FAFB');
  static final _border = PdfColor.fromHex('E5E7EB');

  // ── Widgets ────────────────────────────────────────────────────────────────

  pw.Widget header(String date, String mobile) => pw.Container(
        width: double.infinity,
        padding:
            const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: pw.BoxDecoration(
          color: _purple,
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Wealth Goals Report',
                    style: ts(size: 20, isBold: true, color: PdfColors.white)),
                pw.SizedBox(height: 3),
                pw.Text('Financial goal projections & feasibility analysis',
                    style: ts(size: 10, color: PdfColors.white)),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('Generated: $date',
                    style: ts(size: 9, color: PdfColors.white)),
                if (mobile.isNotEmpty)
                  pw.Text(mobile,
                      style: ts(size: 9, color: PdfColors.white)),
              ],
            ),
          ],
        ),
      );

  pw.Widget profileInfoBar(FinancialProfile profile) {
    final items = [
      ('Age', '${profile.currentAge.toInt()} yrs'),
      ('Current AUM', WealthCalculator.formatRupee(profile.currentAUM)),
      ('Monthly SIP', WealthCalculator.formatRupee(profile.monthlySIP)),
      ('CAGR', '${profile.expectedReturn}%'),
      ('SIP Increase', '${profile.annualSIPIncrease}% p.a.'),
      ('Inflation', '${profile.inflationRate}%'),
    ];
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: pw.BoxDecoration(
        color: _lightBg,
        border: pw.Border.all(color: _border),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: items
            .map((i) => pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(i.$1, style: ts(size: 8, color: _grey)),
                    pw.Text(i.$2,
                        style: ts(size: 10, isBold: true, color: _dark)),
                  ],
                ))
            .toList(),
      ),
    );
  }

  pw.Widget metricsRow(FinancialProfile profile, List<Goal> goals) {
    final projected = WealthCalculator.totalProjectedWealth(profile, goals);
    final totalGoals = goals.fold<double>(0, (s, g) => s + g.targetAmount);
    final items = [
      ('Current AUM', WealthCalculator.formatRupee(profile.currentAUM)),
      ('Projected Wealth', WealthCalculator.formatRupee(projected)),
      ('Monthly SIP', WealthCalculator.formatRupee(profile.monthlySIP)),
      ('Total Goals', WealthCalculator.formatRupee(totalGoals)),
    ];
    return pw.Row(
      children: items
          .map((item) => pw.Expanded(
                child: pw.Container(
                  margin: const pw.EdgeInsets.symmetric(horizontal: 4),
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: _lightBg,
                    borderRadius: pw.BorderRadius.circular(6),
                    border: pw.Border.all(color: _border),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(item.$1, style: ts(size: 8, color: _grey)),
                      pw.SizedBox(height: 3),
                      pw.Text(item.$2,
                          style: ts(size: 12, isBold: true, color: _dark)),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }

  pw.Widget goalsTable(List<Goal> goals, FinancialProfile profile) =>
      pw.TableHelper.fromTextArray(
        headers: [
          'Goal Name',
          'Category',
          'Year',
          'Target Amt',
          'Inflation Adj.',
          'Projected',
          'Funding %',
          'Status',
        ],
        columnWidths: {
          0: const pw.FlexColumnWidth(2.5),
          1: const pw.FlexColumnWidth(1.2),
          2: const pw.FlexColumnWidth(0.7),
          3: const pw.FlexColumnWidth(1.4),
          4: const pw.FlexColumnWidth(1.4),
          5: const pw.FlexColumnWidth(1.4),
          6: const pw.FlexColumnWidth(0.8),
          7: const pw.FlexColumnWidth(1.0),
        },
        headerStyle: ts(size: 8, isBold: true, color: PdfColors.white),
        headerDecoration: pw.BoxDecoration(color: _purple),
        rowDecoration: pw.BoxDecoration(color: _altRow),
        oddRowDecoration: pw.BoxDecoration(color: PdfColors.white),
        cellStyle: ts(size: 8, color: _dark),
        cellAlignments: {
          0: pw.Alignment.centerLeft,
          1: pw.Alignment.center,
          2: pw.Alignment.center,
          3: pw.Alignment.centerRight,
          4: pw.Alignment.centerRight,
          5: pw.Alignment.centerRight,
          6: pw.Alignment.center,
          7: pw.Alignment.center,
        },
        data: goals.map((g) {
          final m = WealthCalculator.calculateGoalMetrics(g, profile);
          return [
            g.name,
            g.category,
            g.targetYear.toString(),
            WealthCalculator.formatRupee(g.targetAmount),
            WealthCalculator.formatRupee(m.adjustedTarget),
            WealthCalculator.formatRupee(m.projectedValue),
            '${m.fundingRatio.round()}%',
            m.isOnTrack ? 'On Track' : 'Shortfall',
          ];
        }).toList(),
      );

  pw.Widget projectionsTable(List<YearProjection> projections) =>
      pw.TableHelper.fromTextArray(
        headers: [
          'Year',
          'Age',
          'Yr. Begin',
          'Monthly SIP',
          'Annual SIP',
          'Goal Amt',
          'Yr. End Corpus',
          'Goal',
        ],
        columnWidths: {
          0: const pw.FlexColumnWidth(0.7),
          1: const pw.FlexColumnWidth(0.6),
          2: const pw.FlexColumnWidth(1.4),
          3: const pw.FlexColumnWidth(1.4),
          4: const pw.FlexColumnWidth(1.4),
          5: const pw.FlexColumnWidth(1.4),
          6: const pw.FlexColumnWidth(1.4),
          7: const pw.FlexColumnWidth(2.1),
        },
        headerStyle: ts(size: 8, isBold: true, color: PdfColors.white),
        headerDecoration: pw.BoxDecoration(color: _purple),
        rowDecoration: pw.BoxDecoration(color: _altRow),
        oddRowDecoration: pw.BoxDecoration(color: PdfColors.white),
        cellStyle: ts(size: 8, color: _dark),
        cellAlignments: {
          0: pw.Alignment.center,
          1: pw.Alignment.center,
          2: pw.Alignment.centerRight,
          3: pw.Alignment.centerRight,
          4: pw.Alignment.centerRight,
          5: pw.Alignment.centerRight,
          6: pw.Alignment.centerRight,
          7: pw.Alignment.centerLeft,
        },
        data: projections.map((row) => [
              row.year.toString(),
              row.age.toString(),
              WealthCalculator.formatRupee(row.yearBeginningInvestment),
              WealthCalculator.formatRupee(row.monthlySIP),
              WealthCalculator.formatRupee(row.annualSIP),
              row.goalAmount > 0
                  ? WealthCalculator.formatRupee(row.goalAmount)
                  : '-',
              WealthCalculator.formatRupee(row.yearEndCorpus),
              row.goalNames.isNotEmpty ? row.goalNames.join(', ') : '-',
            ]).toList(),
      );

  pw.Widget sectionTitle(String title) => pw.Container(
        padding:
            const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: pw.BoxDecoration(
          color: _lightBg,
          border: pw.Border(
            left: pw.BorderSide(color: _purple, width: 4),
          ),
        ),
        child: pw.Text(title,
            style: ts(size: 13, isBold: true, color: _dark)),
      );

  pw.Widget footer(pw.Context ctx) => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('WealthPath — Confidential',
              style: ts(size: 8, color: _muted)),
          pw.Text('Page ${ctx.pageNumber} of ${ctx.pagesCount}',
              style: ts(size: 8, color: _muted)),
        ],
      );
}
