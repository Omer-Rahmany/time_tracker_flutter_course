import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker_flutter_course/app/home/jobs/job_model.dart';
import 'package:time_tracker_flutter_course/app/home/models/job.dart';
import 'package:time_tracker_flutter_course/common_widgets/show_alert_dialog.dart';
import 'package:time_tracker_flutter_course/common_widgets/show_exception_alert_dialog.dart';
import 'package:time_tracker_flutter_course/services/database.dart';

class EditJobPage extends StatefulWidget {
  const EditJobPage({Key? key, required this.model, this.job})
      : super(key: key);
  final JobModel model;
  final Job? job;

  static Future<void> show(
    BuildContext context, {
      required Database database,
    Job? job,
  }) async {
    await Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
      builder: (context) => ChangeNotifierProvider<JobModel>(
        create: (_) => job != null
            ? JobModel(
                database: database,
                id: job.id,
                name: job.name,
                ratePerHour: job.ratePerHour,
                formType: JobFormType.edit)
            : JobModel(database: database, formType: JobFormType.create),
        child: Consumer<JobModel>(
            builder: (_, model, __) => EditJobPage(
                  model: model,
                  job: job,
                )),
      ),
      fullscreenDialog: true,
    ));
  }

  @override
  _EditJobPageState createState() => _EditJobPageState();
}

class _EditJobPageState extends State<EditJobPage> {
  final _formKey = GlobalKey<FormState>();

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _ratePerHourFocusNode = FocusNode();

  JobModel get model => widget.model;

  void dispose() {
    _nameFocusNode.dispose();
    _ratePerHourFocusNode.dispose();
    super.dispose();
  }

  void _nameEditingComplete() {
    final newFocus = model.nameValidator.isValid(model.name)
        ? _ratePerHourFocusNode
        : _nameFocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

  bool _validateAndSaveForm() {
    final form = _formKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  Future<void> _submit() async {
    model.updateWith(submitted: true);
    if (_validateAndSaveForm()) {
      try {
        if (!await model.canCreateJob()) {
          showAlertDialog(
            context,
            title: 'Name already in use',
            content: 'Please choose a different job name',
            defaultActionText: 'OK',
          );
          FocusScope.of(context).requestFocus(_nameFocusNode);
        } else {
          await model.submit();
          Navigator.of(context).pop();
        }
      } on FirebaseException catch (e) {
        showExceptionAlertDialog(
          context,
          title: 'Operation Failed',
          exception: e,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        title: Text(model.appBarTitleText),
        actions: [
          TextButton(
            onPressed: _submit,
            child: Text(
              'Save',
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
      body: _buildContents(context),
      backgroundColor: Colors.grey[200],
    );
  }

  Widget _buildContents(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: model.isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _buildForm(context)),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _buildChildren(context),
        ));
  }

  List<Widget> _buildChildren(BuildContext context) {
    return [
      _buildNameTextFormField(),
      buildRatePerHourTextFormField(),
    ];
  }

  TextFormField _buildNameTextFormField() {
    return TextFormField(
      initialValue: model.name,
      decoration: InputDecoration(labelText: 'Job name'),
      onSaved: (value) => model.updateWith(name: value!),
      validator: (value) {
        if (model.nameErrorText == null) {
          _nameEditingComplete();
        }
        return model.nameErrorText;
      },
      focusNode: _nameFocusNode,
      autofocus: true,
      onEditingComplete: () => _nameEditingComplete(),
      textInputAction: TextInputAction.next,
      enabled: model.isLoading == false,
      onChanged: model.updateName,
    );
  }

  TextFormField buildRatePerHourTextFormField() {
    return TextFormField(
      initialValue: model.ratePerHour > 0 ? model.ratePerHour.toString() : null,
      decoration: InputDecoration(labelText: 'Rate per hour'),
      keyboardType: TextInputType.numberWithOptions(
        signed: false,
        decimal: false,
      ),
      onSaved: (value) =>
          model.updateWith(ratePerHour: int.tryParse(value!) ?? 0),
      focusNode: _ratePerHourFocusNode,
      enabled: model.isLoading == false,
      validator: (value) =>
          model.ratePerHourErrorText ?? model.ratePerHourErrorText,
      onChanged: (value) =>
          model.updateWith(ratePerHour: int.tryParse(value) ?? 0),
    );
  }
}
