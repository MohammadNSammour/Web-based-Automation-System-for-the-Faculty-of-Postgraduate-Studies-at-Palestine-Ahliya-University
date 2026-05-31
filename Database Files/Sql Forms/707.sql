USE MPA2;
-- ------------------------------------------------------------
-- ------------------------------------------------------------
-- FORM 9-707 : تقرير ممتحن للرسائل العلمية والأطروحات الجامعية
-- ------------------------------------------------------------
-- ------------------------------------------------------------
INSERT INTO FormTypes (FormTypeID,Code,Name,Description,DisplayOrder,IsStartingForm,Category) VALUES
(9,'707','تقرير ممتحن للرسائل العلمية والأطروحات الجامعية','تقييم الممتحن الشامل للرسالة — يُرسَل لكل ممتحن مستقلاً',9,0,'Defense');

INSERT INTO FormWorkflowSteps (StepID,FormTypeID,StepName,StepOrder,AllowedRole,RequiresSpecificUser) VALUES
(23,9,'تقرير الممتحن',1,'Examiner',TRUE),
(24,9,'اعتماد عميد الكلية',2,'DeanOfFaculty',FALSE),
(25,9,'قرار لجنة الدراسات العليا',3,'DeanOfGradStudies',FALSE);

INSERT INTO FormSections (SectionID,StepID,SectionName,SectionOrder) VALUES
(44,23,'بيانات الطالب والرسالة',1),
(45,23,'بيانات الممتحن',2),
(46,23,'أولاً: ملخصات الرسالة',3),
(47,23,'ثانياً: مقدمة الرسالة',4),
(48,23,'ثالثاً: الإطار النظري والدراسات السابقة',5),
(49,23,'رابعاً: المنهجية',6),
(50,23,'خامساً: النتائج والمناقشة',7),
(51,23,'سادساً: الخاتمة والتوصيات',8),
(52,23,'سابعاً: المراجع والتوثيق',9),
(53,23,'ثامناً: الملاحق',10),
(54,23,'تاسعاً: الجدة والأصالة',11),
(55,23,'عاشراً: الالتزام بمناهج البحث',12),
(56,23,'حادي عشر: الموضوعية',13),
(57,23,'ثاني عشر: الأسلوب وشخصية الباحث',14),
(58,23,'ثالث عشر: التنظيم والترتيب',15),
(59,23,'رابع عشر: اللغة',16),
(60,23,'خامس عشر: التعامل مع التقنيات',17),
(61,23,'سادس عشر: التوثيق الداخلي للنص',18),
(62,23,'سابع عشر: نتائج البحث وتحليلها',19),
(63,23,'التوصية النهائية للممتحن',20),
(64,24,'للاستعمال الرسمي — اعتماد عميد الكلية',1),
(65,25,'قرار لجنة الدراسات العليا',1);

INSERT INTO FormFields (FieldID,SectionID,FieldLabel,FieldName,FieldType,FieldOptions,IsRequired,IsReadOnly,IsAutoFill,IsRepeatable,MaxRepeat,DataSource,ConditionalOn,ConditionalValue,FieldOrder,CSSClass) VALUES
-- ── Sec 44: بيانات الطالب والرسالة (تلقائية) ────────────────────────
(207,44,'اسم الطالب/ة','student_name','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Students.Users.full_name',NULL,NULL,1,'col-6'),
(208,44,'الرقم الجامعي','student_id','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Students.UniversityID',NULL,NULL,2,'col-6'),
(209,44,'البرنامج','program','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Students.Programs.ProgramName',NULL,NULL,3,'col-6'),
(210,44,'منسق البرنامج','coordinator','text',NULL,FALSE,TRUE,TRUE,FALSE,1,'Programs.ProgramCoordinator.Users.full_name',NULL,NULL,4,'col-6'),
(211,44,'عنوان الرسالة','thesis_title','textarea',NULL,TRUE,TRUE,TRUE,FALSE,1,'Thesis.ThesisName',NULL,NULL,5,'col-12'),
-- ── Sec 45: بيانات الممتحن (تلقائية من سجل الدخول) ─────────────────
(212,45,'نوع الممتحن','examiner_type','radio','داخلي,خارجي',TRUE,TRUE,TRUE,FALSE,1,'FormSubmissionAssignees.ExaminerType',NULL,NULL,1,'col-6'),
(213,45,'اسم الممتحن','examiner_name','text',NULL,TRUE,TRUE,TRUE,FALSE,1,'Users.full_name',NULL,NULL,2,'col-6'),
(214,45,'التخصص الدقيق','examiner_specialty','text',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-6'),
(215,45,'الرتبة الأكاديمية','examiner_rank','text',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,4,'col-6'),
(216,45,'الوظيفة','examiner_job','text',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,5,'col-6'),
(217,45,'المؤسسة أو الجامعة','examiner_inst','text',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,6,'col-6'),
(218,45,'العنوان','examiner_address','text',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,7,'col-6'),
(219,45,'رقم الهاتف','examiner_phone','text',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,8,'col-6'),
(220,45,'الفاكس','examiner_fax','text',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,9,'col-6'),
(221,45,'البريد الإلكتروني','examiner_email','email',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,10,'col-6'),
-- ── Sec 46: أولاً — ملخصات الرسالة ─────────────────────────────────
(222,46,'أ- الملخص (Abstract) بلغة الرسالة — 600 كلمة / 2-4 صفحات','abstract_ar','radio','ملائمة,بحاجة إلى تعديل,غير ملائمة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(223,46,'ب- الملخص (Abstract) بلغة غير لغة الرسالة — 600 كلمة / 2-4 صفحات','abstract_other','radio','ملائمة,بحاجة إلى تعديل,غير ملائمة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(224,46,'ملاحظات على الملخصات','abstract_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-12'),
-- ── Sec 47: ثانياً — مقدمة الرسالة ─────────────────────────────────
(225,47,'أ- مشكلة الدراسة','intro_problem','radio','ملائمة,بحاجة إلى تعديل,غير ملائمة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(226,47,'ب- أهمية الدراسة','intro_importance','radio','ملائمة,بحاجة إلى تعديل,غير ملائمة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(227,47,'ج- أهداف الدراسة','intro_objectives','radio','ملائمة,بحاجة إلى تعديل,غير ملائمة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-12'),
(228,47,'د- أسئلة أو فرضيات الدراسة','intro_questions','radio','ملائمة,بحاجة إلى تعديل,غير ملائمة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,4,'col-12'),
(229,47,'هـ- حدود الدراسة','intro_limits','radio','ملائمة,بحاجة إلى تعديل,غير ملائمة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,5,'col-12'),
(230,47,'ملاحظات على المقدمة','intro_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,6,'col-12'),
-- ── Sec 48: ثالثاً — الإطار النظري والدراسات السابقة ───────────────
(231,48,'أ- شمولية الدراسات السابقة','theory_coverage','radio','ملائمة,بحاجة إلى تعديل,غير ملائمة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(232,48,'ب- تحليل الدراسات السابقة','theory_analysis','radio','ملائمة,بحاجة إلى تعديل,غير ملائمة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(233,48,'ج- الإسهام النظري الأصيل','theory_originality','radio','ملائمة,بحاجة إلى تعديل,غير ملائمة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-12'),
(234,48,'ملاحظات على الإطار النظري','theory_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,4,'col-12'),
-- ── Sec 49: رابعاً — المنهجية ───────────────────────────────────────
(235,49,'أ- مجتمع الدراسة وعينتها','method_sample','radio','ملائمة,بحاجة إلى تعديل,غير ملائمة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(236,49,'ب- أداة الدراسة','method_tool','radio','ملائمة,بحاجة إلى تعديل,غير ملائمة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(237,49,'ج- المعالجة الإحصائية','method_stats','radio','ملائمة,بحاجة إلى تعديل,غير ملائمة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-12'),
(238,49,'ملاحظات على المنهجية','method_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,4,'col-12'),
-- ── Sec 50: خامساً — النتائج والمناقشة ─────────────────────────────
(239,50,'أ- مناقشة النتائج','results_discussion','radio','ملائمة,بحاجة إلى تعديل,غير ملائمة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(240,50,'ب- تفسير النتائج','results_interpretation','radio','ملائمة,بحاجة إلى تعديل,غير ملائمة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(241,50,'ج- الجداول والأشكال','results_tables','radio','ملائمة,بحاجة إلى تعديل,غير ملائمة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-12'),
(242,50,'ملاحظات على النتائج والمناقشة','results_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,4,'col-12'),
-- ── Sec 51: سادساً — الخاتمة والتوصيات ─────────────────────────────
(243,51,'أ- استنتاجات البحث','conclusion_findings','radio','ملائمة,بحاجة إلى تعديل,غير ملائمة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(244,51,'ب- التوصيات','conclusion_recommendations','radio','ملائمة,بحاجة إلى تعديل,غير ملائمة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(245,51,'ملاحظات على الخاتمة','conclusion_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-12'),
-- ── Sec 52: سابعاً — المراجع والتوثيق ──────────────────────────────
(246,52,'عدد المراجع المستخدمة','refs_count','radio','كافٍ,متوسط,قليل',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(247,52,'لغة المراجع المستخدمة','refs_language','radio','لغة واحدة,لغتان,أكثر من ذلك',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(248,52,'رد الباحث المعلومات إلى مصادرها الأصلية','refs_attribution','radio','غالباً,أحياناً,استند إلى باحثين آخرين',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-12'),
(249,52,'مصادر البحث اشتملت على','refs_sources','checkbox','القرآن الكريم,كتب,مجلات ودوريات,موسوعات,مخطوطات,جرائد,تقارير,رسائل ماجستير ودكتوراه,الإنترنت,الإذاعة والتلفزيون,لقاء واتصال شخصي',FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,4,'col-12'),
(250,52,'ملاحظات على التوثيق','refs_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,5,'col-12'),
-- ── Sec 53: ثامناً — الملاحق ────────────────────────────────────────
(251,53,'الملاحق مرتبطة بموضوع الرسالة','appendix_relevance','radio','نعم,لا,لا توجد ملاحق',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(252,53,'ملاحظات على الملاحق','appendix_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
-- ── Sec 54: تاسعاً — الجدة والأصالة (checkboxes نعم/لا) ────────────
(253,54,'الرسالة تحوي إنتاجاً علمياً لم يُسبق اكتشافه أو دراسته','originality_new','radio','نعم,لا',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(254,54,'الرسالة أتمت موضوعاً ناقصاً','originality_complete','radio','نعم,لا',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(255,54,'الرسالة شرحت موضوعاً مبهماً','originality_clarify','radio','نعم,لا',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-12'),
(256,54,'الرسالة اختصرت موضوعاً طويلاً دون الإخلال بالمعنى','originality_shorten','radio','نعم,لا',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,4,'col-12'),
(257,54,'الرسالة جمعت موضوعاً متفرقاً أو رتبت موضوعاً مشتتاً','originality_organize','radio','نعم,لا',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,5,'col-12'),
(258,54,'ملاحظات على الجدة والأصالة','originality_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,6,'col-12'),
-- ── Sec 55: عاشراً — الالتزام بمناهج البحث ─────────────────────────
(259,55,'المنهج العلمي المستخدم','research_method','select','الوصفي,التاريخي,التحليلي,التجريبي,الوصفي الارتباطي,لم يلتزم بمنهج محدد',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(260,55,'ملاحظات على الالتزام بالمنهج','research_method_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
-- ── Sec 56: حادي عشر — الموضوعية ───────────────────────────────────
(261,56,'طرح الباحث مشكلة البحث بموضوعية بدرجة','objectivity_problem','radio','كبيرة,متوسطة,معدومة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(262,56,'مواقف وآراء الباحث جاءت بصورة','objectivity_stance','radio','متناسقة,متناقضة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(263,56,'عرض الباحث نتائج البحث بصورة','objectivity_results','radio','موضوعية,متحيزة,لا رأي للباحث',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-12'),
(264,56,'ملاحظات على الموضوعية','objectivity_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,4,'col-12'),
-- ── Sec 57: ثاني عشر — الأسلوب وشخصية الباحث ──────────────────────
(265,57,'برزت شخصية الباحث في','style_personality','radio','كافة الفصول,بعض الفصول,الخاتمة فقط,لم تبرز',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(266,57,'أسلوب عرض الرسالة','style_presentation','radio','خاص بالباحث (تقليدي),غير ذلك (مختلط)',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(267,57,'ملاحظات على الأسلوب','style_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-12'),
-- ── Sec 58: ثالث عشر — التنظيم والترتيب ────────────────────────────
(268,58,'توزيع المعلومات في فصول الرسالة','organization_dist','radio','مناسب,غير مناسب',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(269,58,'التزم الباحث بتتابع منطقي للمعلومات بدرجة','organization_logic','radio','كبيرة,متوسطة,قليلة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(270,58,'ملاحظات على التنظيم','organization_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-12'),
-- ── Sec 59: رابع عشر — اللغة ────────────────────────────────────────
(271,59,'الرسالة تحتوي أخطاء لغوية','language_errors','radio','قليلة,متوسطة,كثيرة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(272,59,'الرسالة تحتوي أخطاء مطبعية','typo_errors','radio','معدومة,قليلة,كثيرة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(273,59,'لغة التخصص العلمية للرسالة','language_level','radio','سطحية,متوسطة,عميقة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-12'),
(274,59,'ملاحظات على اللغة','language_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,4,'col-12'),
-- ── Sec 60: خامس عشر — التعامل مع التقنيات ─────────────────────────
(275,60,'البيانات المستخدمة','tech_data','radio','من إعداد الباحث,استعان بها,لا ينطبق',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(276,60,'استخدم الباحث البرامج الحاسوبية','tech_software','radio','نعم,لا',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(277,60,'الطرق المستخدمة في البحث','tech_methods','radio','قابلة للإعادة,غير قابلة للإعادة وعشوائية',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-12'),
(278,60,'ملاحظات على التقنيات','tech_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,4,'col-12'),
-- ── Sec 61: سادس عشر — التوثيق الداخلي للنص ───────────────────────
(279,61,'التوثيق داخل النص متسق مع قائمة المراجع','doc_consistency','radio','نعم دائماً,أحياناً,نادراً',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(280,61,'ملاحظات على التوثيق الداخلي','doc_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
-- ── Sec 62: سابع عشر — نتائج البحث وتحليلها ────────────────────────
(281,62,'نتائج البحث أجابت على الفرضيات أو التساؤلات بدرجة','results_answered','radio','كبيرة,متوسطة,قليلة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(282,62,'نتائج البحث حققت أهداف الدراسة بدرجة','results_achieved','radio','كبيرة,متوسطة,قليلة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(283,62,'تحليل ومناقشة النتائج','results_analysis','radio','عميق,متوسط,غير مناسب',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-12'),
(284,62,'أهمية نتائج البحث بالنسبة للتخصص','results_importance','radio','مفيدة جداً,مفيدة,غير مفيدة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,4,'col-12'),
(285,62,'نتائج البحث وتوصياته في خدمة المجتمع','results_social','radio','قابلة للتطبيق,مهمة,نظرية بحتة,مكررة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,5,'col-12'),
(286,62,'نتائج البحث','results_publishable','radio','قابلة للنشر,غير قابلة للنشر',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,6,'col-12'),
(287,62,'ملاحظات على النتائج والتحليل','results_final_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,7,'col-12'),
-- ── Sec 63: التوصية النهائية للممتحن ────────────────────────────────
(288,63,'الرسالة تحوي إسهاماً في عالم المعرفة','knowledge_contribution','radio','نعم,لا',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(289,63,'توصية الممتحن بخصوص الرسالة','final_recommendation','radio','الرسالة صالحة للمناقشة بصورتها الحالية (لا توجد تعديلات),الرسالة صالحة للمناقشة بعد تعديلات جانبية,الرسالة غير صالحة بصورتها الحالية (تعديلات أساسية مطلوبة),الرسالة مرفوضة وغير قابلة للمناقشة',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(290,63,'نوع التعديلات الجانبية','minor_revision_type','checkbox','الإطار النظري,توثيق,أخطاء مطبعية,أخطاء لغوية,غير ذلك',FALSE,FALSE,FALSE,FALSE,1,NULL,'final_recommendation','الرسالة صالحة للمناقشة بعد تعديلات جانبية',3,'col-12'),
(291,63,'تفاصيل التعديلات الجانبية','minor_revision_details','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,'final_recommendation','الرسالة صالحة للمناقشة بعد تعديلات جانبية',4,'col-12'),
(292,63,'نوع التعديلات الأساسية','major_revision_type','checkbox','المنهجية,أداة الدراسة,الأهداف,معالجة النتائج ومناقشتها,التوصيات,غير ذلك',FALSE,FALSE,FALSE,FALSE,1,NULL,'final_recommendation','الرسالة غير صالحة بصورتها الحالية (تعديلات أساسية مطلوبة)',5,'col-12'),
(293,63,'تفاصيل التعديلات الأساسية','major_revision_details','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,'final_recommendation','الرسالة غير صالحة بصورتها الحالية (تعديلات أساسية مطلوبة)',6,'col-12'),
(294,63,'سبب رفض الرسالة','rejection_reason','checkbox','لا تحوي إسهاماً في عالم المعرفة,مخالفة لقواعد الأمانة العلمية',FALSE,FALSE,FALSE,FALSE,1,NULL,'final_recommendation','الرسالة مرفوضة وغير قابلة للمناقشة',7,'col-12'),
(295,63,'ملاحظات عامة على الرسالة','general_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,8,'col-12'),
(296,63,'توقيع الممتحن (صورة)','examiner_signature','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,9,'col-6'),
(297,63,'تاريخ التقرير','report_date','date',NULL,TRUE,TRUE,TRUE,FALSE,1,'CURRENT_DATE',NULL,NULL,10,'col-6'),
-- ── Sec 64: للاستعمال الرسمي — اعتماد عميد الكلية ──────────────────
(298,64,'رأي عميد الكلية','dean_opinion','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-12'),
(299,64,'قرار عميد الكلية','dean_decision','radio','يحول التقرير لمنسق البرنامج لمتابعة عقد المناقشة,يُعرض الأمر على لجنة الدراسات العليا لاختيار مقيّم ثالث,يُعرض الأمر على لجنة الدراسات العليا للبت في نتيجة الطالب',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-12'),
(300,64,'توقيع عميد الكلية (صورة)','dean_signature','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-6'),
(301,64,'تاريخ المصادقة','dean_date','date',NULL,TRUE,TRUE,TRUE,FALSE,1,'CURRENT_DATE',NULL,NULL,4,'col-6'),
-- ── Sec 65: قرار لجنة الدراسات العليا ──────────────────────────────
(302,65,'رقم الجلسة','session_number','text',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,1,'col-6'),
(303,65,'تاريخ الجلسة','session_date','date',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,2,'col-6'),
(304,65,'قرار لجنة الدراسات العليا','committee_decision','radio','اعتماد التقارير ومتابعة عقد المناقشة,تعيين مقيّم ثالث مرجّح (تضارب التوصيات),قرار رسوب الطالب في رسالة الماجستير (مفصول من البرنامج)',TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,3,'col-12'),
(305,65,'اسم المقيّم الثالث المقترح','third_examiner_name','text',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,'committee_decision','تعيين مقيّم ثالث مرجّح (تضارب التوصيات)',4,'col-12'),
(306,65,'ملاحظات اللجنة','committee_notes','textarea',NULL,FALSE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,5,'col-12'),
(307,65,'توقيع عميد الدراسات العليا (صورة)','grad_dean_signature','file',NULL,TRUE,FALSE,FALSE,FALSE,1,NULL,NULL,NULL,6,'col-6'),
(308,65,'تاريخ القرار','grad_dean_date','date',NULL,TRUE,TRUE,TRUE,FALSE,1,'CURRENT_DATE',NULL,NULL,7,'col-6');
