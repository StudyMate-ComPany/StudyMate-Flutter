import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('ko')];

  /// 앱 타이틀
  ///
  /// In ko, this message translates to:
  /// **'스터디메이트 📚'**
  String get appTitle;

  /// No description provided for @welcomeTitle.
  ///
  /// In ko, this message translates to:
  /// **'안녕하세요! 👋'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'AI 학습 도우미와 함께\n효율적으로 공부해요'**
  String get welcomeSubtitle;

  /// No description provided for @loginTitle.
  ///
  /// In ko, this message translates to:
  /// **'로그인'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'다시 만나서 반가워요! 😊'**
  String get loginSubtitle;

  /// No description provided for @registerTitle.
  ///
  /// In ko, this message translates to:
  /// **'회원가입'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'스터디메이트에 오신 걸 환영해요! 🎉'**
  String get registerSubtitle;

  /// No description provided for @email.
  ///
  /// In ko, this message translates to:
  /// **'이메일'**
  String get email;

  /// No description provided for @emailHint.
  ///
  /// In ko, this message translates to:
  /// **'your@email.com'**
  String get emailHint;

  /// No description provided for @password.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호'**
  String get password;

  /// No description provided for @passwordHint.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호를 입력하세요'**
  String get passwordHint;

  /// No description provided for @passwordConfirm.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호 확인'**
  String get passwordConfirm;

  /// No description provided for @passwordConfirmHint.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호를 다시 입력하세요'**
  String get passwordConfirmHint;

  /// No description provided for @name.
  ///
  /// In ko, this message translates to:
  /// **'이름'**
  String get name;

  /// No description provided for @nameHint.
  ///
  /// In ko, this message translates to:
  /// **'이름을 입력하세요'**
  String get nameHint;

  /// No description provided for @loginButton.
  ///
  /// In ko, this message translates to:
  /// **'로그인'**
  String get loginButton;

  /// No description provided for @registerButton.
  ///
  /// In ko, this message translates to:
  /// **'회원가입'**
  String get registerButton;

  /// No description provided for @logoutButton.
  ///
  /// In ko, this message translates to:
  /// **'로그아웃'**
  String get logoutButton;

  /// No description provided for @termsAccept.
  ///
  /// In ko, this message translates to:
  /// **'이용약관에 동의합니다'**
  String get termsAccept;

  /// No description provided for @privacyAccept.
  ///
  /// In ko, this message translates to:
  /// **'개인정보처리방침에 동의합니다'**
  String get privacyAccept;

  /// No description provided for @noAccount.
  ///
  /// In ko, this message translates to:
  /// **'아직 계정이 없으신가요?'**
  String get noAccount;

  /// No description provided for @haveAccount.
  ///
  /// In ko, this message translates to:
  /// **'이미 계정이 있으신가요?'**
  String get haveAccount;

  /// No description provided for @homeTitle.
  ///
  /// In ko, this message translates to:
  /// **'홈'**
  String get homeTitle;

  /// No description provided for @goalsTitle.
  ///
  /// In ko, this message translates to:
  /// **'학습 목표'**
  String get goalsTitle;

  /// No description provided for @sessionsTitle.
  ///
  /// In ko, this message translates to:
  /// **'학습 세션'**
  String get sessionsTitle;

  /// No description provided for @aiHelperTitle.
  ///
  /// In ko, this message translates to:
  /// **'AI 도우미'**
  String get aiHelperTitle;

  /// No description provided for @profileTitle.
  ///
  /// In ko, this message translates to:
  /// **'프로필'**
  String get profileTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get settingsTitle;

  /// No description provided for @dashboard.
  ///
  /// In ko, this message translates to:
  /// **'대시보드'**
  String get dashboard;

  /// No description provided for @todaySummary.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 학습'**
  String get todaySummary;

  /// No description provided for @studyTime.
  ///
  /// In ko, this message translates to:
  /// **'학습 시간'**
  String get studyTime;

  /// No description provided for @completedGoals.
  ///
  /// In ko, this message translates to:
  /// **'완료한 목표'**
  String get completedGoals;

  /// No description provided for @activeGoals.
  ///
  /// In ko, this message translates to:
  /// **'진행 중인 목표'**
  String get activeGoals;

  /// No description provided for @createGoal.
  ///
  /// In ko, this message translates to:
  /// **'목표 만들기'**
  String get createGoal;

  /// No description provided for @goalTitle.
  ///
  /// In ko, this message translates to:
  /// **'목표 제목'**
  String get goalTitle;

  /// No description provided for @goalDescription.
  ///
  /// In ko, this message translates to:
  /// **'목표 설명'**
  String get goalDescription;

  /// No description provided for @goalType.
  ///
  /// In ko, this message translates to:
  /// **'목표 유형'**
  String get goalType;

  /// No description provided for @daily.
  ///
  /// In ko, this message translates to:
  /// **'일일'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In ko, this message translates to:
  /// **'주간'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In ko, this message translates to:
  /// **'월간'**
  String get monthly;

  /// No description provided for @custom.
  ///
  /// In ko, this message translates to:
  /// **'사용자 정의'**
  String get custom;

  /// No description provided for @targetHours.
  ///
  /// In ko, this message translates to:
  /// **'목표 시간'**
  String get targetHours;

  /// No description provided for @targetSummaries.
  ///
  /// In ko, this message translates to:
  /// **'목표 요약 수'**
  String get targetSummaries;

  /// No description provided for @targetQuizzes.
  ///
  /// In ko, this message translates to:
  /// **'목표 퀴즈 수'**
  String get targetQuizzes;

  /// No description provided for @startDate.
  ///
  /// In ko, this message translates to:
  /// **'시작일'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In ko, this message translates to:
  /// **'종료일'**
  String get endDate;

  /// No description provided for @startStudy.
  ///
  /// In ko, this message translates to:
  /// **'학습 시작'**
  String get startStudy;

  /// No description provided for @pauseStudy.
  ///
  /// In ko, this message translates to:
  /// **'일시정지'**
  String get pauseStudy;

  /// No description provided for @resumeStudy.
  ///
  /// In ko, this message translates to:
  /// **'계속하기'**
  String get resumeStudy;

  /// No description provided for @endStudy.
  ///
  /// In ko, this message translates to:
  /// **'학습 종료'**
  String get endStudy;

  /// No description provided for @subject.
  ///
  /// In ko, this message translates to:
  /// **'과목'**
  String get subject;

  /// No description provided for @topic.
  ///
  /// In ko, this message translates to:
  /// **'주제'**
  String get topic;

  /// No description provided for @duration.
  ///
  /// In ko, this message translates to:
  /// **'시간'**
  String get duration;

  /// No description provided for @notes.
  ///
  /// In ko, this message translates to:
  /// **'메모'**
  String get notes;

  /// No description provided for @aiChat.
  ///
  /// In ko, this message translates to:
  /// **'AI와 대화하기'**
  String get aiChat;

  /// No description provided for @askQuestion.
  ///
  /// In ko, this message translates to:
  /// **'질문하기'**
  String get askQuestion;

  /// No description provided for @generateQuiz.
  ///
  /// In ko, this message translates to:
  /// **'퀴즈 생성'**
  String get generateQuiz;

  /// No description provided for @generatePlan.
  ///
  /// In ko, this message translates to:
  /// **'학습 계획 생성'**
  String get generatePlan;

  /// No description provided for @statistics.
  ///
  /// In ko, this message translates to:
  /// **'통계'**
  String get statistics;

  /// No description provided for @progress.
  ///
  /// In ko, this message translates to:
  /// **'진행률'**
  String get progress;

  /// No description provided for @achievements.
  ///
  /// In ko, this message translates to:
  /// **'성과'**
  String get achievements;

  /// No description provided for @streaks.
  ///
  /// In ko, this message translates to:
  /// **'연속 학습'**
  String get streaks;

  /// No description provided for @notifications.
  ///
  /// In ko, this message translates to:
  /// **'알림'**
  String get notifications;

  /// No description provided for @darkMode.
  ///
  /// In ko, this message translates to:
  /// **'다크 모드'**
  String get darkMode;

  /// No description provided for @language.
  ///
  /// In ko, this message translates to:
  /// **'언어'**
  String get language;

  /// No description provided for @about.
  ///
  /// In ko, this message translates to:
  /// **'앱 정보'**
  String get about;

  /// No description provided for @save.
  ///
  /// In ko, this message translates to:
  /// **'저장'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In ko, this message translates to:
  /// **'삭제'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In ko, this message translates to:
  /// **'수정'**
  String get edit;

  /// No description provided for @close.
  ///
  /// In ko, this message translates to:
  /// **'닫기'**
  String get close;

  /// No description provided for @confirm.
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get confirm;

  /// No description provided for @loading.
  ///
  /// In ko, this message translates to:
  /// **'로딩 중...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In ko, this message translates to:
  /// **'오류가 발생했습니다'**
  String get error;

  /// No description provided for @success.
  ///
  /// In ko, this message translates to:
  /// **'성공!'**
  String get success;

  /// No description provided for @retry.
  ///
  /// In ko, this message translates to:
  /// **'다시 시도'**
  String get retry;

  /// No description provided for @passwordRequirements.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호는 대문자와 특수문자를 포함해야 합니다'**
  String get passwordRequirements;

  /// No description provided for @emailInvalid.
  ///
  /// In ko, this message translates to:
  /// **'올바른 이메일 주소를 입력하세요'**
  String get emailInvalid;

  /// No description provided for @fieldsRequired.
  ///
  /// In ko, this message translates to:
  /// **'모든 필드를 입력해주세요'**
  String get fieldsRequired;

  /// No description provided for @noGoals.
  ///
  /// In ko, this message translates to:
  /// **'아직 목표가 없어요'**
  String get noGoals;

  /// No description provided for @noGoalsDescription.
  ///
  /// In ko, this message translates to:
  /// **'첫 번째 학습 목표를 만들어보세요! 🎯'**
  String get noGoalsDescription;

  /// No description provided for @noSessions.
  ///
  /// In ko, this message translates to:
  /// **'학습 기록이 없어요'**
  String get noSessions;

  /// No description provided for @noSessionsDescription.
  ///
  /// In ko, this message translates to:
  /// **'지금 바로 학습을 시작해보세요! 💪'**
  String get noSessionsDescription;

  /// No description provided for @todayGoal.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 목표'**
  String get todayGoal;

  /// No description provided for @weeklyProgress.
  ///
  /// In ko, this message translates to:
  /// **'주간 진행률'**
  String get weeklyProgress;

  /// No description provided for @monthlyReport.
  ///
  /// In ko, this message translates to:
  /// **'월간 리포트'**
  String get monthlyReport;

  /// No description provided for @motivationMessage1.
  ///
  /// In ko, this message translates to:
  /// **'오늘도 화이팅! 💪'**
  String get motivationMessage1;

  /// No description provided for @motivationMessage2.
  ///
  /// In ko, this message translates to:
  /// **'조금씩 꾸준히! 🌱'**
  String get motivationMessage2;

  /// No description provided for @motivationMessage3.
  ///
  /// In ko, this message translates to:
  /// **'할 수 있어요! ⭐'**
  String get motivationMessage3;

  /// No description provided for @motivationMessage4.
  ///
  /// In ko, this message translates to:
  /// **'멋진 진전이에요! 🎉'**
  String get motivationMessage4;

  /// No description provided for @motivationMessage5.
  ///
  /// In ko, this message translates to:
  /// **'대단해요! 👏'**
  String get motivationMessage5;

  /// No description provided for @emailPlaceholder.
  ///
  /// In ko, this message translates to:
  /// **'your@email.com'**
  String get emailPlaceholder;

  /// No description provided for @studymatePlaceholder.
  ///
  /// In ko, this message translates to:
  /// **'studymate123'**
  String get studymatePlaceholder;

  /// No description provided for @studyEmailPlaceholder.
  ///
  /// In ko, this message translates to:
  /// **'study@example.com'**
  String get studyEmailPlaceholder;

  /// No description provided for @askMeAnything.
  ///
  /// In ko, this message translates to:
  /// **'학습에 대해 무엇이든 물어보세요...'**
  String get askMeAnything;

  /// No description provided for @subjectLabel.
  ///
  /// In ko, this message translates to:
  /// **'과목 *'**
  String get subjectLabel;

  /// No description provided for @subjectHint.
  ///
  /// In ko, this message translates to:
  /// **'예: 수학, 물리'**
  String get subjectHint;

  /// No description provided for @topicLabel.
  ///
  /// In ko, this message translates to:
  /// **'주제 (선택사항)'**
  String get topicLabel;

  /// No description provided for @topicHint.
  ///
  /// In ko, this message translates to:
  /// **'예: 미적분, 양자역학'**
  String get topicHint;

  /// No description provided for @linkToGoalLabel.
  ///
  /// In ko, this message translates to:
  /// **'목표 연결 (선택사항)'**
  String get linkToGoalLabel;

  /// No description provided for @sessionTypeLabel.
  ///
  /// In ko, this message translates to:
  /// **'세션 유형'**
  String get sessionTypeLabel;

  /// No description provided for @sessionNotesLabel.
  ///
  /// In ko, this message translates to:
  /// **'세션 노트 (선택사항)'**
  String get sessionNotesLabel;

  /// No description provided for @sessionNotesHint.
  ///
  /// In ko, this message translates to:
  /// **'무엇을 배웠거나 달성했나요?'**
  String get sessionNotesHint;

  /// No description provided for @titleLabel.
  ///
  /// In ko, this message translates to:
  /// **'제목'**
  String get titleLabel;

  /// No description provided for @titleHint.
  ///
  /// In ko, this message translates to:
  /// **'예: 수학 과정 완료'**
  String get titleHint;

  /// No description provided for @descriptionLabel.
  ///
  /// In ko, this message translates to:
  /// **'설명'**
  String get descriptionLabel;

  /// No description provided for @descriptionHint.
  ///
  /// In ko, this message translates to:
  /// **'무엇을 달성하고 싶나요?'**
  String get descriptionHint;

  /// No description provided for @goalTypeLabel.
  ///
  /// In ko, this message translates to:
  /// **'목표 유형'**
  String get goalTypeLabel;

  /// No description provided for @targetHoursLabel.
  ///
  /// In ko, this message translates to:
  /// **'목표 시간'**
  String get targetHoursLabel;

  /// No description provided for @startDateLabel.
  ///
  /// In ko, this message translates to:
  /// **'시작일'**
  String get startDateLabel;

  /// No description provided for @endDateLabel.
  ///
  /// In ko, this message translates to:
  /// **'종료일'**
  String get endDateLabel;

  /// No description provided for @targetSummariesLabel.
  ///
  /// In ko, this message translates to:
  /// **'목표 요약 수'**
  String get targetSummariesLabel;

  /// No description provided for @targetQuizzesLabel.
  ///
  /// In ko, this message translates to:
  /// **'목표 퀴즈 수'**
  String get targetQuizzesLabel;

  /// No description provided for @subjectExampleHint.
  ///
  /// In ko, this message translates to:
  /// **'예: 수학, 물리, 역사'**
  String get subjectExampleHint;

  /// No description provided for @subjectExampleHint2.
  ///
  /// In ko, this message translates to:
  /// **'예: 생물학, 화학, 문학'**
  String get subjectExampleHint2;

  /// No description provided for @conceptLabel.
  ///
  /// In ko, this message translates to:
  /// **'개념'**
  String get conceptLabel;

  /// No description provided for @conceptHint.
  ///
  /// In ko, this message translates to:
  /// **'예: 광합성, 뉴턴의 법칙, 민주주의'**
  String get conceptHint;

  /// No description provided for @mathematics.
  ///
  /// In ko, this message translates to:
  /// **'수학'**
  String get mathematics;

  /// No description provided for @science.
  ///
  /// In ko, this message translates to:
  /// **'과학'**
  String get science;

  /// No description provided for @english.
  ///
  /// In ko, this message translates to:
  /// **'영어'**
  String get english;

  /// No description provided for @history.
  ///
  /// In ko, this message translates to:
  /// **'역사'**
  String get history;

  /// No description provided for @geography.
  ///
  /// In ko, this message translates to:
  /// **'지리'**
  String get geography;

  /// No description provided for @physics.
  ///
  /// In ko, this message translates to:
  /// **'물리'**
  String get physics;

  /// No description provided for @chemistry.
  ///
  /// In ko, this message translates to:
  /// **'화학'**
  String get chemistry;

  /// No description provided for @biology.
  ///
  /// In ko, this message translates to:
  /// **'생물학'**
  String get biology;

  /// No description provided for @computerScience.
  ///
  /// In ko, this message translates to:
  /// **'컴퓨터 과학'**
  String get computerScience;

  /// No description provided for @literature.
  ///
  /// In ko, this message translates to:
  /// **'문학'**
  String get literature;

  /// No description provided for @art.
  ///
  /// In ko, this message translates to:
  /// **'미술'**
  String get art;

  /// No description provided for @music.
  ///
  /// In ko, this message translates to:
  /// **'음악'**
  String get music;

  /// No description provided for @physicalEducation.
  ///
  /// In ko, this message translates to:
  /// **'체육'**
  String get physicalEducation;

  /// No description provided for @foreignLanguage.
  ///
  /// In ko, this message translates to:
  /// **'외국어'**
  String get foreignLanguage;

  /// No description provided for @philosophy.
  ///
  /// In ko, this message translates to:
  /// **'철학'**
  String get philosophy;

  /// No description provided for @psychology.
  ///
  /// In ko, this message translates to:
  /// **'심리학'**
  String get psychology;

  /// No description provided for @economics.
  ///
  /// In ko, this message translates to:
  /// **'경제학'**
  String get economics;

  /// No description provided for @businessStudies.
  ///
  /// In ko, this message translates to:
  /// **'경영학'**
  String get businessStudies;

  /// No description provided for @reading.
  ///
  /// In ko, this message translates to:
  /// **'읽기'**
  String get reading;

  /// No description provided for @writing.
  ///
  /// In ko, this message translates to:
  /// **'쓰기'**
  String get writing;

  /// No description provided for @problemSolving.
  ///
  /// In ko, this message translates to:
  /// **'문제 해결'**
  String get problemSolving;

  /// No description provided for @memorization.
  ///
  /// In ko, this message translates to:
  /// **'암기'**
  String get memorization;

  /// No description provided for @research.
  ///
  /// In ko, this message translates to:
  /// **'연구'**
  String get research;

  /// No description provided for @practice.
  ///
  /// In ko, this message translates to:
  /// **'연습'**
  String get practice;

  /// No description provided for @review.
  ///
  /// In ko, this message translates to:
  /// **'복습'**
  String get review;

  /// No description provided for @discussion.
  ///
  /// In ko, this message translates to:
  /// **'토론'**
  String get discussion;

  /// No description provided for @projectWork.
  ///
  /// In ko, this message translates to:
  /// **'프로젝트 작업'**
  String get projectWork;

  /// No description provided for @presentationPrep.
  ///
  /// In ko, this message translates to:
  /// **'발표 준비'**
  String get presentationPrep;

  /// No description provided for @beginner.
  ///
  /// In ko, this message translates to:
  /// **'초급'**
  String get beginner;

  /// No description provided for @intermediate.
  ///
  /// In ko, this message translates to:
  /// **'중급'**
  String get intermediate;

  /// No description provided for @advanced.
  ///
  /// In ko, this message translates to:
  /// **'고급'**
  String get advanced;

  /// No description provided for @expert.
  ///
  /// In ko, this message translates to:
  /// **'전문가'**
  String get expert;

  /// No description provided for @studyMateTagline.
  ///
  /// In ko, this message translates to:
  /// **'AI 기반 학습 도우미'**
  String get studyMateTagline;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In ko, this message translates to:
  /// **'이메일을 입력해주세요'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In ko, this message translates to:
  /// **'올바른 이메일 주소를 입력해주세요'**
  String get pleaseEnterValidEmail;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호를 입력해주세요'**
  String get pleaseEnterPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호는 최소 8자 이상이어야 합니다'**
  String get passwordMinLength;

  /// No description provided for @passwordRequirementsDetail.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호는 대문자, 소문자, 숫자를 포함해야 합니다'**
  String get passwordRequirementsDetail;

  /// No description provided for @pleaseEnterName.
  ///
  /// In ko, this message translates to:
  /// **'이름을 입력해주세요'**
  String get pleaseEnterName;

  /// No description provided for @nameMinLength.
  ///
  /// In ko, this message translates to:
  /// **'이름은 최소 2자 이상이어야 합니다'**
  String get nameMinLength;

  /// No description provided for @nameMaxLength.
  ///
  /// In ko, this message translates to:
  /// **'이름은 50자 이하여야 합니다'**
  String get nameMaxLength;

  /// No description provided for @pleaseEnterField.
  ///
  /// In ko, this message translates to:
  /// **'{fieldName}을(를) 입력해주세요'**
  String pleaseEnterField(Object fieldName);

  /// No description provided for @fieldMustBePositive.
  ///
  /// In ko, this message translates to:
  /// **'{fieldName}은(는) 양수여야 합니다'**
  String fieldMustBePositive(Object fieldName);

  /// No description provided for @confirmButton.
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get confirmButton;

  /// No description provided for @cancelButton.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get cancelButton;

  /// No description provided for @failedToLoadAIHistory.
  ///
  /// In ko, this message translates to:
  /// **'AI 기록을 불러오는데 실패했습니다: {error}'**
  String failedToLoadAIHistory(Object error);

  /// No description provided for @failedToGetAIResponse.
  ///
  /// In ko, this message translates to:
  /// **'AI 응답을 받는데 실패했습니다: {error}'**
  String failedToGetAIResponse(Object error);

  /// No description provided for @failedToLoadStudyGoals.
  ///
  /// In ko, this message translates to:
  /// **'학습 목표를 불러오는데 실패했습니다: {error}'**
  String failedToLoadStudyGoals(Object error);

  /// No description provided for @failedToLoadStudySessions.
  ///
  /// In ko, this message translates to:
  /// **'학습 세션을 불러오는데 실패했습니다: {error}'**
  String failedToLoadStudySessions(Object error);

  /// No description provided for @failedToCreateGoal.
  ///
  /// In ko, this message translates to:
  /// **'목표를 생성하는데 실패했습니다: {error}'**
  String failedToCreateGoal(Object error);

  /// No description provided for @failedToUpdateGoal.
  ///
  /// In ko, this message translates to:
  /// **'목표를 업데이트하는데 실패했습니다: {error}'**
  String failedToUpdateGoal(Object error);

  /// No description provided for @failedToDeleteGoal.
  ///
  /// In ko, this message translates to:
  /// **'목표를 삭제하는데 실패했습니다: {error}'**
  String failedToDeleteGoal(Object error);

  /// No description provided for @studySessionAlreadyActive.
  ///
  /// In ko, this message translates to:
  /// **'학습 세션이 이미 진행 중입니다'**
  String get studySessionAlreadyActive;

  /// No description provided for @failedToStartStudySession.
  ///
  /// In ko, this message translates to:
  /// **'학습 세션을 시작하는데 실패했습니다: {error}'**
  String failedToStartStudySession(Object error);

  /// No description provided for @failedToPauseStudySession.
  ///
  /// In ko, this message translates to:
  /// **'학습 세션을 일시정지하는데 실패했습니다: {error}'**
  String failedToPauseStudySession(Object error);

  /// No description provided for @failedToResumeStudySession.
  ///
  /// In ko, this message translates to:
  /// **'학습 세션을 재개하는데 실패했습니다: {error}'**
  String failedToResumeStudySession(Object error);

  /// No description provided for @failedToEndStudySession.
  ///
  /// In ko, this message translates to:
  /// **'학습 세션을 종료하는데 실패했습니다: {error}'**
  String failedToEndStudySession(Object error);

  /// No description provided for @failedToInitializeAuth.
  ///
  /// In ko, this message translates to:
  /// **'인증을 초기화하는데 실패했습니다: {error}'**
  String failedToInitializeAuth(Object error);

  /// No description provided for @invalidServerResponse.
  ///
  /// In ko, this message translates to:
  /// **'서버로부터 잘못된 응답을 받았습니다'**
  String get invalidServerResponse;

  /// No description provided for @loginFailed.
  ///
  /// In ko, this message translates to:
  /// **'로그인에 실패했습니다: {error}'**
  String loginFailed(Object error);

  /// No description provided for @registrationFailed.
  ///
  /// In ko, this message translates to:
  /// **'회원가입에 실패했습니다: {error}'**
  String registrationFailed(Object error);

  /// No description provided for @profileUpdateFailed.
  ///
  /// In ko, this message translates to:
  /// **'프로필 업데이트에 실패했습니다: {error}'**
  String profileUpdateFailed(Object error);

  /// No description provided for @unsupportedHttpMethod.
  ///
  /// In ko, this message translates to:
  /// **'지원하지 않는 HTTP 메소드입니다: {method}'**
  String unsupportedHttpMethod(Object method);

  /// No description provided for @networkConnectionFailed.
  ///
  /// In ko, this message translates to:
  /// **'네트워크 연결에 실패했습니다. 인터넷 연결을 확인해주세요.'**
  String get networkConnectionFailed;

  /// No description provided for @invalidResponseFormat.
  ///
  /// In ko, this message translates to:
  /// **'서버로부터 잘못된 응답 형식을 받았습니다.'**
  String get invalidResponseFormat;

  /// No description provided for @unexpectedError.
  ///
  /// In ko, this message translates to:
  /// **'예기치 않은 오류가 발생했습니다: {error}'**
  String unexpectedError(Object error);

  /// No description provided for @connectionTimeout.
  ///
  /// In ko, this message translates to:
  /// **'연결 시간이 초과되었습니다'**
  String get connectionTimeout;

  /// No description provided for @noInternetConnection.
  ///
  /// In ko, this message translates to:
  /// **'인터넷 연결이 없습니다'**
  String get noInternetConnection;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
