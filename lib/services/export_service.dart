import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:autidetect/models/assessment_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';

class ExportService {
  // Generate PDF from assessment data
  static Future<Uint8List> generateAssessmentPdf(Assessment assessment) async {
    // Create PDF document
    final pdf = pw.Document();
    
    // Format date
    final dateFormat = DateFormat('MMMM d, yyyy');
    final dateString = assessment.completedAt != null 
        ? dateFormat.format(assessment.completedAt!) 
        : dateFormat.format(DateTime.now());
    
    // Get likelihood text and color
    final String likelihoodText = _getLikelihoodText(assessment);
    final PdfColor color = _getLikelihoodColor(assessment);
    
    // Add pages to the document
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(assessment, dateString),
          pw.SizedBox(height: 20),
          _buildResultSection(assessment, likelihoodText, color),
          pw.SizedBox(height: 20),
          _buildDetailedResults(assessment),
          pw.SizedBox(height: 20),
          _buildRecommendations(assessment),
          pw.SizedBox(height: 20),
          _buildDisclaimer(),
        ],
      ),
    );

    return pdf.save();
  }
  
  // Save PDF to a file
  static Future<String> savePdfFile(Uint8List pdfBytes, String fileName) async {
    try {
      final dir = await _getExportDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(pdfBytes);
      return file.path;
    } catch (e) {
      print('Error saving PDF: $e');
      return '';
    }
  }
  
  // Get directory for exporting files
  static Future<Directory> _getExportDirectory() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final exportDir = Directory('${directory.path}/autidetect_reports');
      
      if (!(await exportDir.exists())) {
        await exportDir.create(recursive: true);
      }
      
      return exportDir;
    } catch (e) {
      print('Error accessing documents directory: $e');
      try {
        // Fallback to temporary directory if documents directory is not available
        final tempDir = await getTemporaryDirectory();
        final exportDir = Directory('${tempDir.path}/autidetect_reports');
        
        if (!(await exportDir.exists())) {
          await exportDir.create(recursive: true);
        }
        
        return exportDir;
      } catch (e2) {
        // If all else fails, use application support directory
        print('Error accessing temporary directory: $e2');
        final appDir = await getApplicationSupportDirectory();
        final exportDir = Directory('${appDir.path}/autidetect_reports');
        
        if (!(await exportDir.exists())) {
          await exportDir.create(recursive: true);
        }
        
        return exportDir;
      }
    }
  }
  
  // Share PDF file
  static Future<void> sharePdf(String filePath, String subject) async {
    try {
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: subject,
        text: 'AutiDetect Assessment Report',
      );
    } catch (e) {
      print('Error sharing PDF: $e');
    }
  }
  
  // Open PDF file
  static Future<void> openPdf(String filePath) async {
    try {
      final Uri uri = Uri.file(filePath);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        print('Could not launch $uri');
      }
    } catch (e) {
      print('Error opening PDF: $e');
    }
  }
  
  // Helper methods for PDF generation
  static pw.Widget _buildHeader(Assessment assessment, String dateString) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'AutiDetect Assessment Report',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue50,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
              ),
              child: pw.Text(
                dateString,
                style: const pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.blue900,
                ),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 20),
        pw.Container(
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Assessment Information',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      'Assessment Type:',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      assessment.type == AssessmentType.toddler
                          ? 'Toddler Assessment (18-36 months)'
                          : 'Child Assessment (3-12 years)',
                      style: const pw.TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      'Assessment ID:',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      assessment.id,
                      style: const pw.TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  static pw.Widget _buildResultSection(
    Assessment assessment,
    String likelihoodText,
    PdfColor color,
  ) {
    final int percentage = assessment.qualityScore ?? 0;
    
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Assessment Results',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 15),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Risk Level:',
                    style: const pw.TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    likelihoodText,
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              pw.Container(
                width: 70,
                height: 70,
                decoration: pw.BoxDecoration(
                  color: color.shade(50),
                  shape: pw.BoxShape.circle,
                  border: pw.Border.all(
                    color: color,
                    width: 2,
                  ),
                ),
                alignment: pw.Alignment.center,
                child: pw.Text(
                  '$percentage%',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 15),
          pw.Container(
            width: double.infinity,
            height: 10,
            decoration: pw.BoxDecoration(
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
              color: PdfColors.grey200,
            ),
            child: pw.ClipRRect(
              horizontalRadius: 5,
              verticalRadius: 5,
              child: pw.Container(
                width: percentage * 5.15,
                decoration: pw.BoxDecoration(
                  color: color,
                ),
              ),
            ),
          ),
          pw.SizedBox(height: 15),
          pw.Text(
            _getLikelihoodDescription(assessment),
            style: const pw.TextStyle(
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
  
  static pw.Widget _buildDetailedResults(Assessment assessment) {
    final responses = assessment.questionnaireResponses ?? [];
    if (responses.isEmpty) return pw.SizedBox.shrink();

    // Group responses by category
    final Map<String, List<Map<String, dynamic>>> categorizedResponses = {};
    for (var response in responses) {
      final category = response['category'] as String? ?? 'General';
      if (!categorizedResponses.containsKey(category)) {
        categorizedResponses[category] = [];
      }
      categorizedResponses[category]!.add(response);
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Detailed Results',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.SizedBox(height: 15),
        ...categorizedResponses.entries.map((entry) {
          final category = entry.key;
          final categoryResponses = entry.value;
          
          // Calculate category score
          int categoryScore = 0;
          int totalQuestions = categoryResponses.length;
          for (var response in categoryResponses) {
            final score = response['score'] as int? ?? 0;
            categoryScore += score;
          }
          final categoryPercentage = totalQuestions > 0 
              ? (categoryScore / (totalQuestions * 3) * 100).round() 
              : 0;

          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 15),
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        category,
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: pw.BoxDecoration(
                        color: _getCategoryColor(categoryPercentage).shade(50),
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(15)),
                      ),
                      child: pw.Text(
                        '$categoryPercentage%',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: _getCategoryColor(categoryPercentage),
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Container(
                  width: double.infinity,
                  height: 8,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey200,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                  ),
                  child: pw.ClipRRect(
                    horizontalRadius: 4,
                    verticalRadius: 4,
                    child: pw.Container(
                      width: 500,
                      decoration: pw.BoxDecoration(
                        color: _getCategoryColor(categoryPercentage),
                      ),
                    ),
                  ),
                ),
                pw.SizedBox(height: 15),
                ...categoryResponses.map((response) {
                  final question = response['question'] as String? ?? '';
                  final answer = response['answer'] as String? ?? '';
                  final score = response['score'] as int? ?? 0;

                  return pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 10),
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey50,
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          question,
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 5),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              'Response: $answer',
                              style: const pw.TextStyle(
                                fontSize: 10,
                                color: PdfColors.grey700,
                              ),
                            ),
                            pw.Container(
                              padding: const pw.EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: pw.BoxDecoration(
                                color: _getCategoryColor(score).shade(50),
                                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                              ),
                              child: pw.Text(
                                'Score: $score',
                                style: pw.TextStyle(
                                  fontSize: 9,
                                  fontWeight: pw.FontWeight.bold,
                                  color: _getCategoryColor(score),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
  
  static pw.Widget _buildRecommendations(Assessment assessment) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Recommendations',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            _getRecommendations(assessment),
            style: const pw.TextStyle(
              fontSize: 11,
              color: PdfColors.grey800,
            ),
          ),
        ],
      ),
    );
  }
  
  static String _getRecommendations(Assessment assessment) {
    switch (assessment.likelihood) {
      case AutismLikelihood.low:
        return 'Based on the assessment results, there is a low likelihood of autism-related behaviors. However, it is recommended to:\n\n'
            '• Continue monitoring your child\'s development\n'
            '• Keep track of any changes in behavior or development\n'
            '• Schedule regular check-ups with your pediatrician\n'
            '• Share these results with your healthcare provider during your next visit';
      
      case AutismLikelihood.moderate:
        return 'Based on the assessment results, there is a moderate likelihood of autism-related behaviors. We recommend:\n\n'
            '• Schedule an appointment with a developmental specialist\n'
            '• Share these results with your pediatrician\n'
            '• Consider early intervention services\n'
            '• Keep detailed records of your child\'s behaviors and development\n'
            '• Learn more about autism spectrum disorder and available resources';
      
      case AutismLikelihood.high:
        return 'Based on the assessment results, there is a high likelihood of autism-related behaviors. We strongly recommend:\n\n'
            '• Schedule an immediate appointment with a developmental specialist\n'
            '• Share these results with your pediatrician\n'
            '• Begin early intervention services as soon as possible\n'
            '• Document all behaviors and developmental milestones\n'
            '• Connect with autism support groups and resources\n'
            '• Consider a comprehensive developmental evaluation';
      
      case AutismLikelihood.unknown:
      default:
        return 'The assessment results were inconclusive. We recommend:\n\n'
            '• Schedule a follow-up assessment\n'
            '• Consult with your pediatrician\n'
            '• Monitor your child\'s development closely\n'
            '• Consider a comprehensive developmental evaluation';
    }
  }
  
  static PdfColor _getCategoryColor(int percentage) {
    if (percentage >= 70) return PdfColors.red;
    if (percentage >= 40) return PdfColors.orange;
    return PdfColors.green;
  }
  
  static pw.Widget _buildDisclaimer() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Text(
        'DISCLAIMER: This assessment is not a diagnostic tool. It is designed to help identify potential signs of autism spectrum disorder that may warrant further evaluation by a qualified healthcare professional. This report should not be used to make medical decisions without professional consultation.',
        style: const pw.TextStyle(
          fontSize: 8,
          color: PdfColors.grey800,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }
  
  // Helper methods for getting formatted text
  static String _getLikelihoodText(Assessment assessment) {
    switch (assessment.likelihood) {
      case AutismLikelihood.low:
        return 'Low Risk';
      case AutismLikelihood.moderate:
        return 'Medium Risk';
      case AutismLikelihood.high:
        return 'High Risk';
      case AutismLikelihood.unknown:
      default:
        return 'Inconclusive';
    }
  }
  
  static PdfColor _getLikelihoodColor(Assessment assessment) {
    switch (assessment.likelihood) {
      case AutismLikelihood.low:
        return PdfColors.green700;
      case AutismLikelihood.moderate:
        return PdfColors.orange;
      case AutismLikelihood.high:
        return PdfColors.red;
      case AutismLikelihood.unknown:
      default:
        return PdfColors.grey;
    }
  }
  
  static String _getLikelihoodDescription(Assessment assessment) {
    switch (assessment.likelihood) {
      case AutismLikelihood.low:
        return 'Based on your responses, there is a low likelihood of autism-related behaviors. Continue to monitor your child\'s development.';
      case AutismLikelihood.moderate:
        return 'Based on your responses, there is a moderate likelihood of autism-related behaviors. We recommend discussing these results with a healthcare professional.';
      case AutismLikelihood.high:
        return 'Based on your responses, there is a high likelihood of autism-related behaviors. We strongly recommend consulting with a developmental specialist or pediatrician as soon as possible.';
      case AutismLikelihood.unknown:
      default:
        return 'The assessment was inconclusive. This may happen if too few questions were answered or if there were inconsistencies in the responses.';
    }
  }
} 