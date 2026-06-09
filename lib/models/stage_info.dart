// نماذج بيانات المراحل المخصّصة (تُحمَّل من جداول كل مرحلة في Supabase)
// تُستخدم في شاشة تفاصيل المرحلة (StageDetailsView) عبر (StageDetailsController).

/// المرحلة الأولى — جدول "first stage"
class Stage1Info {
  final int? id;
  final String? researchTitle;
  final String? researchDescription;
  final bool? supervisorApproval;

  Stage1Info({
    this.id,
    this.researchTitle,
    this.researchDescription,
    this.supervisorApproval,
  });

  factory Stage1Info.fromJson(Map<String, dynamic> json) {
    return Stage1Info(
      id: json["stage1_id"],
      researchTitle: json["research_title"],
      researchDescription: json["research_description"],
      supervisorApproval: json["sprvsr_approval"],
    );
  }
}

/// المرحلة الثانية — جدول "stage2_titles_approval"
class Stage2Info {
  final int? id;
  final String? pdfFile;
  final bool? stageApproval;
  final String? supervisorNote;
  final String? studentNotes;

  Stage2Info({
    this.id,
    this.pdfFile,
    this.stageApproval,
    this.supervisorNote,
    this.studentNotes,
  });

  factory Stage2Info.fromJson(Map<String, dynamic> json) {
    return Stage2Info(
      id: json["stage2_id"],
      pdfFile: json["pdf_file"],
      stageApproval: json["stage_approval"],
      supervisorNote: json["sprvsr_note"],
      studentNotes: json["student_notes"],
    );
  }
}

/// المرحلة الثالثة — جدول "third stage(discussion)"
class Stage3Info {
  final int? id;
  final bool? discussionState;
  final double? discussionPercent;
  final String? supervisorNote;
  final DateTime? discussionDate;

  Stage3Info({
    this.id,
    this.discussionState,
    this.discussionPercent,
    this.supervisorNote,
    this.discussionDate,
  });

  factory Stage3Info.fromJson(Map<String, dynamic> json) {
    return Stage3Info(
      id: json["stage3_id"],
      discussionState: json["discussion_state"],
      discussionPercent: (json["discussion_percent"] as num?)?.toDouble(),
      supervisorNote: json["sprvsr_note"],
      discussionDate: json["discus_date"] != null
          ? DateTime.tryParse(json["discus_date"].toString())
          : null,
    );
  }
}

/// المرحلة الرابعة — جدول "fourth stage"
class Stage4Info {
  final int? id;
  final String? pdfFile;
  final bool? approval;
  final String? supervisorNotes;

  Stage4Info({
    this.id,
    this.pdfFile,
    this.approval,
    this.supervisorNotes,
  });

  factory Stage4Info.fromJson(Map<String, dynamic> json) {
    return Stage4Info(
      id: json["stage4_id"],
      pdfFile: json["stage4_pdf"],
      approval: json["approval"],
      supervisorNotes: json["sprvsr_notes"],
    );
  }
}

/// المرحلة الخامسة — قسم واحد من جدول "fifth_Stage" + اسم القسم من "fifth stage titles".
/// لكل مجموعة سبعة أقسام ثابتة (الفصول والملحق والمراجع)؛ قد لا يوجد صف بعد إن لم يرفع الطالب ملفاً.
class Stage5Section {
  final int titleId;
  final String titleName;
  final int? rowId; // stage5_id (null إن لم يُرفع بعد)
  final String? pdfFile;
  final bool? approval;
  final String? supervisorNote;

  Stage5Section({
    required this.titleId,
    required this.titleName,
    this.rowId,
    this.pdfFile,
    this.approval,
    this.supervisorNote,
  });

  /// يبني قسماً من اسم العنوان وصفّ "fifth_Stage" المطابق (قد يكون null).
  factory Stage5Section.from(
    int titleId,
    String titleName,
    Map<String, dynamic>? row,
  ) {
    return Stage5Section(
      titleId: titleId,
      titleName: titleName,
      rowId: row?["stage5_id"],
      pdfFile: row?["pdf_file"],
      approval: row?["approval"],
      supervisorNote: row?["sprvsr_note"],
    );
  }
}
