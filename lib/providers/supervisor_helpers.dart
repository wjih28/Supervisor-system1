import 'package:flutter/material.dart';
import '../models/models.dart';

/// فئة مساعدة تحتوي على دوال مساعدة لنظام المشرف
class SupervisorHelpers {
  /// الحصول على لون الحالة
  static Color getStatusColor(String? status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.orange;
      case 'delayed':
        return Colors.red;
      case 'pending_approval':
      case 'pending':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  /// الحصول على تسمية الحالة بالعربية
  static String getStatusLabel(String? status) {
    switch (status) {
      case 'completed':
        return 'مكتملة';
      case 'in_progress':
        return 'قيد التنفيذ';
      case 'delayed':
        return 'متأخرة';
      case 'pending_approval':
        return 'بانتظار الموافقة';
      case 'pending':
        return 'قيد الانتظار';
      default:
        return 'غير محدد';
    }
  }

  /// الحصول على أيقونة الحالة
  static IconData getStatusIcon(String? status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'in_progress':
        return Icons.hourglass_bottom;
      case 'delayed':
        return Icons.warning;
      case 'pending_approval':
      case 'pending':
        return Icons.schedule;
      default:
        return Icons.info;
    }
  }

  /// تنسيق التاريخ
  static String formatDate(DateTime? date) {
    if (date == null) return 'غير محدد';
    return '${date.day}/${date.month}/${date.year}';
  }

  /// تنسيق التاريخ والوقت
  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'غير محدد';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} - ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// الحصول على الفرق بين التاريخ الحالي والتاريخ المعطى
  static String getTimeDifference(DateTime? date) {
    if (date == null) return 'غير محدد';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else {
      return 'للتو';
    }
  }

  /// تنسيق حجم الملف
  static String formatFileSize(int? bytes) {
    if (bytes == null || bytes == 0) return '0 B';

    const suffixes = ['B', 'KB', 'MB', 'GB'];
    double size = bytes.toDouble();
    int suffixIndex = 0;

    while (size >= 1024 && suffixIndex < suffixes.length - 1) {
      size /= 1024;
      suffixIndex++;
    }

    return '${size.toStringAsFixed(2)} ${suffixes[suffixIndex]}';
  }

  /// الحصول على أيقونة نوع الملف
  static IconData getFileTypeIcon(String? fileType) {
    switch (fileType?.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'zip':
      case 'rar':
        return Icons.folder_zip;
      default:
        return Icons.insert_drive_file;
    }
  }

  /// الحصول على لون نوع الملف
  static Color getFileTypeColor(String? fileType) {
    switch (fileType?.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'xls':
      case 'xlsx':
        return Colors.green;
      case 'ppt':
      case 'pptx':
        return Colors.orange;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Colors.purple;
      case 'zip':
      case 'rar':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  /// حساب نسبة التقدم الكلية
  static double calculateOverallProgress(List<ResearchGroup> groups) {
    if (groups.isEmpty) return 0.0;
    final totalProgress =
        groups.fold(0.0, (sum, g) => sum + (g.progress ?? 0.0));
    return totalProgress / groups.length;
  }

  /// حساب معدل الإنجاز
  static double calculateCompletionRate(List<ResearchGroup> groups) {
    if (groups.isEmpty) return 0.0;
    final completed = groups.where((g) => g.status == 'completed').length;
    return (completed / groups.length) * 100;
  }

  /// الحصول على ملخص الحالة
  static String getStatusSummary(List<ResearchGroup> groups) {
    final completed = groups.where((g) => g.status == 'completed').length;
    final inProgress = groups.where((g) => g.status == 'in_progress').length;
    final delayed = groups.where((g) => g.status == 'delayed').length;
    final pending = groups.where((g) => g.status == 'pending').length;

    return 'مكتملة: $completed | قيد التنفيذ: $inProgress | متأخرة: $delayed | قيد الانتظار: $pending';
  }

  /// التحقق من تأخر المشروع
  static bool isProjectDelayed(ResearchGroup group) {
    if (group.status == 'delayed') return true;
    if (group.status == 'completed') return false;
    return (group.progress ?? 0.0) < 0.5; 
  }

  /// الحصول على تحذير التأخر
  static String getDelayWarning(ResearchGroup group) {
    if (!isProjectDelayed(group)) return '';
    return 'تحذير: هذا المشروع متأخر عن الجدول الزمني';
  }

  /// ترتيب المجموعات حسب الأولوية
  static List<ResearchGroup> sortByPriority(List<ResearchGroup> groups) {
    final sorted = [...groups];
    sorted.sort((a, b) {
      // Priority 1: Delayed projects
      if (a.status == 'delayed' && b.status != 'delayed') return -1;
      if (a.status != 'delayed' && b.status == 'delayed') return 1;

      // Priority 2: In-progress projects
      if (a.status == 'in_progress' && b.status != 'in_progress') return -1;
      if (a.status != 'in_progress' && b.status == 'in_progress') return 1;

      // Priority 3: By progress (less progress first)
      return (a.progress ?? 0.0).compareTo(b.progress ?? 0.0);
    });
    return sorted;
  }

  /// التحقق من وجود ملفات جديدة
  static bool hasNewFiles(List<ProjectFile> files) {
    final oneDayAgo = DateTime.now().subtract(const Duration(days: 1));
    return files
        .any((f) => f.uploadedAt != null && f.uploadedAt!.isAfter(oneDayAgo));
  }

  /// الحصول على الملفات المرتبة حسب التاريخ
  static List<ProjectFile> sortFilesByDate(List<ProjectFile> files) {
    final sorted = [...files];
    sorted.sort((a, b) {
      final dateA = a.uploadedAt ?? DateTime(1970);
      final dateB = b.uploadedAt ?? DateTime(1970);
      return dateB.compareTo(dateA);
    });
    return sorted;
  }

  /// التحقق من صحة بيانات المجموعة
  static bool isValidGroup(ResearchGroup group) {
    return group.id != null &&
        group.name.isNotEmpty &&
        group.supervisorId != null;
  }

  /// التحقق من صحة بيانات الملاحظة
  static bool isValidComment(ProjectFeedback comment) {
    return comment.groupId != null &&
        comment.supervisorId != null &&
        comment.comment.isNotEmpty;
  }

  /// الحصول على رسالة تحذير للمشرف
  static String getWarningMessage(List<ResearchGroup> groups) {
    final delayed = groups.where((g) => g.status == 'delayed').length;
    final pending = groups.where((g) => g.status == 'pending').length;

    if (delayed > 0) {
      return 'لديك $delayed مشروع متأخر يحتاج إلى متابعة فورية';
    } else if (pending > 0) {
      return 'لديك $pending مشروع لم يبدأ بعد';
    }

    return '';
  }
}
