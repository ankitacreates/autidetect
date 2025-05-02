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
    final pdf = pw.Document();
    
    // Format date
    final dateFormat = DateFormat('MMMM d, yyyy');
    final dateString = assessment.completedAt != null 
        ? dateFormat.format(assessment.completedAt!) 
        : dateFormat.format(DateTime.now());
    
    // Get likelihood text and color
    final String likelihoodText = _getLikelihoodText(assessment);
    final PdfColor color = _getLikelihoodColor(assessment);
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => [
          _buildHeader(),
          pw.SizedBox(height: 20),
          _buildPatientInfo(assessment, dateString),
          pw.SizedBox(height: 20),
          _buildResultSection(assessment, likelihoodText, color),
          pw.SizedBox(height: 20),
          _buildExplanationSection(),
          pw.SizedBox(height: 20),
          _buildRecommendationsSection(),
          pw.SizedBox(height: 30),
          _buildDisclaimer(),
        ],
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 20),
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(
              fontSize: 10,
            ),
          ),
        ),
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
    final directory = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${directory.path}/autidetect_reports');
    
    if (!(await exportDir.exists())) {
      await exportDir.create(recursive: true);
    }
    
    return exportDir;
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
  static pw.Widget _buildHeader() {
    return pw.Header(
      level: 0,
      child: pw.Text(
        'AutiDetect Assessment Report',
        style: pw.TextStyle(
          fontSize: 24,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }
  
  static pw.Widget _buildPatientInfo(
    Assessment assessment,
    String dateString,
  ) {
    String assessmentType = assessment.type == AssessmentType.toddler
        ? "Toddler Assessment (18-36 months)"
        : "Child Assessment (3-12 years)";
        
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
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
                  'Assessment Date:',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Expanded(
                flex: 2,
                child: pw.Text(
                  dateString,
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
                  assessmentType,
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
  
  static pw.Widget _buildExplanationSection() {
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
            'What This Means',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Bullet(
            text: 'These results are based on your responses to the autism screening questionnaire.',
            style: const pw.TextStyle(
              fontSize: 11,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Bullet(
            text: 'This is not a diagnosis. Only a qualified healthcare professional can diagnose autism.',
            style: const pw.TextStyle(
              fontSize: 11,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Bullet(
            text: 'Early intervention can significantly improve outcomes for children with autism.',
            style: const pw.TextStyle(
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
  
  static pw.Widget _buildRecommendationsSection() {
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
            'Recommended Next Steps',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: 24,
                height: 24,
                decoration: const pw.BoxDecoration(
                  color: PdfColors.lightBlue100,
                  shape: pw.BoxShape.circle,
                ),
                alignment: pw.Alignment.center,
                child: pw.Text(
                  '1',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Share these results with a healthcare professional',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'Discuss these screening results with your child\'s pediatrician or a developmental specialist.',
                      style: const pw.TextStyle(
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: 24,
                height: 24,
                decoration: const pw.BoxDecoration(
                  color: PdfColors.lightBlue100,
                  shape: pw.BoxShape.circle,
                ),
                alignment: pw.Alignment.center,
                child: pw.Text(
                  '2',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Learn more about developmental milestones',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'Understand typical childhood development and potential signs of autism.',
                      style: const pw.TextStyle(
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: 24,
                height: 24,
                decoration: const pw.BoxDecoration(
                  color: PdfColors.lightBlue100,
                  shape: pw.BoxShape.circle,
                ),
                alignment: pw.Alignment.center,
                child: pw.Text(
                  '3',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Schedule a follow-up assessment',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'Tracking development over time provides more accurate insights.',
                      style: const pw.TextStyle(
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
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