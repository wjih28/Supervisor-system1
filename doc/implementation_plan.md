# خطة تنفيذ: ربط نظام المشرف بقاعدة بيانات Supabase

هذه الخطة مخصصة للمبرمج للقيام بربط **نظام المشرف (Supervisor System)** بقاعدة بيانات Supabase الفعلية وإزالة الاعتماد على البيانات الوهمية (Mock Data).

النظام جاهز تقريباً من ناحية الواجهات ويحتوي على الكود المبدئي الخاص بـ Supabase (موجود كتعليقات)، والمطلوب هو تفعيل هذا الكود ومطابقته مع الجداول الحقيقية المتوفرة على المنصة.

---

## 1. التجهيز والتهيئة (Setup & Initialization)

### 1.1. إعداد متغيرات البيئة (`.env`)

- إضافة مفاتيح مشروع Supabase في ملف `.env` الموجود في جذر المشروع:

```env
SUPABASE_URL=رابط_المشروع_هنا
SUPABASE_ANON_KEY=المفتاح_الخاص_بالمشروع_هنا
```

- التأكد من أن ملف `pubspec.yaml` يحتوي على الحزمتين:
  - `flutter_dotenv`
  - `supabase_flutter`

### 1.2. تفعيل التهيئة في `lib/main.dart`

- إزالة التعليقات `/* ... */` حول كود تهيئة `Supabase.initialize` وتحميل `dotenv`.
- إزالة رسالة `"يتم تشغيل النظام في وضع النموذج الأولي"`.

> **[تعديل ملف]** `lib/main.dart`

---

## 2. تفعيل الاتصال بقاعدة البيانات وتحديث الدوال

يحتوي ملف `lib/services/supabase_service.dart` على الدوال الأساسية معتمدة حالياً على `MockData`. يجب إلغاء تعليق كود Supabase ومطابقته بدقة مع الجداول الفعلية التالية.

### 2.1. إعداد الـ Client

داخل أعلى كلاس `SupabaseService`:

```dart
// إزالة التعليق عن هذا السطر:
static final client = Supabase.instance.client;
```

- إزالة الاستيراد: `import '../constants/mock_data.dart';`

---

### 2.2. مطابقة أسماء الجداول والأعمدة في دوال الخدمة

#### 🔐 تسجيل الدخول (`loginSupervisor`)

| التفصيل | القيمة |
|---------|--------|
| الجدول | `supervisor` |
| عمود اليوزرنيم | `sprvsr_username` |
| عمود الإيميل | `sprvsr_email` |
| عمود كلمة المرور | `sprvsr_password` |
| المعرف الأساسي | `sprvsr_id` |

```dart
final response = await client
    .from('supervisor')
    .select()
    .or('sprvsr_username.eq.$username,sprvsr_email.eq.$username')
    .eq('sprvsr_password', password)
    .maybeSingle();
```

---

#### 📋 جلب المشاريع (`getGroupsBySupervisor`)

| التفصيل | القيمة |
|---------|--------|
| الجدول | `groups` |
| شرط البحث | `id_sprvsr = supervisorId` |
| الأعمدة الرئيسية | `group_id`, `group_name`, `group_progress`, `current_stage`, `id_program`, `group_led_id` |

```dart
final response = await client
    .from('groups')
    .select()
    .eq('id_sprvsr', supervisorId);
```

---

#### 👥 جلب طلاب المجموعة (`getGroupStudents`)

| التفصيل | القيمة |
|---------|--------|
| الجدول | `student` |
| شرط البحث | `id_group = groupId` |
| الأعمدة | `stud_id`, `stud_name`, `stud_email`, `stud_phone_num`, `stud_college_num` |

```dart
final response = await client
    .from('student')
    .select()
    .eq('id_group', groupId);
```

---

#### 💬 التعليقات والملاحظات (`getCommentsByGroup`, `addReviewComment`)

| التفصيل | القيمة |
|---------|--------|
| الجدول | `review_comments` |
| الأعمدة | `comment_id`, `id_group`, `id_sprvsr`, `comment_text`, `comment_type`, `comment_rating`, `is_resolved`, `created_at` |

```dart
// جلب التعليقات
final response = await client
    .from('review_comments')
    .select()
    .eq('id_group', groupId);

// إضافة تعليق
await client.from('review_comments').insert({
  'id_group': groupId,
  'id_sprvsr': supervisorId,
  'comment_text': commentText,
  'is_resolved': false,
});

// حل تعليق
await client
    .from('review_comments')
    .update({'is_resolved': true})
    .eq('comment_id', commentId);
```

---

#### 📁 الملفات المرفوعة (`getProjectFiles`)

| التفصيل | القيمة |
|---------|--------|
| الجدول | `research_files` |
| الأعمدة | `file_id`, `id_group`, `file_name`, `file_url`, `file_type`, `file_size`, `uploaded_by`, `uploaded_at`, `file_stage` |

```dart
var query = client
    .from('research_files')
    .select()
    .eq('id_group', projectId);

if (stage != null) {
  query = query.eq('file_stage', stage);
}
```

---

#### 💭 نظام الدردشة (`getSupervisorChats`, `getChatMessages`, `sendMessage`)

جداول الدردشة **موجودة وجاهزة** وتدعم الوقت الفعلي (Real-time).

**جدول `chats`:**

| العمود | النوع | الوصف |
|--------|-------|-------|
| `chat_id` | int | المعرف |
| `id_group` | int | معرف المجموعة |
| `id_sprvsr` | int | معرف المشرف |
| `last_message` | text | آخر رسالة |
| `last_message_time` | timestamp | وقت آخر رسالة |

**جدول `messages`:**

| العمود | النوع | الوصف |
|--------|-------|-------|
| `message_id` | int | المعرف |
| `id_chat` | int | معرف المحادثة |
| `sender_id` | int | معرف المرسل |
| `sender_role` | text | `'student'` أو `'supervisor'` |
| `message_text` | text | نص الرسالة |
| `is_read` | bool | حالة القراءة |

```dart
// جلب محادثات المشرف
final chats = await client
    .from('chats')
    .select('*, groups(group_name)')
    .eq('id_sprvsr', supervisorId);

// إرسال رسالة
await client.from('messages').insert({
  'id_chat': chatId,
  'sender_id': supervisorId,
  'sender_role': 'supervisor',
  'message_text': text,
});

// تحديث آخر رسالة في المحادثة
await client.from('chats').update({
  'last_message': text,
  'last_message_time': DateTime.now().toIso8601String(),
}).eq('chat_id', chatId);

// Stream للرسائل الفورية (Real-time)
Stream<List<Map<String, dynamic>>> getMessagesStream(int chatId) {
  return client
      .from('messages')
      .stream(primaryKey: ['message_id'])
      .eq('id_chat', chatId)
      .order('created_at');
}
```

---

#### 📊 الإحصائيات (`getSupervisorStatistics`)

يجب كتابة هذه الدالة بالكامل حيث لا يوجد لها كود Supabase معلق:

```dart
static Future<Map<String, dynamic>?> getSupervisorStatistics(int supervisorId) async {
  try {
    final groups = await client
        .from('groups')
        .select('group_id, id_group_state, group_progress')
        .eq('id_sprvsr', supervisorId);

    int total = groups.length;
    // الاستناد إلى GroupState جدول لتحديد المعنى
    // يمكن تعديل الأرقام حسب قيم id_group_state في قاعدة البيانات
    double avgProgress = total > 0
        ? groups.fold(0.0, (sum, g) => sum + (g['group_progress'] ?? 0.0)) / total
        : 0.0;

    return {
      'totalProjects': total,
      'averageProgress': avgProgress,
    };
  } catch (e) {
    debugPrint('Error fetching statistics: $e');
    return null;
  }
}
```

---

#### ⚙️ الإعدادات (`getSupervisorSettings`, `updateSupervisorSettings`)

| التفصيل | القيمة |
|---------|--------|
| الجدول | `supervisor_settings` |
| شرط البحث | `id_sprvsr = supervisorId` |
| الأعمدة | `settings_id`, `id_sprvsr`, `email_notifications`, `push_notifications`, `language`, `timezone`, `profile_image_url`, `phone_number` |

---

#### 🔔 الإشعارات (`getNotifications`, `markNotificationAsRead`)

| التفصيل | القيمة |
|---------|--------|
| الجدول | `notifications` |
| الأعمدة | `notification_id`, `id_sprvsr`, `notification_title`, `notification_message`, `notification_type`, `id_group`, `is_read`, `created_at` |

---

## 3. مطابقة النماذج مع قاعدة البيانات (Models Syncing)

هذه خطوة هامة جداً، النماذج (Models) يجب أن تطابق هيكل الجداول الفعلي تماماً لتجنب مشاكل `null` أو `ParseErrors`.

### جدول التطابق بين النماذج والجداول الفعلية

| ملف النموذج | الجدول في Supabase | ملاحظات |
|-------------|-------------------|---------|
| `research_group.dart` | `groups` | الأعمدة: `group_id`, `group_name`, `id_sprvsr`, `group_progress`, `group_led_id`, `id_program`, `current_stage` |
| `student.dart` | `student` | الأعمدة: `stud_id`, `stud_name`, `stud_email`, `id_group`, `id_program` |
| `supervisor.dart` | `supervisor` | الأعمدة: `sprvsr_id`, `sprvsr_name`, `sprvsr_username`, `sprvsr_email` |
| `review_comment.dart` | `review_comments` | الأعمدة: `comment_id`, `id_group`, `id_sprvsr`, `comment_text`, `is_resolved` |
| `project_file.dart` | `research_files` | الأعمدة: `file_id`, `id_group`, `file_name`, `file_url`, `file_stage` |
| `app_notification.dart` | `notifications` | الأعمدة: `notification_id`, `id_sprvsr`, `notification_title`, `is_read` |
| `supervisor_settings.dart` | `supervisor_settings` | الأعمدة: `settings_id`, `id_sprvsr`, `email_notifications`, `language` |

> **[تعديل ملفات]** `lib/models/*.dart`

---

## 4. ملاحظة حول نظام المراحل (Stages)

قاعدة البيانات تحتوي على نظام مراحل **متقدم جداً** مُقسَّم إلى جداول منفصلة لكل مرحلة:

| الجدول | المرحلة |
|--------|---------|
| `first stage` | اختيار عنوان البحث + اعتمادات ثلاثية |
| `stage2_titles_approval` | اعتماد الخطة + رفع PDF |
| `third stage(discussion)` | مناقشة الخطة + نسبة التقييم |
| `fourth stage` | المرحلة الرابعة + اعتمادات العميد ورئيس القسم |
| `fifth_Stage` | المرحلة الخامسة + اختيار العنوان |
| `stage 6 (trio discussion)` | المناقشة الثلاثية النهائية |
| `stages statues` | حالة كل مرحلة لكل مجموعة |
| `stages` | الجدول الرئيسي للمراحل مع التواريخ |

حالياً التطبيق يستخدم بيانات وهمية ثابتة للمراحل. للربط الصحيح يجب:
1. جلب بيانات المراحل من جدول `stages` الرئيسي.
2. جلب حالة كل مجموعة في كل مرحلة من `stages statues`.

---

## 5. إزالة البيانات الوهمية (Cleanup)

- حذف ملف `lib/constants/mock_data.dart` بالكامل.
- إزالة أي استيراد له من جميع ملفات الشاشات والتحكم (Controllers).

> **[حذف ملف]** `lib/constants/mock_data.dart`

---

## 6. خطة التحقق والاختبار (Verification Plan)

بعد إنهاء الربط والتأكد من خلو المشروع من أخطاء الـ Compilation:

1. ✅ **تسجيل الدخول الحقيقي**: تسجيل دخول باستخدام حساب مشرف موجود فعلاً في جدول `supervisor`.
2. ✅ **عرض بيانات حقيقية**: التأكد من ظهور المجموعات المرتبطة بالمشرف في لوحة التحكم.
3. ✅ **اختبار الدردشة**: إرسال رسالة والتأكد من ظهورها فورياً بدون تحديث (Real-time Streams).
4. ✅ **اختبار الملاحظات**: إضافة ملاحظة من واجهة المشرف والتأكد من حفظها في `review_comments`.
5. ✅ **اختبار الإشعارات**: التأكد من ظهور الإشعارات المرتبطة بالمشرف وتحديث حالة القراءة.
6. ✅ **اختبار الإعدادات**: حفظ إعدادات المشرف والتأكد من تحديثها في `supervisor_settings`.
