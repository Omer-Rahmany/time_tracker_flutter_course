import 'package:flutter/cupertino.dart';
import 'package:time_tracker_flutter_course/app/home/models/job.dart';
import 'package:time_tracker_flutter_course/app/sign_in/validators.dart';
import 'package:time_tracker_flutter_course/services/database.dart';

enum JobFormType {
  create,
  edit,
}

class JobModel with NameAndRatePerHourValidators, ChangeNotifier {
  JobModel({
    @required this.database,
    this.id,
    this.name = '',
    this.ratePerHour = -1,
    this.isLoading = false,
    this.submitted = false,
    this.formType = JobFormType.create,
  });
  final Database database;

  String id;
  String name;
  int ratePerHour;
  bool isLoading;
  bool submitted;
  JobFormType formType;

  String get appBarTitleText =>
      formType == JobFormType.create ? 'New Job' : 'Edit Job';

  bool get canSubmit =>
      !isLoading &&
      nameValidator.isValid(name) &&
      ratePerHourValidator.isValid(ratePerHour);

  String get nameErrorText {
    bool showErrorText = submitted && !nameValidator.isValid(name);
    return showErrorText ? invalidNameErrorText : null;
  }

  String get ratePerHourErrorText {
    bool showErrorText =
        submitted && !ratePerHourValidator.isValid(ratePerHour);
    return showErrorText ? invalidRatePerHourErrorText : null;
  }

  Future<bool> canCreateJob() async {
    final jobs = await database.jobsStream().first;
    final allNames = jobs.map((job) => job.name).toList();
    if (this.id != null) allNames.remove(this.name);
    return !allNames.contains(name);
  }

  Future<void> submit() async {
    updateWith(submitted: true, isLoading: true);
    try {
      final jobId = this.id ?? documentIdFromCurrentDate();
      final job = Job(id: jobId, name: name, ratePerHour: ratePerHour);
      await database.setJob(job);
    } catch (e) {
      updateWith(isLoading: false);
      rethrow;
    }
  }

  void updateName(String name) => updateWith(name: name);

  void updateRatePerHour(int ratePerHour) =>
      updateWith(ratePerHour: ratePerHour);

  void updateFormType(JobFormType formType) => updateWith(formType: formType);

  void updateWith({
    String id,
    String name,
    int ratePerHour,
    bool isLoading,
    bool submitted,
    JobFormType formType,
  }) {
    this.id = id ?? this.id;
    this.name = name ?? this.name;
    this.ratePerHour = ratePerHour ?? this.ratePerHour;
    this.isLoading = isLoading ?? this.isLoading;
    this.submitted = submitted ?? this.submitted;
    this.formType = formType ?? this.formType;
    notifyListeners();
  }

  void updateWithJob({Job job}) {
    this.id = job.id ?? this.id;
    this.name = job.name ?? this.name;
    this.ratePerHour = job.ratePerHour ?? this.ratePerHour;
    notifyListeners();
  }
}
