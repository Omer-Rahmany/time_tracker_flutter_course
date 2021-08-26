import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker_flutter_course/app/home/models/job.dart';
import 'package:time_tracker_flutter_course/common_widgets/show_exception_alert_dialog.dart';
import 'package:time_tracker_flutter_course/services/database.dart';

class AddJobPage extends StatefulWidget {
  const AddJobPage({Key key, this.database}) : super(key: key);
  final Database database;

  static Future<void> show(BuildContext context) async {
    final database = Provider.of<Database>(context, listen: false);
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AddJobPage(database: database),
      fullscreenDialog: true,
    ));
  }

  @override
  _AddJobPageState createState() => _AddJobPageState();
}

class _AddJobPageState extends State<AddJobPage> {
  final _formKey = GlobalKey<FormState>();

  String _name;
  int _ratePerHour;

  bool _validateAndSaveForm() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  Future<void> _submit() async {
    if (_validateAndSaveForm()) {
      try {
        final job = Job(name: _name, ratePerHour: _ratePerHour);
        await widget.database.createJob(job);
        Navigator.of(context).pop();
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
        title: Text('New Job'),
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
            child: _buildForm(context),
          ),
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
      TextFormField(
        decoration: InputDecoration(labelText: 'Job name'),
        onSaved: (value) => _name = value,
        validator: (value) => value.isNotEmpty ? null : 'Name can\'t be empty',
      ),
      TextFormField(
        decoration: InputDecoration(labelText: 'Rate per hour'),
        keyboardType: TextInputType.numberWithOptions(
          signed: false,
          decimal: false,
        ),
        onSaved: (value) => _ratePerHour = int.parse(value) ?? 0,
      ),
    ];
  }
}
